import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Apis/location.dart';
import '../Apis/loginApis.dart';
import '../helper/customTextfield.dart';

class AddOrganScreen extends StatefulWidget {
  @override
  _AddOrganScreenState createState() => _AddOrganScreenState();
}

class _AddOrganScreenState extends State<AddOrganScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _donorNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _bloodGroupController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _medicalHistoryController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _organNameController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _hospitalNameController = TextEditingController();
  final TextEditingController _nextOfKinController = TextEditingController();
  final TextEditingController _lastSurgeryController = TextEditingController();
  final TextEditingController _lifestyleInfoController = TextEditingController();
  final TextEditingController _specialInstructionsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  bool _isAvailable = true;
  bool _isLoading = false;
  bool _isConsentGiven = false;
  List<Map<String, dynamic>> _searchResults = [];
  void _showLocationSearch() async {
    // Show the bottom sheet immediately
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.6,  // Adjust height to make it non-fullscreen
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
                                      _locationController.text = location['name']!;
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
                              title: Text(currentLocation['locality'] ?? 'Unknown'),
                              subtitle: Text(currentLocation['country'] ?? ''),
                              onTap: () {
                                setState(() {
                                  _locationController.text = currentLocation['locality']!;
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
  void _addOrgan() async {
    if (_formKey.currentState!.validate() && _isConsentGiven) {
      setState(() {
        _isLoading = true;
      });
      DateTime? lastSurgeryDate;
      if (_lastSurgeryController.text.isNotEmpty) {
        try {
          lastSurgeryDate = DateFormat('dd-MM-yyyy').parse(_lastSurgeryController.text);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid date format. Please use dd-MM-yyyy')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }
      await OrganLS.addOrganDetails(
            donorName:_donorNameController.text,
        age: _ageController.text,
        gender: _genderController.text,
        contactNumber: _contactNumberController.text,
        email: _emailController.text,
        id: _idController.text,
        bloodGroup:_bloodGroupController.text,
        weight: _weightController.text,
        height: _heightController.text,
        medicalHistory: _medicalHistoryController.text,
        allergies:_allergiesController.text,
        organName: _organNameController.text,
        reason: _reasonController.text,
        hospitalName: _hospitalNameController.text,
        isAvailable: _isAvailable,
        nextOfKin: _nextOfKinController.text,
        lastSurgery: lastSurgeryDate,
        lifestyleInfo: _lifestyleInfoController.text,
        specialInstructions: _specialInstructionsController.text,
        location:  _locationController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Organ details added successfully!')),
      );

      _formKey.currentState!.reset();
      setState(() {
        _isLoading = false;
        _isConsentGiven = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organ Donation Form'),
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
          padding: const EdgeInsets.only(top: 27.0,left: 16.0,right: 16.0,bottom: 16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildTextField(_donorNameController, 'Full Name', 'Please enter donor name',inputType: TextInputType.name),
                  buildTextField(_ageController, 'Age', 'Please enter age',inputType: TextInputType.number),
                  buildTextField(_genderController, 'Gender', 'Please specify gender'),
                  buildTextField(_contactNumberController, 'Contact Number', 'Please enter contact number',inputType: TextInputType.phone),
                  buildTextField(_emailController, 'Email (Optional)', null, required: false,inputType: TextInputType.emailAddress),

                  // Identification
                  buildTextField(_idController, 'National ID / Unique ID', 'Please enter ID',inputType: TextInputType.number),

                  // Medical Information
                  buildTextField(_bloodGroupController, 'Blood Group', 'Please enter blood group'),
                  buildTextField(_weightController, 'Weight', 'Please enter weight',inputType: TextInputType.number),
                  buildTextField(_heightController, 'Height', 'Please enter height',inputType: TextInputType.number),
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
                  const SizedBox(height: 20),
                  buildTextField(_medicalHistoryController, 'Medical History', 'Please enter medical history'),
                  buildTextField(_allergiesController, 'Allergies', 'Please specify any allergies'),

                  // Organ-Specific Details
                  buildTextField(_organNameController, 'Organ to Donate', 'Please specify organ'),
                  buildTextField(_reasonController, 'Reason for Donation (Optional)', null, required: false),
                  SwitchListTile(
                    title: const Text('Availability', style: TextStyle(color: Colors.white)),
                    value: _isAvailable,
                    onChanged: (bool value) {
                      setState(() {
                        _isAvailable = value;
                      });
                    },
                  ),
                  buildTextField(_hospitalNameController, 'Hospital Details', 'Please specify hospital'),
                  buildDatePickerTextField(context,_lastSurgeryController, 'Last Donation Date', 'Please enter the last donation date'),
                  // Legal and Consent
                  buildTextField(_nextOfKinController, 'Next of Kin / Emergency Contact', 'Please specify contact'),
                  CheckboxListTile(
                    title: const Text(
                      'I give my consent to donate my organ(s) as per the details provided.',
                      style: TextStyle(color: Colors.white),
                    ),
                    value: _isConsentGiven,
                    onChanged: (bool? value) {
                      setState(() {
                        _isConsentGiven = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    checkColor: Colors.black,
                    activeColor: Colors.yellow,
                  ),

                  // Additional Information
                  buildTextField(_lifestyleInfoController, 'Lifestyle Information (Optional)', null, required: false),
                  buildTextField(_specialInstructionsController, 'Any Special Instructions (Optional)', null, required: false),
                  if (_isLoading)
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                    ),
                  if (!_isLoading)
                    ElevatedButton(
                      onPressed: _addOrgan,
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
    _genderController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _idController.dispose();
    _bloodGroupController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _medicalHistoryController.dispose();
    _allergiesController.dispose();
    _organNameController.dispose();
    _reasonController.dispose();
    _hospitalNameController.dispose();
    _nextOfKinController.dispose();
    _lastSurgeryController.dispose();
    _lifestyleInfoController.dispose();
    _specialInstructionsController.dispose();
    super.dispose();
  }
}
