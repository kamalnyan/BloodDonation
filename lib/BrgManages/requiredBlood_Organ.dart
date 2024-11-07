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
  double? _selectedLatitude;
  double? _selectedLongitude;
  void _showLocationSearch() async {
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
                                Text('Fetching current location...'),
                              ],
                            ),
                          ),
                          // Show other search results if available
                          Expanded(
                            child: ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final location = _searchResults[index];
                                final locationName =
                                    location['name'] ?? 'Unknown';
                                final description =
                                    location['description'] ?? '';
                                final latitude = location['latitude'];
                                final longitude = location['longitude'];

                                return ListTile(
                                  title: Text(locationName),
                                  subtitle: Text(description),
                                  onTap: () {
                                    // Save name, latitude, and longitude
                                    setState(() {
                                      _locationController.text = locationName;
                                      _selectedLatitude =
                                          double.tryParse(latitude ?? '0.0') ??
                                              0.0;
                                      _selectedLongitude =
                                          double.tryParse(longitude ?? '0.0') ??
                                              0.0;
                                    });

                                    // Debugging logs
                                    print('Selected Location: $locationName');
                                    print(
                                        'Latitude: $_selectedLatitude, Longitude: $_selectedLongitude');

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
                                // Save current location details
                                setState(() {
                                  _locationController.text =
                                      currentLocation['locality'] ?? 'Unknown';
                                  _selectedLatitude = double.tryParse(
                                      currentLocation['latitude'] ?? '0.0');
                                  _selectedLongitude = double.tryParse(
                                      currentLocation['longitude'] ?? '0.0');
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
                                // Save name, latitude, and longitude
                                setState(() {
                                  _locationController.text =
                                      location['name'] ?? 'Unknown';
                                  _selectedLatitude = double.tryParse(
                                      location['latitude'] ?? '0.0');
                                  _selectedLongitude = double.tryParse(
                                      location['longitude'] ?? '0.0');
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
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();

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
                DropdownButtonFormField<String>(
                  value: _genderController.text.isEmpty ? null : _genderController.text,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: ['Male', 'Female', 'Other']
                      .map((gender) => DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _genderController.text = value ?? '';
                    });
                  },
                  validator: (value) => value == null ? 'Please select a gender' : null,
                ),
                const SizedBox(height: 20),
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
                buildTextField(_contactController, 'Contact Number', 'Please enter contact number', inputType: TextInputType.phone),
                buildTextField(_hospitalController, 'Hospital Name(Optional)', 'Please enter  hospital name', inputType: TextInputType.phone,required: false),
                buildTextField(_urgencyController, 'Urgency Level', 'Please specify urgency level'),

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
                  buildDatePickerTextField(context,_requiredDateController, 'Required Date',
                      'Please enter the required date'),
                ],

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Show loading state
                      setState(() {
                        isLoading = true;
                      });

                      try {
                        if (isOragnRequest) {
                          // Upload organ details
                          await OrganLS.addOrganDetailsrequired(
                            donorName: _nameController.text,
                            age: _ageController.text,
                            organType: _organTypeController.text,
                            bloodGroup: _bloodGroupController.text,
                            contactNumber: _contactController.text,
                            hospitalName: _hospitalController.text,
                            gender: _genderController.text,
                            urgency: _urgencyController.text,
                            location: _locationController.text,
                            lat: _selectedLatitude,
                            logg: _selectedLongitude,
                            requiredDate: _requiredDateController.text,
                          );
                        } else {
                          // Upload blood details
                          await OrganLS.addBloodDetailsrequired(
                            donorName: _nameController.text,
                            age: _ageController.text,
                            bloodGroup: _bloodGroupController.text,
                            quantity: _quantityController.text,
                            hospitalName: _hospitalController.text.isEmpty?"N/A":_hospitalController.text,
                            gender: _genderController.text,
                            contactNumber: _contactController.text,
                            urgency: _urgencyController.text,
                            location: _locationController.text,
                            lat: _selectedLatitude,
                            logg: _selectedLongitude,
                          );
                        }
                        _formKey.currentState!.reset();
                        _nameController.clear();
                        _ageController.clear();
                        _locationController.clear();
                        _contactController.clear();
                        _urgencyController.clear();
                        _genderController.clear();
                        _hospitalController.clear();
                        _bloodGroupController.clear();
                        _quantityController.clear();
                        _organTypeController.clear();
                        _requiredDateController.clear();

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Request submitted successfully!')),
                        );
                      } catch (e) {
                        // Handle any errors during submission
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('An error occurred: $e')),
                        );
                      } finally {
                        // Hide loading state
                        setState(() {
                          isLoading = false;
                        });
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
                  child: isLoading
                      ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  )
                      : const Center(
                    child: Text(
                      'Done',
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
