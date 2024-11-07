import 'dart:async';

import 'package:brg_donation/BrgManages/uploadBlood.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Apis/loginApis.dart';
import '../BrgManages/profile.dart';
import '../BrgManages/requiredBlood_Organ.dart';
import '../BrgManages/uploadOrgans.dart';
import '../detailsScreen/bloodDetails.dart';
import '../detailsScreen/organDetails.dart';
import '../detailsScreen/requiredDetails.dart';
import '../helper/shimmar.dart';
import '../login&signup/intoScreen.dart';
import '../themes/colors.dart';
import '../themes/dark_light_switch.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: isDarkMode(context) ? CradDark : Colors.white,
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading:
                  Icon(Icons.bloodtype, color: LightDark(isDarkMode(context))),
              title: Text(
                'Blood',
                style: TextStyle(color: LightDark(isDarkMode(context))),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddBloodDonationScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.monitor_heart,
                  color: LightDark(isDarkMode(context))),
              title: Text(
                'Organ',
                style: TextStyle(color: LightDark(isDarkMode(context))),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddOrganScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.health_and_safety,
                  color: LightDark(isDarkMode(context))),
              title: Text(
                'Required Blood / Organ',
                style: TextStyle(color: LightDark(isDarkMode(context))),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RequestScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }
  @override
  void initState() {
    _validateUser();
    OrganLS.fetchUserInfo();
    super.initState();
  }
  Future<void> _validateUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser; // Get the current user
      if (user != null) {
        // Reload user data to get the latest status
        await user.reload();
        user = FirebaseAuth.instance.currentUser; // Update with the latest user data

        // Check if the user is anonymous, email is not verified, or user no longer exists
        if (user!.isAnonymous || !user!.emailVerified) {
          // Sign out and navigate to the IntroScreen
          await FirebaseAuth.instance.signOut();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const IntroScreen()),
                (route) => false,
          );
        }
      } else {
        // If user is null (not found), sign out and navigate to the IntroScreen
        await FirebaseAuth.instance.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const IntroScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      // Handle any error that might occur
      print('Error: $e');
      // Sign out and navigate to the IntroScreen in case of an error
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const IntroScreen()),
            (route) => false,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Three tabs: Required Donor, Blood, and Organ
      child: Scaffold(
        backgroundColor: darkLight(isDarkMode(context)),
        appBar: AppBar(
          title: const Text('HopeLink'),
          backgroundColor: Colors.yellow,
          actions: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProfilePage()));
                  },
                  icon: const Icon(
                    Icons.account_circle,
                    size: 35,
                  )),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Required Donor'),
              Tab(text: 'Blood'),
              Tab(text: 'Organ'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Required Donor (Fetch both Blood and Organ Requirements)
            StreamBuilder<QuerySnapshot>(
              stream: OrganLS.fetchOrganDetailsrequired(),
              builder: (context, organSnapshot) {
                if (organSnapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => shimmarr(context),
                  );
                }

                if (organSnapshot.hasError) {
                  return Center(child: Text('Error: ${organSnapshot.error}'));
                }

                if (!organSnapshot.hasData ||
                    organSnapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No organ donors found.',
                      style: TextStyle(color: LightDark(isDarkMode(context))),
                    ),
                  );
                }

                final allOrganDonors = organSnapshot.data!.docs;

                return StreamBuilder<QuerySnapshot>(
                  stream: OrganLS.fetchBloodDetailsrequired(),
                  builder: (context, bloodSnapshot) {
                    if (bloodSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) => shimmarr(context),
                      );
                    }

                    if (bloodSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${bloodSnapshot.error}'));
                    }

                    if (!bloodSnapshot.hasData ||
                        bloodSnapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No blood donors found.',
                          style:
                              TextStyle(color: LightDark(isDarkMode(context))),
                        ),
                      );
                    }

                    final allBloodDonors = bloodSnapshot.data!.docs;

                    return FutureBuilder<List<DocumentSnapshot>>(
                      future: OrganLS.filterDonorsBasedOnDistance(
                          allOrganDonors + allBloodDonors),
                      builder: (context, asyncSnapshot) {
                        if (asyncSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ListView.builder(
                            itemCount: 5,
                            itemBuilder: (context, index) => shimmarr(context),
                          );
                        }

                        final filteredDonors = asyncSnapshot.data ?? [];
                        if (filteredDonors.isEmpty) {
                          return Center(
                            child: Text(
                              'No donors found near you.',
                              style: TextStyle(
                                  color: LightDark(isDarkMode(context))),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: filteredDonors.length,
                          itemBuilder: (context, index) {
                            final donorData = filteredDonors[index].data()
                                as Map<String, dynamic>?;

                            if (donorData == null) {
                              return const SizedBox.shrink();
                            }

                            final donorName =
                                donorData['donorName'] ?? 'Unknown';
                            final donationType = donorData['organType'] ??
                                donorData['bloodGroup'] ??
                                'Unknown';
                            final location = donorData['location'] ?? 'Unknown';
                            final age = donorData['age']?.toString() ?? 'N/A';
                            final weight =
                                donorData['weight']?.toString() ?? 'N/A';
                            final contactNumber =
                                donorData['contactNumber'] ?? 'N/A';
                            final medicalHistory =
                                donorData['medicalHistory'] ?? 'None';
                            final allergies = donorData['allergies'] ?? 'None';
                            final lastDonationDate =
                                donorData['lastDonationDate'] ?? 'N/A';
                            final preferredDonationType =
                                donorData['preferredDonationType'] ?? 'N/A';

                            return InkWell(
                              onTap: () {
                                final isOrganRequest =
                                    donorData.containsKey('organType');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Requireddetails(
                                      isOragnRequest: isOrganRequest,
                                      donorName: donorName,
                                      age: age,
                                      weight: weight,
                                      bloodGroup:
                                          donorData['bloodGroup'] ?? 'N/A',
                                      contactNumber: contactNumber,
                                      gender: donorData['gender'] ?? 'N/A',
                                      hospitalName:
                                          donorData['hospitalName'] ?? 'N/A',
                                      urgency: donorData['urgency'] ?? 'N/A',
                                      location: location,
                                      organName: isOrganRequest
                                          ? donorData['organType']
                                          : null,
                                      requiredDate:
                                          donorData['requiredDate'] ?? 'N/A',
                                      quantity: isOrganRequest
                                          ? null
                                          : donorData['quantity'],
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                color: isDarkMode(context)
                                    ? CradDark
                                    : Colors.white,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        donationType,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: LightDark(isDarkMode(context)),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Provided by: $donorName',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: LightDark(isDarkMode(context)),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Location: $location',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: LightDark(isDarkMode(context)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
            //Blood
            StreamBuilder<QuerySnapshot>(
              stream: OrganLS.fetchBloodDetails(),
              builder: (context, snapshot) {
                // Handling loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => shimmarr(context),
                  );
                }

                // Handling errors
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Check if snapshot has data
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No blood donors found.',
                      style: TextStyle(color: LightDark(isDarkMode(context))),
                    ),
                  );
                }

                final allDonors = snapshot.data!.docs;
                return FutureBuilder<List<DocumentSnapshot>>(
                  future: OrganLS.filterDonorsBasedOnDistance(allDonors),
                  builder: (context, asyncSnapshot) {
                    if (asyncSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) => shimmarr(context),
                      );
                    }

                    final filteredDonors = asyncSnapshot.data ?? [];
                    if (filteredDonors.isEmpty) {
                      return Center(
                        child: Text(
                          'No blood donors found near you.',
                          style:
                              TextStyle(color: LightDark(isDarkMode(context))),
                        ),
                      );
                    }

                    // Display filtered donors
                    return ListView.builder(
                      itemCount: filteredDonors.length,
                      itemBuilder: (context, index) {
                        final bloodDonorData = filteredDonors[index].data()
                            as Map<String, dynamic>?;

                        if (bloodDonorData == null) {
                          return const SizedBox.shrink();
                        }

                        // Extract donor details
                        final donorName =
                            bloodDonorData['donorName'] ?? 'Unknown';
                        final bloodType =
                            bloodDonorData['bloodGroup'] ?? 'Unknown';
                        final location =
                            bloodDonorData['location'] ?? 'Unknown';
                        final age = bloodDonorData['age']?.toString() ?? 'N/A';
                        final weight =
                            bloodDonorData['weight']?.toString() ?? 'N/A';
                        final contactNumber =
                            bloodDonorData['contactNumber'] ?? 'N/A';
                        final medicalHistory =
                            bloodDonorData['medicalHistory'] ?? 'None';
                        final allergies = bloodDonorData['allergies'] ?? 'None';
                        final lastDonationDate =
                            bloodDonorData['lastDonationDate'] ?? 'N/A';
                        final preferredDonationType =
                            bloodDonorData['preferredDonationType'] ?? 'N/A';

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BloodDonorDetailsScreen(
                                  donorName: donorName,
                                  age: age,
                                  weight: weight,
                                  bloodGroup: bloodType,
                                  contactNumber: contactNumber,
                                  medicalHistory: medicalHistory,
                                  allergies: allergies,
                                  lastDonationDate: lastDonationDate,
                                  preferredDonationType: preferredDonationType,
                                  location: location,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            color:
                                isDarkMode(context) ? CradDark : Colors.white,
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bloodType,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: LightDark(isDarkMode(context)),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Provided by: $donorName',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: LightDark(isDarkMode(context)),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Location: $location',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: LightDark(isDarkMode(context)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            //Organ
            StreamBuilder<QuerySnapshot>(
              stream: OrganLS.fetchOrganDetails(),
              builder: (context, snapshot) {
                // Handling loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => shimmarr(context),
                  );
                }

                // Handling errors
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Check if snapshot has data
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No Organ donors found.',
                      style: TextStyle(color: LightDark(isDarkMode(context))),
                    ),
                  );
                }
                final allDonors = snapshot.data!.docs;

                return FutureBuilder<List<DocumentSnapshot>>(
                  future: OrganLS.filterDonorsBasedOnDistance(allDonors),
                  builder: (context, asyncSnapshot) {
                    if (asyncSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) => shimmarr(context),
                      );
                    }

                    final filteredDonors = asyncSnapshot.data ?? [];
                    if (filteredDonors.isEmpty) {
                      return Center(
                        child: Text(
                          'No Organ donors found near you',
                          style:
                              TextStyle(color: LightDark(isDarkMode(context))),
                        ),
                      );
                    }

                    // Display filtered donors
                    return ListView.builder(
                      itemCount: filteredDonors.length,
                      itemBuilder: (context, index) {
                        final organ = filteredDonors[index].data()
                            as Map<String, dynamic>?;

                        if (organ == null) {
                          return const SizedBox.shrink();
                        }

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrganDonorDetailsScreen(
                                  donorName:
                                      organ['donorName'] ?? 'Unknown Donor',
                                  organName:
                                      organ['organName'] ?? 'Unknown Organ',
                                  contactNumber: organ['contactNumber'] ??
                                      'No Contact Number',
                                  bloodGroup: organ['bloodGroup'] ??
                                      'Unknown Blood Group',
                                  hospitalName: organ['hospitalName'] ??
                                      'Unknown Hospital',
                                  isAvailable: organ['isAvailable'] ?? false,
                                  age: organ['age'] ??
                                      "", // Use default 0 if null
                                  weight: organ['weight'] ??
                                      "", // Use default 0 if null
                                  height: organ['height'] ??
                                      "", // Use default 0 if null
                                  gender: organ['gender'] ?? 'Unknown Gender',
                                  id: organ['id'] ?? 'Unknown ID',
                                  email: organ['email'] ?? 'No Email',
                                  medicalHistory: organ['medicalHistory'] ??
                                      'No Medical History',
                                  allergies:
                                      organ['allergies'] ?? 'No Allergies',
                                  reason:
                                      organ['reason'] ?? 'No Reason Provided',
                                  nextOfKin:
                                      organ['nextOfKin'] ?? 'No Next of Kin',
                                  lastSurgery: organ['lastSurgery']
                                          .toString() ??
                                      "Not Provided", // Use current date if null
                                  lifestyleInfo: organ['lifestyleInfo'] ??
                                      'No Lifestyle Info',
                                  specialInstructions:
                                      organ['specialInstructions'] ??
                                          'No Special Instructions',
                                  location:
                                      organ['location'] ?? 'Unknown Location',
                                ),
                              ),
                            );
                          },
                          child: Card(
                            color:
                                isDarkMode(context) ? CradDark : Colors.white,
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    organ['organName'] ?? 'Unknown Organ',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: LightDark(isDarkMode(context)),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Provided by: ${organ['donorName'] ?? 'Unknown Donor'}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: LightDark(isDarkMode(context))),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Location: ${organ['location'] ?? 'Unknown Location'}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: LightDark(isDarkMode(context)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            )
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton(
            onPressed: () {
              _showOptions(context);
            },
            backgroundColor: Colors.yellow,
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
