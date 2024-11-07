import 'package:flutter/material.dart';

class Requireddetails extends StatefulWidget {
  final String donorName;
  final String? organName;
  final String contactNumber;
  final String bloodGroup;
  final String? hospitalName;
  final String age;
  final String gender;
  final String? location;
  final String? quantity;
  final String urgency;
  final String? requiredDate;
  final bool isOragnRequest;

  const Requireddetails({
    Key? key,
    required this.donorName,
    required this.contactNumber,
    required this.bloodGroup,
    required this.hospitalName,
    required this.age,
    required this.gender,
    required this.urgency,
    required this.isOragnRequest,
    this.organName,
    this.quantity,
    this.requiredDate,
    this.location,
    required String weight,
  }) : super(key: key);

  @override
  _OrganDonorDetailsScreenState createState() => _OrganDonorDetailsScreenState();
}

class _OrganDonorDetailsScreenState extends State<Requireddetails> with SingleTickerProviderStateMixin {
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
              _buildInfoRow("Contact Number", widget.contactNumber),
              _buildInfoRow("Gender", widget.gender),
              _buildInfoRow("Location", widget.location??"N/A"),
              const SizedBox(height: 20),
              if (widget.isOragnRequest) ...[
                _buildSectionTitle("Organ Details", Icons.health_and_safety),
                _buildInfoRow("Organ Type", widget.organName??"N/A"),
                _buildInfoRow("Blood Group", widget.bloodGroup),
                _buildInfoRow("Required Date", widget.requiredDate??"N/A"),
              ],
              if(!widget.isOragnRequest)...[
                _buildSectionTitle("Blood Details", Icons.health_and_safety),
                _buildInfoRow("Blood Group", widget.bloodGroup),
                _buildInfoRow("Quantity Needed", widget.quantity??"N/A"),
              ],
              _buildInfoRow("Hospital", widget.hospitalName??"N/A"),
              _buildInfoRow("Urgency Level", widget.urgency),
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
