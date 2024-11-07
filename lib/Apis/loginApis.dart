import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

import '../helper/chatUser.dart';
import 'Apis.dart';

class OrganLS {
  // Firestore instance
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static User? user = _auth.currentUser;
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;
// Function to initialize ChatUser and add to Firestore
  static Future<void> initializeAndAddUserToFirestore({
    required String id,
    required String name,
    required String email,
    required String image,
    required String about,
    String? pushToken,
  }) async {
    // Create an instance of ChatUser using the provided field values
    ChatUser me = ChatUser(
      image: image,
      about: about,
      name: name,
      createdAt: Timestamp.now().toString(),
      id: id,
      email: email,
      pushToken: "",
    );

    // Add to Firestore
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(me.id)
          .set(me.toJson());
      print("User added to Firestore successfully");
    } catch (e) {
      print("Error adding user to Firestore: $e");
    }
  }

  static ChatUser me = ChatUser(
    image: '',
    about: '',
    name: '',
    createdAt: '',
    id: '',
    email: '',
    pushToken: '',
  );
  static Future<void> fetchUserInfo() async {
    try {
      if (user == null) throw Exception("No user is currently logged in.");
      final DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(user!.uid).get();
      if (userDoc.exists) {
        me = ChatUser.fromJson(userDoc.data() as Map<String, dynamic>);
        log("User info fetched successfully: ${me.name}");
        await getFirebaseMessagingToken();
      } else {
        log("No user document found for UID: ${user!.uid}");
      }
    } catch (e) {
      log("Error fetching user info: $e");
    }
  }

  static Future<void> getFirebaseMessagingToken() async {
    try {
      // Request permission for notifications
      await fMessaging.requestPermission();

      // Get the Firebase messaging token
      String? token = await fMessaging.getToken();

      if (token != null) {
        // Check if the user document exists
        DocumentSnapshot userDoc =
            await _firestore.collection('Users').doc(user!.uid).get();
        if (userDoc.exists) {
          // Update the pushToken in Firestore
          await _firestore.collection('Users').doc(user!.uid).update({
            'pushToken': token,
          });
          print("Push token updated successfully.");
        } else {
          print("Document does not exist for user: ${user!.uid}");
        }

        // Update the local ChatUser instance
        me.pushToken = token;
      } else {
        print("Failed to retrieve push token.");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  static Future<LocationData?> getCurrentLocation() async {
    Location location = Location();
    try {
      // Check if location services are enabled
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          print('Location services are disabled.');
          return null; // Return null to indicate failure
        }
      }

      // Check location permissions
      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          print('Location permissions are denied.');
          return null; // Return null to indicate failure
        }
      }

      if (permissionGranted == PermissionStatus.deniedForever) {
        print(
            'Location permissions are permanently denied, cannot request permissions.');
        // Optionally, guide the user to open app settings:
        return null;
      }

      // Get the current location
      return await location.getLocation();
    } on PlatformException catch (e) {
      print('Error: ${e.message}');
      return null; // Handle any platform-specific errors
    }
  }

  static Future<List<DocumentSnapshot>> filterDonorsBasedOnDistance(
      List<DocumentSnapshot> allDonors) async {
    try {
      LocationData? locationData = await getCurrentLocation();
      if (locationData == null) {
        throw Exception('Unable to retrieve location.');
      }

      double userLatitude = locationData.latitude!;
      double userLongitude = locationData.longitude!;

      List<DocumentSnapshot> filteredDonors = [];

      for (var donor in allDonors) {
        double donorLatitude = donor['lat'];
        double donorLongitude = donor['log'];

        double distanceInMeters = Geolocator.distanceBetween(
          userLatitude,
          userLongitude,
          donorLatitude,
          donorLongitude,
        );
        // If the distance is within 50 km, add to the list
        if (distanceInMeters <= 50000) {
          filteredDonors.add(donor);
        }
      }
      return filteredDonors;
    } catch (e) {
      print("Error fetching donors: $e");
      return [];
    }
  }

  static Future<void> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).then((UserCredential userCredential) {
        // Process after user is created
        initializeAndAddUserToFirestore(
          id: userCredential.user!.uid,
          name: name,
          email: email,
          image: "",
          about: "Hey there, I am using organ donation",
        );

        // Print the user's email
        print("User signed up: ${userCredential.user!.email}");

        // Send email verification
        userCredential.user?.sendEmailVerification().then((_) {
          log("Email verification sent!");
        }).catchError((error) {
          log("Failed to send email verification: $error");
        });
      }).catchError((error) {
        log("Error signing up: $error");
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  // Method for logging in with email and password
  static Future<bool> loginWithEmailPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("User logged in: ${userCredential.user!.email}");
      return true; // Login successful
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided.');
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Method to check if the email is verified
  static bool isEmailVerified(User? user) {
    if (user != null) {
      return user.emailVerified;
    }
    return false; // User is null, hence not verified
  }

  // Method to add organ details to Firestore
  static Future<void> addOrganDetails({
    required String donorName,
    required String organName,
    required String contactNumber,
    required String bloodGroup,
    required String hospitalName,
    required bool isAvailable,
    required String age,
    required String weight,
    required String height,
    required String gender,
    required String id,
    required String email,
    required String medicalHistory,
    required String allergies,
    required String reason,
    required String nextOfKin,
    required DateTime? lastSurgery,
    required String lifestyleInfo,
    required String specialInstructions,
    required String location,
    required double? lat,
    required double? logg,
  }) async {
    try {
      await _firestore
          .collection('organs')
          .doc(user?.uid)
          .collection("userOrgan")
          .add({
        'donorName': donorName,
        'organName': organName,
        'contactNumber': contactNumber,
        'bloodGroup': bloodGroup,
        'hospitalName': hospitalName,
        'isAvailable': isAvailable,
        'age': age,
        'weight': weight,
        'height': height,
        'gender': gender,
        'id': id,
        'email': email,
        'medicalHistory': medicalHistory,
        'allergies': allergies,
        'reason': reason,
        'nextOfKin': nextOfKin,
        'lastSurgery':
            lastSurgery != null ? Timestamp.fromDate(lastSurgery) : null,
        'lifestyleInfo': lifestyleInfo,
        'specialInstructions': specialInstructions,
        'location': location,
        'lat': lat,
        'log': logg,
        'timestamp': FieldValue.serverTimestamp(),
      });
      sendNotificationToAllUsers("$organName Avilable", false, "Organ");
      log("Organ details added successfully!");
    } catch (e) {
      log("Error adding organ details: $e");
    }
  }

  // Method to fetch organ details from Firestore
  static Stream<QuerySnapshot<Object?>> fetchOrganDetails() {
    return _firestore.collectionGroup("userOrgan").snapshots();
  }

  // Method to add blood details to Firestore
  static Future<void> addBloodDetails({
    required String donorName,
    required String age,
    required String weight,
    required String bloodGroup,
    required String contactNumber,
    required String medicalHistory,
    required String allergies,
    required DateTime? lastDonationDate,
    required String preferredDonationType,
    required String location,
    required double? lat,
    required double? logg,
  }) async {
    try {
      await _firestore
          .collection('blood')
          .doc(user?.uid)
          .collection("userBloood")
          .add({
        'donorName': donorName,
        'age': age,
        'weight': weight,
        'bloodGroup': bloodGroup,
        'contactNumber': contactNumber,
        'medicalHistory': medicalHistory,
        'allergies': allergies,
        'lastDonationDate': lastDonationDate != null
            ? Timestamp.fromDate(lastDonationDate)
            : null,
        'preferredDonationType': preferredDonationType,
        'location': location,
        'lat': lat,
        'log': logg,
        'timestamp': FieldValue.serverTimestamp(),
      });
      sendNotificationToAllUsers("$bloodGroup", false, "Blood");
      print("Blood details added successfully!");
    } catch (e) {
      print("Error adding blood details: $e");
    }
  }

  // Method to fetch blood details from Firestore
  static Stream<QuerySnapshot<Map<String, dynamic>>> fetchBloodDetails() {
    return _firestore.collectionGroup("userBloood").snapshots();
  }

  // Method to add blood details to Firestore
  static Future<void> addBloodDetailsrequired({
    required String donorName,
    required String age,
    required String bloodGroup,
    required String quantity,
    required String contactNumber,
    required String urgency,
    required String location,
    required String hospitalName,
    required String gender,
    required double? lat,
    required double? logg,
  }) async {
    try {
      await _firestore
          .collection('bloodRequired')
          .doc(user?.uid)
          .collection("userBloodRequired")
          .add({
        'donorName': donorName,
        'age': age,
        'bloodGroup': bloodGroup,
        'quantity': quantity,
        'contactNumber': contactNumber,
        'gender': gender,
        'hospitalName': hospitalName,
        'urgency': urgency,
        'location': location,
        'lat': lat,
        'log': logg,
        'timestamp': FieldValue.serverTimestamp(),
      });
      sendNotificationToAllUsers("$bloodGroup", true, "Blood");
      print("Blood details added successfully!");
    } catch (e) {
      print("Error adding blood details: $e");
    }
  }

  // Method to fetch blood details from Firestore
  static Stream<QuerySnapshot<Object?>> fetchBloodDetailsrequired() {
    return _firestore.collectionGroup("userBloodRequired").snapshots();
  }

  // Method to add organ details to Firestore
  static Future<void> addOrganDetailsrequired({
    required String donorName,
    required String age,
    required String organType,
    required String bloodGroup,
    required String contactNumber,
    required String urgency,
    required String location,
    required String requiredDate,
    required String hospitalName,
    required String gender,
    required double? lat,
    required double? logg,
  }) async {
    try {
      await _firestore
          .collection('organRequired')
          .doc(user?.uid)
          .collection("userOrganRequired")
          .add({
        'donorName': donorName,
        'age': age,
        'organType': organType,
        'bloodGroup': bloodGroup,
        'contactNumber': contactNumber,
        'gender': gender,
        'hospitalName': hospitalName,
        'urgency': urgency,
        'location': location,
        'lat': lat,
        'log': logg,
        'requiredDate': requiredDate,
        'timestamp': FieldValue.serverTimestamp(),
      });
      sendNotificationToAllUsers("$organType Avilable", true, "Organ");
      print("Organ details added successfully!");
    } catch (e) {
      print("Error adding organ details: $e");
    }
  }

  // Method to fetch organ details from Firestore
  static Stream<QuerySnapshot<Object?>> fetchOrganDetailsrequired() {
    return _firestore.collectionGroup("userOrganRequired").snapshots();
  }
}

class Blood {
  final String donorName;
  final int age;
  final double weight;
  final String bloodGroup;
  final String contactNumber;
  final String medicalHistory;
  final String allergies;
  final DateTime? lastDonationDate;
  final String preferredDonationType;
  final String location;
  final Timestamp timestamp;

  Blood({
    required this.donorName,
    required this.age,
    required this.weight,
    required this.bloodGroup,
    required this.contactNumber,
    required this.medicalHistory,
    required this.allergies,
    required this.lastDonationDate,
    required this.preferredDonationType,
    required this.location,
    required this.timestamp,
  });

  // Factory constructor to create Blood object from Firestore document
  factory Blood.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Blood(
      donorName: data['donorName'] ?? '',
      age: int.tryParse(data['age'] ?? '0') ?? 0,
      weight: double.tryParse(data['weight'] ?? '0') ?? 0.0,
      bloodGroup: data['bloodGroup'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      medicalHistory: data['medicalHistory'] ?? '',
      allergies: data['allergies'] ?? '',
      lastDonationDate: data['lastDonationDate'] != null
          ? (data['lastDonationDate'] as Timestamp).toDate()
          : null,
      preferredDonationType: data['preferredDonationType'] ?? '',
      location: data['location'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  // Method to convert Blood object into Firestore format (for uploading)
  Map<String, dynamic> toFirestore() {
    return {
      'donorName': donorName,
      'age': age.toString(),
      'weight': weight.toString(),
      'bloodGroup': bloodGroup,
      'contactNumber': contactNumber,
      'medicalHistory': medicalHistory,
      'allergies': allergies,
      'lastDonationDate': lastDonationDate != null
          ? Timestamp.fromDate(lastDonationDate!)
          : null,
      'preferredDonationType': preferredDonationType,
      'location': location,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}

class Organ {
  final String donorName;
  final String organName;
  final String contactNumber;
  final String bloodGroup;
  final String hospitalName;
  final bool isAvailable;
  final int age;
  final double weight;
  final double height;
  final String gender;
  final String id;
  final String email;
  final String medicalHistory;
  final String allergies;
  final String reason;
  final String nextOfKin;
  final DateTime? lastSurgery;
  final String lifestyleInfo;
  final String specialInstructions;
  final String location;
  final Timestamp timestamp;

  Organ({
    required this.donorName,
    required this.organName,
    required this.contactNumber,
    required this.bloodGroup,
    required this.hospitalName,
    required this.isAvailable,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.id,
    required this.email,
    required this.medicalHistory,
    required this.allergies,
    required this.reason,
    required this.nextOfKin,
    required this.lastSurgery,
    required this.lifestyleInfo,
    required this.specialInstructions,
    required this.location,
    required this.timestamp,
  });

  // Factory constructor to create Organ object from Firestore document
  factory Organ.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Organ(
      donorName: data['donorName'] ?? '',
      organName: data['organName'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      bloodGroup: data['bloodGroup'] ?? '',
      hospitalName: data['hospitalName'] ?? '',
      isAvailable: data['isAvailable'] ?? false,
      age: data['age'] ?? 0,
      weight: (data['weight'] ?? 0).toDouble(),
      height: (data['height'] ?? 0).toDouble(),
      gender: data['gender'] ?? '',
      id: data['id'] ?? '',
      email: data['email'] ?? '',
      medicalHistory: data['medicalHistory'] ?? '',
      allergies: data['allergies'] ?? '',
      reason: data['reason'] ?? '',
      nextOfKin: data['nextOfKin'] ?? '',
      lastSurgery: data['lastSurgery'] != null
          ? (data['lastSurgery'] as Timestamp).toDate()
          : null,
      lifestyleInfo: data['lifestyleInfo'] ?? '',
      specialInstructions: data['specialInstructions'] ?? '',
      location: data['location'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  // Method to convert Organ object into Firestore format (for uploading)
  Map<String, dynamic> toFirestore() {
    return {
      'donorName': donorName,
      'organName': organName,
      'contactNumber': contactNumber,
      'bloodGroup': bloodGroup,
      'hospitalName': hospitalName,
      'isAvailable': isAvailable,
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'id': id,
      'email': email,
      'medicalHistory': medicalHistory,
      'allergies': allergies,
      'reason': reason,
      'nextOfKin': nextOfKin,
      'lastSurgery':
          lastSurgery != null ? Timestamp.fromDate(lastSurgery!) : null,
      'lifestyleInfo': lifestyleInfo,
      'specialInstructions': specialInstructions,
      'location': location,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}

class BloodRequired {
  final String donorName;
  final int age;
  final String bloodGroup;
  final double quantity;
  final String contactNumber;
  final String urgency;
  final String location;
  final Timestamp timestamp;

  BloodRequired({
    required this.donorName,
    required this.age,
    required this.bloodGroup,
    required this.quantity,
    required this.contactNumber,
    required this.urgency,
    required this.location,
    required this.timestamp,
  });

  // Factory constructor to create Blood object from Firestore document
  factory BloodRequired.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return BloodRequired(
      donorName: data['donorName'] ?? '',
      age: data['age'] ?? 0,
      bloodGroup: data['bloodGroup'] ?? '',
      quantity: (data['quantity'] ?? 0).toDouble(),
      contactNumber: data['contactNumber'] ?? '',
      urgency: data['urgency'] ?? '',
      location: data['location'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}

class OrganRequired {
  final String donorName;
  final String organType;
  final String bloodGroup;
  final String contactNumber;
  final String urgency;
  final String location;
  final String requiredDate;
  final Timestamp timestamp;

  OrganRequired({
    required this.donorName,
    required this.organType,
    required this.bloodGroup,
    required this.contactNumber,
    required this.urgency,
    required this.location,
    required this.requiredDate,
    required this.timestamp,
  });

  // Factory constructor to create Organ object from Firestore document
  factory OrganRequired.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return OrganRequired(
      donorName: data['donorName'] ?? '',
      organType: data['organType'] ?? '',
      bloodGroup: data['bloodGroup'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      urgency: data['urgency'] ?? '',
      location: data['location'] ?? '',
      requiredDate: data['requiredDate'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}
