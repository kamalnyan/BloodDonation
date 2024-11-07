import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Apis/location.dart';
import '../Apis/loginApis.dart';
import '../helper/customTextfield.dart';

class RequestScreen extends StatefulWidget {
  @override
  _RequestScreenState createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  bool isLoading = false;
  bool isOragnRequest = false; // Toggle state
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _searchResults = [];
  void _showLocationSearch() async {
    // Show the bottom sheet immediately
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.6, // Adjust height to make it non-fullscreen
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CupertinoSearchTextField(
                  placeholder: 'Search location',
                  onChanged: (query) async {
                    if (query.isNotEmpty) {
                      final results = await fetchLocationSuggestions(query);
                      setState(() {
                        _searchResults = results;
                      });
                    } else {
                      setState(() {
                        _searchResults = [];
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<Map<String, String>?>(
                  future: fetchLocation(), // Fetch the current location
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      // Show loading for current location
                      return Column(
                        children: [
                          const ListTile(
                            title: Row(
                              children: [
                                CupertinoActivityIndicator(),
                                SizedBox(width: 8),
                                Text('Fetching current location...')
                              ],
                            ),
                          ),
                          // Show other search results if available
                          Expanded(
                            child: ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final location = _searchResults[index];
                                return ListTile(
                                  title: Text(location['name'] ?? 'Unknown'),
                                  subtitle: Text(location['description'] ?? ''),
                                  onTap: () {
                                    setState(() {
                                      _locationController.text =
                                          location['name']!;
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Display fetched current location
                      final currentLocation = snapshot.data!;
                      return ListView.builder(
                        itemCount: _searchResults.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return ListTile(
                              title: Text(
                                  currentLocation['locality'] ?? 'Unknown'),
                              subtitle: Text(currentLocation['country'] ?? ''),
                              onTap: () {
                                setState(() {
                                  _locationController.text =
                                      currentLocation['locality']!;
                                });
                                Navigator.pop(context);
                              },
                            );
                          } else {
                            final location = _searchResults[index - 1];
                            return ListTile(
                              title: Text(location['name'] ?? 'Unknown'),
                              subtitle: Text(location['description'] ?? ''),
                              onTap: () {
                                setState(() {
                                  _locationController.text = location['name']!;
                                });
                                Navigator.pop(context);
                              },
                            );
                          }
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Controllers for shared fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _urgencyController = TextEditingController();

  // Controllers for blood-specific fields
  final TextEditingController _bloodGroupController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  // Controllers for organ-specific fields
  final TextEditingController _organTypeController = TextEditingController();
  final TextEditingController _requiredDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isOragnRequest ? 'Required Organ' : 'Required Blood'),
        backgroundColor: Colors.yellow,
        actions: [
          const Text("Organ", style: TextStyle(fontSize: 17)),
          const SizedBox(
            width: 6.0,
          ),
          Switch(
            value: isOragnRequest,
            onChanged: (value) {
              setState(() {
                isOragnRequest = value;
              });
            },
          ),
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(children: [
                const SizedBox(height: 20),

                // Common fields
                buildTextField(
                    _nameController, 'Name', 'Please enter your name'),
                buildTextField(_ageController, 'Age', 'Please enter age',
                    inputType: TextInputType.number),
                TextFormField(
                  controller: _locationController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Location",
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onTap: _showLocationSearch,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                buildTextField(_contactController, 'Contact Number',
                    'Please enter contact number',
                    inputType: TextInputType.phone),
                buildTextField(_urgencyController, 'Urgency Level',
                    'Please specify urgency level'),

                // Blood-specific fields
                if (!isOragnRequest) ...[
                  buildTextField(_bloodGroupController, 'Blood Group',
                      'Please enter blood group'),
                  buildTextField(_quantityController, 'Quantity Needed',
                      'Please enter quantity',
                      inputType: TextInputType.number),
                ],

                // Organ-specific fields
                if (isOragnRequest) ...[
                  buildTextField(_organTypeController, 'Organ Type',
                      'Please specify organ type'),
                  buildTextField(_bloodGroupController,
                      'Blood Group (if applicable)', null),
                  buildTextField(_requiredDateController, 'Required Date',
                      'Please enter the required date'),
                ],

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (isOragnRequest) {
                        // Upload organ details
                        OrganLS.addOrganDetailsrequired(
                          donorName: _nameController.text,
                          organType: _organTypeController.text,
                          bloodGroup: _bloodGroupController.text,
                          contactNumber: _contactController.text,
                          urgency: _urgencyController.text,
                          location: _locationController.text,
                          requiredDate: _requiredDateController.text,
                        );
                      } else {
                        // Upload blood details
                        OrganLS.addBloodDetailsrequired(
                          donorName: _nameController.text,
                          age: _ageController.text,
                          bloodGroup: _bloodGroupController.text,
                          quantity: _quantityController.text,
                          contactNumber: _contactController.text,
                          urgency: _urgencyController.text,
                          location: _locationController.text,
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.yellow,
                  ),
                  child: const Center(
                    child: Text(
                      'Submit Donation',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    _urgencyController.dispose();
    _bloodGroupController.dispose();
    _quantityController.dispose();
    _organTypeController.dispose();
    _requiredDateController.dispose();
    super.dispose();
  }
}
