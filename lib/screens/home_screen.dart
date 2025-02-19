import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'map_screen.dart';  // Assuming MapScreen exists
import 'RouteScreen.dart';  // Assuming RouteScreen exists

class BusStop {
  final String name;
  final double latitude;
  final double longitude;

  BusStop({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BusStop? _selectedSource;
  BusStop? _selectedDestination;
  List<BusStop> busStops = [];
  bool _isLoading = true;
  final String apiUrl = "http://10.0.2.2:3000/bus_stops"; // Replace with your API URL

  @override
  void initState() {
    super.initState();
    _fetchBusStops();
  }

  Future<void> _fetchBusStops() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          busStops = data.map<BusStop>((stop) {
            return BusStop(
              name: stop['stop_name'],
              latitude: stop['coordinates']['coordinates'][1],
              longitude: stop['coordinates']['coordinates'][0],
            );
          }).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load bus stops');
      }
    } catch (e) {
      print('Error fetching bus stops: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToRouteScreen() {
    if (_selectedSource != null && _selectedDestination != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(
            source: _selectedSource!.name,
            destination: _selectedDestination!.name,
            stopId: _selectedSource!.name, // You can use the stop name or modify as needed
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select both source and destination")),
      );
    }
  }

  void _findRoute() {
    if (_selectedSource != null && _selectedDestination != null){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TripsRoutesPage(
            // source: _selectedSource!.name,
            // destination: _selectedDestination!.name,
            // stopId: _selectedSource!.name, // You can use the stop name or modify as needed
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select both source and destination")),
      );
    }
  }

  void _showMapImage() {
    // Logic for displaying a map image (could be a route map, static map, etc.)
    print("Showing map image...");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with modern overlay
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/images/d.jpg'),  // Replace with your image path
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.6),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'City Bus Transport',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Ahmedabad City Travel Made Easy',
                    style: TextStyle(fontSize: 18, color: Colors.black.withOpacity(0.7)),
                  ),
                  SizedBox(height: 40),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Column(
                    children: [
                      // Source Dropdown
                      _buildDropdownButton(
                        hint: "Select Source Location",
                        value: _selectedSource,
                        onChanged: (BusStop? newValue) {
                          setState(() {
                            _selectedSource = newValue;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      // Destination Dropdown
                      _buildDropdownButton(
                        hint: "Select Destination Location",
                        value: _selectedDestination,
                        onChanged: (BusStop? newValue) {
                          setState(() {
                            _selectedDestination = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 6,
            right: 6,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3), // Semi-transparent background
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20, // Increased blur for a soft shadow effect
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(width: 2),
                  // Adjusted width for each button
                  Flexible(
                    child: _buildModernButton(
                      label: "View Stops",
                      icon: Icons.location_on,
                      onPressed: _navigateToRouteScreen,
                      gradient: LinearGradient(
                        colors: [Colors.red.shade400, Colors.white38],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  SizedBox(width: 2), // Added space between buttons
                  Flexible(
                    child: _buildModernButton(
                      label: "Find Route",
                      icon: Icons.directions_bus,
                      onPressed: _findRoute,
                      gradient: LinearGradient(
                        colors: [Colors.redAccent.shade100, Colors.redAccent.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  SizedBox(width: 2), // Added space between buttons
                  Flexible(
                    child: _buildModernButton(
                      label: "Map",
                      icon: Icons.map,
                      onPressed: _showMapImage,
                      gradient: LinearGradient(
                        colors: [Colors.red.shade100, Colors.white38],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  SizedBox(width: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dropdown Button Widget
  Widget _buildDropdownButton({
    required String hint,
    BusStop? value,
    required void Function(BusStop?) onChanged,
  }) {
    return DropdownButton<BusStop>(
      hint: Text(
        hint,
        style: TextStyle(color: Colors.black),
      ),
      dropdownColor: Colors.white,
      value: value,
      isExpanded: true,
      icon: Icon(Icons.location_on, color: Colors.black),
      style: TextStyle(color: Colors.black),
      onChanged: onChanged,
      items: busStops.map<DropdownMenuItem<BusStop>>((BusStop stop) {
        return DropdownMenuItem<BusStop>(value: stop, child: Text(stop.name));
      }).toList(),
    );
  }

  // Modern button with gradient, shadows, etc.
  Widget _buildModernButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required LinearGradient gradient,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 100,
        height: 60,
        decoration: BoxDecoration(
          gradient: gradient,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              SizedBox(height: 4),
              Text(label, style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
