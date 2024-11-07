import 'package:flutter/material.dart';

class OrganDonorDetailsScreen extends StatefulWidget {
  final String donorName;
  final String organName;
  final String contactNumber;
  final String bloodGroup;
  final String hospitalName;
  final bool isAvailable;
  final String age;
  final String weight;
  final String height;
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
  _OrganDonorDetailsScreenState createState() => _OrganDonorDetailsScreenState();
}

class _OrganDonorDetailsScreenState extends State<OrganDonorDetailsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeInAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Organ Donor Details"),
        backgroundColor: Colors.green[600],
      ),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildSectionTitle("Personal Information", Icons.person),
              _buildInfoRow("Name", widget.donorName),
              _buildInfoRow("Age", widget.age),
              _buildInfoRow("Gender", widget.gender),
              _buildInfoRow("Location", widget.location),
              const SizedBox(height: 20),
              _buildSectionTitle("Organ Details", Icons.health_and_safety),
              _buildInfoRow("Organ Name", widget.organName),
              _buildInfoRow("Availability", widget.isAvailable ? "Available" : "Not Available"),
              _buildInfoRow("Blood Group", widget.bloodGroup),
              _buildInfoRow("Hospital", widget.hospitalName),
              _buildInfoRow("Reason", widget.reason),
              const SizedBox(height: 20),
              _buildSectionTitle("Health Information", Icons.medical_services),
              _buildInfoRow("Weight", "${widget.weight} kg"),
              _buildInfoRow("Height", "${widget.height} cm"),
              _buildInfoRow("Medical History", widget.medicalHistory),
              _buildInfoRow("Allergies", widget.allergies),
              _buildInfoRow("Last Surgery", widget.lastSurgery),
              const SizedBox(height: 20),
              _buildSectionTitle("Additional Details", Icons.info),
              _buildInfoRow("Next of Kin", widget.nextOfKin),
              _buildInfoRow("Lifestyle Info", widget.lifestyleInfo),
              _buildInfoRow("Special Instructions", widget.specialInstructions),
              _buildInfoRow("Contact Number", widget.contactNumber),
              _buildInfoRow("Email", widget.email),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.green[700]),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}