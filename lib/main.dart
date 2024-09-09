import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart'; // Import for autocomplete search
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // HTTP client package

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps with City Search',
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(7.8731, 80.7718);
  final Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();
  String _apiKey =
      'AIzaSyBvdWTRDRIKWd11ClIGYQrSfc883IEkRiw'; // Replace with your actual Google Maps API key

  @override
  void initState() {
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Function to search for a city and move the map
  Future<void> _searchCity(String cityName) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$cityName&inputtype=textquery&fields=geometry&key=$_apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['candidates'].isNotEmpty) {
        final location = data['candidates'][0]['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];

        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(lat, lng), 12),
        );

        setState(() {
          _markers.clear(); // Clear any existing markers
          _markers.add(Marker(
            markerId: MarkerId(cityName),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: cityName),
          ));
        });
      } else {
        print('City not found.');
      }
    } else {
      throw Exception('Failed to fetch city location');
    }
  }

  // Function to get suggestions from the Places API
  Future<List<String>> _getSuggestions(String query) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&types=(cities)&key=$_apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> suggestions = data['predictions'];
      return suggestions.map((item) => item['description'].toString()).toList();
    } else {
      print('Failed to fetch suggestions');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 7.0,
            ),
            markers: _markers,
          ),
          Positioned(
            top: 30.0,
            left: 10.0,
            right: 10.0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for a city...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search),
                  ),
                ),
                suggestionsCallback: (pattern) async {
                  return await _getSuggestions(pattern); // Fetch suggestions
                },
                onSuggestionSelected: (suggestion) {
                  _searchCity(
                      suggestion as String); // Search for the selected city
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion.toString()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
