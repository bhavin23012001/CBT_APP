import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  final String source;
  final String destination;

  MapScreen({required this.source, required this.destination});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Position? _currentPosition;
  late MapController _mapController;
  bool _isLoading = true;

  // List of stops
  final List<Map<String, dynamic>> stops = [
    {"name": "Ahmedabad Central Bus Station", "latitude": 23.015517, "longitude": 72.591825},
    {"name": "Ahmedabad Railway Station", "latitude": 23.025793, "longitude": 72.607486},
    {"name": "Astodia Chakla", "latitude": 23.015883, "longitude": 72.578463},
    {"name": "Astodia Darwaja", "latitude": 23.017275, "longitude": 72.578981},
    {"name": "Bhadar Laldarwaja", "latitude": 23.018607, "longitude": 72.581239},
    {"name": "Bijli Ghar", "latitude": 23.033719, "longitude": 72.608917},
    {"name": "Civil Hospital", "latitude": 23.048002, "longitude": 72.594285},
    // Add other stops as needed...
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    try {
      // Use medium accuracy to improve performance
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      // Move the map to the current location
      if (_currentPosition != null) {
        _mapController.move(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          15.0,
        );
      }
    } catch (e) {
      print("Error fetching location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch location. Using default location.'),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map Screen"),
        backgroundColor: Colors.indigoAccent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: _currentPosition != null
              ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
              : LatLng(23.0225, 72.5714), // Default center
          zoom: 14.0,
          minZoom: 10.0,
          maxZoom: 18.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'], // Default tile provider
          ),
          MarkerLayer(
            markers: [
              if (_currentPosition != null)
                Marker(
                  width: 40.0,
                  height: 40.0,
                  point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                  builder: (ctx) => Icon(Icons.my_location, color: Colors.red, size: 30),
                ),
              ...stops.map((stop) => Marker(
                width: 40.0,
                height: 40.0,
                point: LatLng(stop['latitude'], stop['longitude']),
                builder: (ctx) => Icon(Icons.location_on, color: Colors.blue, size: 30),
              )),
            ],
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: stops
                    .map((stop) => LatLng(stop['latitude'], stop['longitude']))
                    .toList(),
                strokeWidth: 4.0,
                color: Colors.blueAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
