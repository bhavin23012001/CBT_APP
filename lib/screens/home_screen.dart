import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui'; // For ImageFilter
import 'map_screen.dart';
import 'RouteScreen.dart';

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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  BusStop? _selectedSource;
  BusStop? _selectedDestination;
  List<BusStop> busStops = [];
  bool _isLoading = true;
  final String apiUrl = "http://54.236.128.72:3000/bus_stops";
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation = AlwaysStoppedAnimation(0.0);

  // Individual animations for staggered effect
  bool _showContent = false;
  bool _showBottomBar = false;

  @override
  void initState() {
    super.initState();
    _fetchBusStops();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    // Assign the animation properly after controller is initialized
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    // Setup staggered animations with Future.delayed
    Future.delayed(Duration(milliseconds: 400), () {
      if (mounted) setState(() => _showContent = true);
    });

    Future.delayed(Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showBottomBar = true);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      _showErrorSnackbar("Could not load bus stops. Please check your connection.");
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
            stopId: _selectedSource!.name,
          ),
        ),
      );
    } else {
      _showErrorSnackbar("Please select both source and destination");
    }
  }

  void _findRoute() {
    if (_selectedSource != null && _selectedDestination != null) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => TripsRoutesPage(
            selectedSource: _selectedSource!.name,
            selectedDestination: _selectedDestination!.name,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.ease;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    } else {
      _showErrorSnackbar("Please select both source and destinationPlease select both source and destinationPlease select both source and destinationPlease select both source and destinationPlease select both source and destinationPlease select both source and destinationPlease select both source and destinationPlease select both source and destination");
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

  void _showMapImage() {
    print("Showing map image...");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Map view coming soon!"),
        backgroundColor: Colors.blue.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _swapLocations() {
    setState(() {
      final temp = _selectedSource;
      _selectedSource = _selectedDestination;
      _selectedDestination = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          SafeArea(
            child: FadeTransition(
              opacity: _fadeInAnimation,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 90.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Logo with shadow and animation - made smaller
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: Duration(milliseconds: 800),
                          curve: Curves.elasticOut,
                          builder: (context, double value, child) {
                            return Transform.scale(
                              scale: value,
                              child: child,
                            );
                          },
                          child: Hero(
                            tag: 'app_logo',
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'lib/assets/images/re.png',
                                width: 120,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Main content
                    Expanded(
                      child: _isLoading
                          ? Center(
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
                      )
                          : AnimatedOpacity(
                        opacity: _showContent ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 800),
                          curve: Curves.easeOut,
                          transform: Matrix4.translationValues(
                              0,
                              _showContent ? 0 : 30,
                              0
                          ),
                          child: Column(
                            children: [
                              // Source Location Card
                              _buildLocationCard(
                                title: "Source",
                                icon: Icons.trip_origin,
                                iconColor: Colors.green,
                                child: _buildDropdownButton(
                                  hint: "Select source location",
                                  value: _selectedSource,
                                  onChanged: (BusStop? newValue) {
                                    setState(() {
                                      _selectedSource = newValue;
                                    });
                                  },
                                ),
                              ),

                              // Swap button
                              Center(
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.swap_vert, color: Colors.blue.shade700),
                                    onPressed: _swapLocations,
                                    tooltip: "Swap locations",
                                    padding: EdgeInsets.all(8),
                                    constraints: BoxConstraints(),
                                    iconSize: 20,
                                  ),
                                ),
                              ),

                              // Destination Location Card
                              _buildLocationCard(
                                title: "Destination",
                                icon: Icons.location_on,
                                iconColor: Colors.red,
                                child: _buildDropdownButton(
                                  hint: "Select destination location",
                                  value: _selectedDestination,
                                  onChanged: (BusStop? newValue) {
                                    setState(() {
                                      _selectedDestination = newValue;
                                    });
                                  },
                                ),
                              ),

                              // Travel info section - made more compact
                              if (_selectedSource != null && _selectedDestination != null)
                                Container(
                                  margin: EdgeInsets.only(top: 16),
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
                                          Icon(Icons.info_outline,
                                              color: Colors.blue.shade700, size: 16),
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
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("From: ${_selectedSource!.name}",
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Icon(Icons.circle, size: 8,
                                              color: Colors.green),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("To: ${_selectedDestination!.name}",
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Icon(Icons.circle, size: 8,
                                              color: Colors.red),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Navigation Bar with glass effect
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: AnimatedOpacity(
              opacity: _showBottomBar ? 1.0 : 0.0,
              duration: Duration(milliseconds: 800),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 800),
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(
                    0,
                    _showBottomBar ? 0 : 20,
                    0
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNavigationButton(
                            label: "View Stops",
                            icon: Icons.pin_drop,
                            onPressed: _navigateToRouteScreen,
                            iconColor: Colors.blue.shade700,
                          ),
                          _buildNavigationButton(
                            label: "Find Route",
                            icon: Icons.directions_bus,
                            onPressed: _findRoute,
                            iconColor: Colors.orange.shade700,
                            isPrimary: true,
                          ),
                          _buildNavigationButton(
                            label: "Map",
                            icon: Icons.map,
                            onPressed: _showMapImage,
                            iconColor: Colors.green.shade700,
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

  // Location Card Widget
  Widget _buildLocationCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      margin: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 16,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          Divider(thickness: 1, height: 1, color: Colors.grey.shade200),

          // Dropdown
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: child,
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade50,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: DropdownButton<BusStop>(
        hint: Text(
          hint,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
        ),
        underline: SizedBox(),
        dropdownColor: Colors.white,
        value: value,
        isExpanded: true,
        icon: Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(Icons.keyboard_arrow_down,
              color: Colors.grey.shade700, size: 16),
        ),
        style: TextStyle(
          color: Colors.black87,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        onChanged: onChanged,
        items: busStops.map<DropdownMenuItem<BusStop>>((BusStop stop) {
          return DropdownMenuItem<BusStop>(
            value: stop,
            child: Text(
              stop.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Navigation Button Widget
  Widget _buildNavigationButton({
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
              SizedBox(height: 6),
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
