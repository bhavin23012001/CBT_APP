import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui'; // For ImageFilter

class MapScreen extends StatefulWidget {
  final String source;
  final String destination;
  final String stopId;

  const MapScreen({required this.source, required this.destination, required this.stopId, Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  late MapController _mapController;
  double _zoomLevel = 12.0;
  Future<List<dynamic>>? _busStopsFuture;
  final String apiUrl = "http://54.236.128.72:3000/bus_stops";

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  bool _showControls = false;
  bool _showInfo = false;

  // Temporary current location coordinates
  LatLng _currentLocation = LatLng(23.042570043027094, 72.56609809467304);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _busStopsFuture = _fetchBusStops();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    // Setup staggered animations
    Future.delayed(Duration(milliseconds: 400), () {
      if (mounted) setState(() => _showInfo = true);
    });

    Future.delayed(Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showControls = true);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      _showErrorSnackbar("Could not load bus stops. Please check your connection.");
      return [];
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
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

  void _setCurrentLocation() {
    setState(() {
      _mapController.move(_currentLocation, _zoomLevel);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A237E), // Deep indigo
                  Color(0xFF303F9F), // Indigo
                  Color(0xFF3949AB), // Lighter indigo
                ],
              ),
            ),
          ),

          // Background pattern
          Opacity(
            opacity: 0.05,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/assets/images/pattern.png'),
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),

          // Main content with map
          SafeArea(
            child: FadeTransition(
              opacity: _fadeInAnimation,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 120.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button and title in a card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.indigo.shade700),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Text(
                            "Bus Stops Map",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.indigo.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    // Journey info card
                    AnimatedOpacity(
                      opacity: _showInfo ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                        transform: Matrix4.translationValues(
                            0, _showInfo ? 0 : 20, 0
                        ),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    "Journey Info",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              Divider(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "From: ${widget.source}",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Icon(Icons.circle, size: 8, color: Colors.green),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "To: ${widget.destination}",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Icon(Icons.circle, size: 8, color: Colors.red),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Map container
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: FutureBuilder<List<dynamic>>(
                          future: _busStopsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      "Loading bus stops...",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.white, size: 40),
                                    SizedBox(height: 8),
                                    Text(
                                      "No bus stops available",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _busStopsFuture = _fetchBusStops();
                                        });
                                      },
                                      icon: Icon(Icons.refresh),
                                      label: Text("Retry"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade700,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
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
                                      width: 120.0,
                                      height: 70.0,
                                      point: _currentLocation,
                                      builder: (ctx) => Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Colors.red.shade200, Colors.red.shade600],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(8.0),
                                              boxShadow: [
                                                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                              ],
                                            ),
                                            child: const Text(
                                              'Current Location',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 10,
                                                  spreadRadius: 1,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.location_on,
                                              color: Colors.red,
                                              size: 35,
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 10,
                                                  color: Colors.black38,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Markers for bus stops
                                    ...busStops.map((stop) {
                                      final isSource = stop['stop_name'] == widget.source;
                                      final isDestination = stop['stop_name'] == widget.destination;

                                      Color markerColor = Colors.blueGrey;
                                      IconData markerIcon = Icons.directions_bus;

                                      if (isSource) {
                                        markerColor = Colors.green;
                                        markerIcon = Icons.trip_origin;
                                      } else if (isDestination) {
                                        markerColor = Colors.red;
                                        markerIcon = Icons.location_on;
                                      }

                                      return Marker(
                                        width: 120.0,
                                        height: 80.0,
                                        point: LatLng(
                                            stop['coordinates']['coordinates'][1],
                                            stop['coordinates']['coordinates'][0]
                                        ),
                                        builder: (ctx) => Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: isSource
                                                      ? [Colors.green.shade100, Colors.green.shade500]
                                                      : isDestination
                                                      ? [Colors.red.shade100, Colors.red.shade500]
                                                      : [Colors.blue.shade100, Colors.blue.shade500],
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
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              markerIcon,
                                              color: markerColor,
                                              size: 25,
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 5,
                                                  color: Colors.black38,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom controls bar with glass effect
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: Duration(milliseconds: 800),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 800),
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(0, _showControls ? 0 : 20, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 15,
                            spreadRadius: 3,
                            offset: Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 3.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildControlButton(
                            label: "Zoom In",
                            icon: Icons.zoom_in,
                            onPressed: _zoomIn,
                            iconColor: Colors.blue.shade700,
                          ),
                          _buildControlButton(
                            label: "My Location",
                            icon: Icons.my_location,
                            onPressed: _setCurrentLocation,
                            iconColor: Colors.green.shade700,
                            isPrimary: true,
                          ),
                          _buildControlButton(
                            label: "Zoom Out",
                            icon: Icons.zoom_out,
                            onPressed: _zoomOut,
                            iconColor: Colors.blue.shade700,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Control Button Widget
  Widget _buildControlButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color iconColor,
    bool isPrimary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? iconColor.withOpacity(0.15)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: isPrimary
                      ? Border.all(color: iconColor.withOpacity(0.3), width: 1.5)
                      : null,
                  boxShadow: isPrimary
                      ? [
                    BoxShadow(
                      color: iconColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    )
                  ]
                      : null,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              SizedBox(height: 0),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isPrimary ? iconColor : Colors.black87,
                  fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
