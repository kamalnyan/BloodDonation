import 'package:brg_donation/BrgManages/uploadBlood.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Apis/loginApis.dart';
import '../BrgManages/requiredBlood_Organ.dart';
import '../BrgManages/uploadOrgans.dart';
import '../detailsScreen/bloodDetails.dart';
import '../detailsScreen/organDetails.dart';

class HomeScreen extends StatelessWidget {
  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.bloodtype),
              title: Text('Blood'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddBloodDonationScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.monitor_heart),
              title: Text('Organ'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddOrganScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.health_and_safety),
              title: Text('Required Blood / Organ'),
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
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Three tabs: Required Donor, Blood, and Organ
      child: Scaffold(
        appBar: AppBar(
          title: const Text('HopeLink'),
          backgroundColor: Colors.yellow,
          actions: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/logi.png'),
              ),
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
              stream: FirebaseFirestore.instance.collection('organRequired').snapshots(),
              builder: (context, organSnapshot) {
                if (organSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (organSnapshot.hasError) {
                  return Center(child: Text('Error: ${organSnapshot.error}'));
                }

                final organList = organSnapshot.data?.docs.map((doc) {
                  return doc.data() as Map<String, dynamic>;
                }).toList();

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('bloodRequired').snapshots(),
                  builder: (context, bloodSnapshot) {
                    if (bloodSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (bloodSnapshot.hasError) {
                      return Center(child: Text('Error: ${bloodSnapshot.error}'));
                    }

                    final bloodList = bloodSnapshot.data?.docs.map((doc) {
                      return doc.data() as Map<String, dynamic>;
                    }).toList();

                    if ((organList == null || organList.isEmpty) &&
                        (bloodList == null || bloodList.isEmpty)) {
                      return const Center(child: Text('No requirements found.'));
                    }

                    return ListView(
                      children: [
                        if (organList != null && organList.isNotEmpty)
                          ...organList.map((requirement) {
                            final requesterName = requirement['donorName'] ?? 'Unknown Requester';
                            final donationType = requirement['organType'] ?? 'Unknown Type';
                            final location = requirement['location'] ?? 'Unknown Location';

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      donationType,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Requested by: $requesterName',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Location: $location',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        if (bloodList != null && bloodList.isNotEmpty)
                          ...bloodList.map((requirement) {
                            final requesterName = requirement['donorName'] ?? 'Unknown Requester';
                            final donationType = requirement['bloodGroup'] ?? 'Unknown Type';
                            final location = requirement['location'] ?? 'Unknown Location';

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      donationType,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Requested by: $requesterName',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Location: $location',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                      ],
                    );
                  },
                );
              },
            ),
            // Tab 2: Blood Donations
            StreamBuilder<List<Blood>>(
              stream: OrganLS.fetchBloodDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No blood donors found.'));
                }

                final bloodList = snapshot.data!;

                return ListView.builder(
                  itemCount: bloodList.length,
                  itemBuilder: (context, index) {
                    final bloodDonor = bloodList[index];
                    final donorName = bloodDonor.donorName;
                    final bloodType = bloodDonor.bloodGroup;
                    final location = bloodDonor.location;

                    return InkWell(
                      onTap:() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BloodDonorDetailsScreen(
                              donorName: bloodDonor.donorName,
                              age: bloodDonor.age.toString(),
                              weight: bloodDonor.weight.toString(),
                              bloodGroup: bloodDonor.bloodGroup,
                              contactNumber: bloodDonor.contactNumber,
                              medicalHistory: bloodDonor.medicalHistory,
                              allergies: bloodDonor.allergies,
                              lastDonationDate: bloodDonor.lastDonationDate,
                              preferredDonationType: bloodDonor.preferredDonationType,
                              location: bloodDonor.location,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bloodType,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Provided by: $donorName',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Location: $location',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            // Tab 3: Organ Donations
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('organs').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No organs found.'));
                }

                final organList = snapshot.data!.docs.map((doc) {
                  return doc.data() as Map<String, dynamic>;
                }).toList();

                return ListView.builder(
                  itemCount: organList.length,
                  itemBuilder: (context, index) {
                    final organ = organList[index];
                    final organName = organ['organName'] ?? 'Unknown Organ';
                    final location = organ['location'] ?? 'Unknown Location';

                    return InkWell(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => OrganDonorDetailsScreen(
                        //       donorName: organ['donorName'] ?? 'Unknown Donor',
                        //       organName: organ['organName'] ?? 'Unknown Organ',
                        //       contactNumber: organ['contactNumber'] ?? 'No Contact Number',
                        //       bloodGroup: organ['bloodGroup'] ?? 'Unknown Blood Group',
                        //       hospitalName: organ['hospitalName'] ?? 'Unknown Hospital',
                        //       isAvailable: organ['isAvailable'] ?? false,
                        //       age: organ['age'] ?? 0,  // Use default 0 if null
                        //       weight: organ['weight'] ?? 0,  // Use default 0 if null
                        //       height: organ['height'] ?? 0,  // Use default 0 if null
                        //       gender: organ['gender'] ?? 'Unknown Gender',
                        //       id: organ['id'] ?? 'Unknown ID',
                        //       email: organ['email'] ?? 'No Email',
                        //       medicalHistory: organ['medicalHistory'] ?? 'No Medical History',
                        //       allergies: organ['allergies'] ?? 'No Allergies',
                        //       reason: organ['reason'] ?? 'No Reason Provided',
                        //       nextOfKin: organ['nextOfKin'] ?? 'No Next of Kin',
                        //       lastSurgery: organ['lastSurgery'] ?? DateTime.now(),  // Use current date if null
                        //       lifestyleInfo: organ['lifestyleInfo'] ?? 'No Lifestyle Info',
                        //       specialInstructions: organ['specialInstructions'] ?? 'No Special Instructions',
                        //       location: organ['location'] ?? 'Unknown Location',
                        //     ),
                        //   ),
                        // );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                organ['organName'] ?? 'Unknown Organ',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Provided by: ${organ['donorName'] ?? 'Unknown Donor'}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Location: ${organ['location'] ?? 'Unknown Location'}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
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
