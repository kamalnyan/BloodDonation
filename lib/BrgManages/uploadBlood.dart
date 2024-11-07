import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Apis/location.dart';
import '../Apis/loginApis.dart';
import '../helper/customTextfield.dart';

class AddBloodDonationScreen extends StatefulWidget {
  @override
  _AddDonationScreenState createState() => _AddDonationScreenState();
}

class _AddDonationScreenState extends State<AddBloodDonationScreen> {
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

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _donorNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _bloodGroupController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _medicalHistoryController =
      TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _lastDonationDateController =
      TextEditingController();
  final TextEditingController _preferredDonationTypeController =
      TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _consentGiven = false;
  bool _isAvailable = true;
  bool _isLoading = false;

  void _submitDonationForm() async {
    if (_formKey.currentState!.validate() && _consentGiven) {
      setState(() {
        _isLoading = true;
      });
      DateTime? lastDonationDate;
      if (_lastDonationDateController.text.isNotEmpty) {
        try {
          lastDonationDate =
              DateFormat('dd-MM-yyyy').parse(_lastDonationDateController.text);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Invalid date format. Please use dd-MM-yyyy')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }
      await OrganLS.addBloodDetails(
        donorName: _donorNameController.text,
        age: _ageController.text,
        weight: _weightController.text,
        bloodGroup: _bloodGroupController.text,
        contactNumber: _contactNumberController.text,
        medicalHistory: _medicalHistoryController.text,
        allergies: _allergiesController.text,
        lastDonationDate: lastDonationDate,
        preferredDonationType: _preferredDonationTypeController.text,
        location: _locationController.text,
        lat: _selectedLatitude,
        logg: _selectedLongitude,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation details added successfully!')),
      );
      _formKey.currentState!.reset();
      _donorNameController.clear();
      _ageController.clear();
      _weightController.clear();
      _bloodGroupController.clear();
      _contactNumberController.clear();
      _medicalHistoryController.clear();
      _allergiesController.clear();
      _preferredDonationTypeController.clear();
      _locationController.clear();
      setState(() {
        lastDonationDate = null;
        _isLoading = false;
      });
    } else if (!_consentGiven) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must give consent to proceed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Donation Form'),
        backgroundColor: Colors.yellow,
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
              child: Column(
                children: [
                  // Using _buildTextField for each field
                  buildTextField(_donorNameController, 'Full Name',
                      'Please enter your name'),
                  buildTextField(_ageController, 'Age', 'Please enter your age',
                      inputType: TextInputType.number),
                  buildTextField(_weightController, 'Weight (kg)',
                      'Please enter your weight',
                      inputType: TextInputType.number),

                  // Location field with onTap for showing the bottom sheet
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
                  buildTextField(_bloodGroupController, 'Blood Group',
                      'Please enter blood group'),
                  buildTextField(_contactNumberController, 'Contact Number',
                      'Please enter contact number',
                      inputType: TextInputType.phone),
                  buildTextField(_medicalHistoryController,
                      'Medical History (Optional)', null,
                      required: false),
                  buildTextField(
                      _allergiesController, 'Allergies (if any)', null,
                      required: false),
                  buildDatePickerTextField(
                      context,
                      _lastDonationDateController,
                      'Last Donation Date (Optional)',
                      'Please enter the last donation date',
                      required: false),
                  buildTextField(_preferredDonationTypeController,
                      'Preferred Donation Type (Optional)', null,
                      required: false),

                  const SizedBox(height: 20),
                  CheckboxListTile(
                    title: const Text('I consent to donate and agree to terms',
                        style: TextStyle(color: Colors.white)),
                    value: _consentGiven,
                    onChanged: (bool? value) {
                      setState(() {
                        _consentGiven = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  if (_isLoading)
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                    ),
                  if (!_isLoading)
                    ElevatedButton(
                      onPressed: _submitDonationForm,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _donorNameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _bloodGroupController.dispose();
    _contactNumberController.dispose();
    _medicalHistoryController.dispose();
    _allergiesController.dispose();
    _lastDonationDateController.dispose();
    _preferredDonationTypeController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
