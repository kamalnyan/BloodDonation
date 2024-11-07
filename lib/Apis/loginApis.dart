import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrganLS {
  // Firestore instance
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method for signing up with email and password
  static Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.sendEmailVerification();
      print("User signed up: ${userCredential.user!.email}");
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
  static Future<bool> loginWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
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
  }) async {
    try {
      await _firestore.collection('organs').add({
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
        'lastSurgery': lastSurgery != null ? Timestamp.fromDate(lastSurgery) : null,
        'lifestyleInfo': lifestyleInfo,
        'specialInstructions': specialInstructions,
        'location': location,
        'timestamp': FieldValue.serverTimestamp(),
      });
      log("Organ details added successfully!");
    } catch (e) {
      log("Error adding organ details: $e");
    }
  }

  // Method to fetch organ details from Firestore
  static Stream<List<Organ>> fetchOrganDetails() {
    return _firestore.collection('organs').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Organ.fromFirestore(doc);
      }).toList();
    });
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
  }) async {
    try {
      await _firestore.collection('blood').add({
        'donorName': donorName,
        'age': age,
        'weight': weight,
        'bloodGroup': bloodGroup,
        'contactNumber': contactNumber,
        'medicalHistory': medicalHistory,
        'allergies': allergies,
        'lastDonationDate': lastDonationDate != null ? Timestamp.fromDate(lastDonationDate) : null,
        'preferredDonationType': preferredDonationType,
        'location': location,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Blood details added successfully!");
    } catch (e) {
      print("Error adding blood details: $e");
    }
  }

  // Method to fetch blood details from Firestore
  static Stream<List<Blood>> fetchBloodDetails() {
    return _firestore.collection('blood').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Blood.fromFirestore(doc);
      }).toList();
    });
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
  }) async {
    try {
      await _firestore.collection('bloodRequired').add({
        'donorName': donorName,
        'age': age,
        'bloodGroup': bloodGroup,
        'quantity': quantity,
        'contactNumber': contactNumber,
        'urgency': urgency,
        'location': location,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Blood details added successfully!");
    } catch (e) {
      print("Error adding blood details: $e");
    }
  }

  // Method to fetch blood details from Firestore
  static Stream<List<Blood>> fetchBloodDetailsrequired() {
    return _firestore.collection('bloodRequired').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Blood.fromFirestore(doc);
      }).toList();
    });
  }

  // Method to add organ details to Firestore
  static Future<void> addOrganDetailsrequired({
    required String donorName,
    required String organType,
    required String bloodGroup,
    required String contactNumber,
    required String urgency,
    required String location,
    required String requiredDate,
  }) async {
    try {
      await _firestore.collection('organRequired').add({
        'donorName': donorName,
        'organType': organType,
        'bloodGroup': bloodGroup,
        'contactNumber': contactNumber,
        'urgency': urgency,
        'location': location,
        'requiredDate': requiredDate,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Organ details added successfully!");
    } catch (e) {
      print("Error adding organ details: $e");
    }
  }

  // Method to fetch organ details from Firestore
  static Stream<List<Organ>> fetchOrganDetailsrequired() {
    return _firestore.collection('organRequired').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Organ.fromFirestore(doc);
      }).toList();
    });
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
      lastDonationDate: data['lastDonationDate'] != null ? (data['lastDonationDate'] as Timestamp).toDate() : null,
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
      'lastDonationDate': lastDonationDate != null ? Timestamp.fromDate(lastDonationDate!) : null,
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
      lastSurgery: data['lastSurgery'] != null ? (data['lastSurgery'] as Timestamp).toDate() : null,
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
      'lastSurgery': lastSurgery != null ? Timestamp.fromDate(lastSurgery!) : null,
      'lifestyleInfo': lifestyleInfo,
      'specialInstructions': specialInstructions,
      'location': location,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
class BloodRequired{
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
  factory BloodRequired.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
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
class OrganRequired{
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
  factory OrganRequired.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
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
