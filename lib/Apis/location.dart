
import 'dart:convert';
import 'dart:developer';

import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;
// Fetch current location coordinates and details
Future<Map<String, String>?> fetchLocation() async {
  try {
    final loc.Location location = loc.Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return null;
    }

    loc.PermissionStatus permissionStatus = await location.hasPermission();
    if (permissionStatus == loc.PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != loc.PermissionStatus.granted) return null;
    }

    final loc.LocationData locationData = await location.getLocation();
    final double? latitude = locationData.latitude;
    final double? longitude = locationData.longitude;
    log("Latitude: $latitude, Longitude: $longitude");

    if (latitude != null && longitude != null) {
      final placemarks = await getLocationDetails(latitude, longitude);
      if (placemarks != null) return placemarks;
    }
  } catch (e) {
    print("Error fetching location: $e");
  }
  return null;
}
// Fetch location details from OpenStreetMap API
Future<Map<String, String>?> getLocationDetails(double latitude, double longitude) async {
  final url = Uri.parse(
    'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude',
  );

  try {
    final response = await http.get(url, headers: {'User-Agent': 'GlobeGaze/1.0 (uic.23mca20237@gmail.com)'});
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final locality = data['address']['city'] ?? data['address']['town'] ?? data['address']['village'] ?? 'Unknown';
      final country = data['address']['country'] ?? 'Unknown';
      return {
        'locality': locality,
        'country': country,
      };
    } else {
      print("Failed to fetch location details. Status code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error fetching location data: $e");
  }
  return null;
}
// Fetch location suggestions based on user input using OpenStreetMap Nominatim API
Future<List<Map<String, String>>> fetchLocationSuggestions(String query) async {
  final url = Uri.parse(
    'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5',
  );

  try {
    final response = await http.get(url, headers: {'User-Agent': 'GlobeGaze/1.0 (uic.23mca20237@gmail.com)'});
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map<Map<String, String>>((location) {
        final displayName = location['display_name'] ?? 'Unknown';
        final address = location['address'] ?? {};
        final description = [
          address['city'] ?? address['town'] ?? address['village'] ?? '',
          address['country'] ?? ''
        ].where((element) => element.isNotEmpty).join(', ');
        return {'name': displayName, 'description': description};
      }).toList();
    } else {
      print("Failed to fetch search results. Status code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error fetching search results: $e");
  }
  return [];
}