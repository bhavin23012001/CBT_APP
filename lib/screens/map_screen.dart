import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  final String source;
  final String destination;
  final String stopId;

  const MapScreen({required this.source, required this.destination, required this.stopId, Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController _mapController;
  double _zoomLevel = 12.0;
  Future<List<dynamic>>? _busStopsFuture;
  final String apiUrl = "http://54.236.128.72:3000/bus_stops";

  // Temporary current location coordinates
  LatLng _currentLocation = LatLng(23.042570043027094, 72.56609809467304);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _busStopsFuture = _fetchBusStops();
  }

  Future<List<dynamic>> _fetchBusStops() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load bus stops');
      }
    } catch (e) {
      print('Error fetching bus stops: $e');
      return [];
    }
  }

  void _zoomIn() {
    setState(() {
      if (_zoomLevel < 18.0) {
        _zoomLevel++;
        _mapController.move(_mapController.center, _zoomLevel);
      }
    });
  }

  void _zoomOut() {
    setState(() {
      if (_zoomLevel > 5.0) {
        _zoomLevel--;
        _mapController.move(_mapController.center, _zoomLevel);
      }
    });
  }

  // Function to set current location on map
  void _setCurrentLocation() {
    setState(() {
      _mapController.move(_currentLocation, _zoomLevel);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FutureBuilder<List<dynamic>>(
            future: _busStopsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
                return const Center(child: Text("No bus stops available"));
              }

              final busStops = snapshot.data!;
              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(center: _currentLocation, zoom: _zoomLevel),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      // Marker for the current location with red color
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: _currentLocation,
                        builder: (ctx) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.red.shade500, // Red color for current location
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                ],
                              ),
                              child: const Text(
                                'Current Location',
                                style: TextStyle(color: Colors.black38, fontSize: 12.0, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Icon(Icons.location_on, color: Colors.red, size: 35), // Red location icon
                          ],
                        ),
                      ),
                      // Marker for bus stops
                      ...busStops.map((stop) {
                        return Marker(
                          width: 80.0,
                          height: 80.0,
                          point: LatLng(stop['coordinates']['coordinates'][1], stop['coordinates']['coordinates'][0]),
                          builder: (ctx) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.blue.shade100, Colors.blue.shade500],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                  ],
                                ),
                                child: Text(
                                  stop['stop_name'],
                                  style: const TextStyle(color: Colors.black54, fontSize: 12.0, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Icon(Icons.directions_bus, color: Colors.blueGrey, size: 24),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 30.0,
            right: 20.0,
            child: Column(
              children: [
                _buildModernButton(
                  icon: Icons.zoom_in,
                  onPressed: _zoomIn,
                  colors: [Colors.blue.shade500, Colors.white38],
                ),
                const SizedBox(height: 10),
                _buildModernButton(
                  icon: Icons.zoom_out,
                  onPressed: _zoomOut,
                  colors: [Colors.blue.shade500, Colors.white38],
                ),
                const SizedBox(height: 10),
                _buildModernButton(
                  icon: Icons.my_location,
                  onPressed: _setCurrentLocation,
                  colors: [Colors.green.shade500, Colors.white38],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernButton({
    required IconData icon,
    required VoidCallback onPressed,
    required List<Color> colors,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
