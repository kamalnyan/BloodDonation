import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting DateTime

class BloodDonorDetailsScreen extends StatefulWidget {
  final String donorName;
  final String age;
  final String weight;
  final String bloodGroup;
  final String contactNumber;
  final String medicalHistory;
  final String allergies;
  final DateTime? lastDonationDate;
  final String preferredDonationType;
  final String location;

  const BloodDonorDetailsScreen({
    Key? key,
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
  }) : super(key: key);

  @override
  _BloodDonorDetailsScreenState createState() => _BloodDonorDetailsScreenState();
}

class _BloodDonorDetailsScreenState extends State<BloodDonorDetailsScreen> with SingleTickerProviderStateMixin {
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
        title: const Text("Donor Details"),
        backgroundColor: Colors.red[600],
      ),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildSectionTitle("Personal Information", Icons.person),
              _buildInfoRow("Donor Name", widget.donorName),
              _buildInfoRow("Age", widget.age),
              _buildInfoRow("Location", widget.location),
              const SizedBox(height: 20),
              _buildSectionTitle("Health Details", Icons.health_and_safety),
              _buildInfoRow("Weight", "${widget.weight} kg"),
              _buildInfoRow("Blood Group", widget.bloodGroup),
              _buildInfoRow("Medical History", widget.medicalHistory),
              _buildInfoRow("Allergies", widget.allergies),
              _buildInfoRow("Last Donation Date", widget.lastDonationDate != null ? DateFormat.yMMMd().format(widget.lastDonationDate!) : "No recent donations"),
              const SizedBox(height: 20),
              _buildSectionTitle("Donation Preferences", Icons.favorite),
              _buildInfoRow("Preferred Donation Type", widget.preferredDonationType),
              _buildInfoRow("Contact Number", widget.contactNumber),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build section titles with icons
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.red[700]),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red[700],
          ),
        ),
      ],
    );
  }

  // Helper function to build each information row
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
