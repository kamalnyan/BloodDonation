import 'package:flutter/material.dart';

class OrganDonorDetailsScreen extends StatelessWidget {
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
  final String lastSurgery;
  final String lifestyleInfo;
  final String specialInstructions;
  final String location;

  const OrganDonorDetailsScreen({
    Key? key,
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Organ Donor Details'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Donor Information'),
            _buildDetailCard('Name', donorName),
            _buildDetailCard('Age', age.toString()),
            _buildDetailCard('Gender', gender),
            _buildDetailCard('Blood Group', bloodGroup),
            _buildDetailCard('Contact Number', contactNumber),
            _buildDetailCard('Email', email),
            _buildDetailCard('Location', location),

            SizedBox(height: 20.0),
            _buildSectionHeader('Organ Information'),
            _buildDetailCard('Organ Name', organName),
            _buildDetailCard('Availability', isAvailable ? 'Available' : 'Not Available'),
            _buildDetailCard('Reason', reason),
            _buildDetailCard('Hospital', hospitalName),

            SizedBox(height: 20.0),
            _buildSectionHeader('Medical History'),
            _buildDetailCard('Medical History', medicalHistory),
            _buildDetailCard('Allergies', allergies),
            _buildDetailCard('Last Surgery', lastSurgery),

            SizedBox(height: 20.0),
            _buildSectionHeader('Additional Information'),
            _buildDetailCard('Next of Kin', nextOfKin),
            _buildDetailCard('Lifestyle Info', lifestyleInfo),
            _buildDetailCard('Special Instructions', specialInstructions),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.green[700],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String value) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value),
      ),
    );
  }
}
