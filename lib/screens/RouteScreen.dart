import 'dart:convert';
import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TripsRoutesPage extends StatefulWidget {
  final String? sourceStop;
  final String? destinationStop;

  const TripsRoutesPage({
    Key? key,
    this.sourceStop,
    this.destinationStop
  }) : super(key: key);

  @override
  _TripsRoutesPageState createState() => _TripsRoutesPageState();
}

class _TripsRoutesPageState extends State<TripsRoutesPage> with SingleTickerProviderStateMixin {
  int? expandedIndex;
  List<dynamic> busRoutes = [];
  List<dynamic> filteredRoutes = [];
  bool _isLoading = true;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  // Individual animations for staggered effect
  bool _showContent = false;
  bool _showBottomBar = false;

  @override
  void initState() {
    super.initState();
    fetchBusRoutes();

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

  Future<void> fetchBusRoutes() async {
    try {
      final response = await http.get(Uri.parse('https://cbt-backend-02ce.onrender.com/bus_routes'));
      if (response.statusCode == 200) {
        final allRoutes = json.decode(response.body);

        // Filter routes if source and destination are provided
        if (widget.sourceStop != null && widget.destinationStop != null) {
          filteredRoutes = allRoutes.where((route) {
            // Ensure route has stops and they are a list
            if (route['stops'] == null || !(route['stops'] is List)) return false;

            // Check if route contains both source and destination stops
            bool hasSourceStop = route['stops'].any((stop) =>
            stop['name'].toString().toLowerCase() == widget.sourceStop!.toLowerCase());

            bool hasDestinationStop = route['stops'].any((stop) =>
            stop['name'].toString().toLowerCase() == widget.destinationStop!.toLowerCase());

            // Ensure source stop comes before destination stop
            if (hasSourceStop && hasDestinationStop) {
              int sourceIndex = route['stops'].indexWhere((stop) =>
              stop['name'].toString().toLowerCase() == widget.sourceStop!.toLowerCase());

              int destIndex = route['stops'].indexWhere((stop) =>
              stop['name'].toString().toLowerCase() == widget.destinationStop!.toLowerCase());

              return sourceIndex < destIndex;
            }

            return false;
          }).toList();
        } else {
          // If no source/destination provided, show all routes
          filteredRoutes = allRoutes;
        }

        setState(() {
          busRoutes = filteredRoutes;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load bus routes');
      }
    } catch (e) {
      print('Error fetching bus routes: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar("Could not load bus routes. Please check your connection.");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background (same as previous implementation)
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

          // Background pattern (same as previous implementation)
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
            child: Column(
              children: [
                // App bar (same as previous implementation)
                FadeTransition(
                  opacity: _fadeInAnimation,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 12.0),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'backButton',
                          child: Material(
                            color: Colors.transparent,
                            child: IconButton(
                              icon: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.blue.shade700,
                                  size: 20,
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            widget.sourceStop != null && widget.destinationStop != null
                                ? "Routes via ${widget.sourceStop} to ${widget.destinationStop}"
                                : "Available Routes",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        // App logo small version (same as previous implementation)
                        Hero(
                          tag: 'app_logo',
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'lib/assets/images/re.png',
                              width: 70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Info card with route filtering information
                FadeTransition(
                  opacity: _fadeInAnimation,
                  child: AnimatedOpacity(
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
                      child: Container(
                        margin: EdgeInsets.fromLTRB(16, 8, 16, 16),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Route Guidance",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    widget.sourceStop != null && widget.destinationStop != null
                                        ? "Showing routes between ${widget.sourceStop} and ${widget.destinationStop}"
                                        : "Tap on a route to see all the bus stops. All timings are approximate.",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Routes list
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
                          "Loading routes...",
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
                    child: busRoutes.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.route_outlined,
                            color: Colors.white.withOpacity(0.7),
                            size: 64,
                          ),
                          SizedBox(height: 16),
                          Text(
                            widget.sourceStop != null && widget.destinationStop != null
                                ? "No routes found between ${widget.sourceStop} and ${widget.destinationStop}"
                                : "No routes available",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 90),
                      itemCount: busRoutes.length,
                      itemBuilder: (context, index) {
                        var route = busRoutes[index];
                        bool isExpanded = expandedIndex == index;

                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: isExpanded
                                    ? Colors.red.withOpacity(0.2)
                                    : Colors.black.withOpacity(0.08),
                                blurRadius: isExpanded ? 15 : 10,
                                spreadRadius: isExpanded ? 2 : 1,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Card Header (same as previous implementation)
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      expandedIndex = isExpanded ? null : index;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                                        child: Row(
                                          children: [
                                            _buildRouteNumberBadge(route),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    (route['busName'] ?? 'UNKNOWN').toString().toUpperCase(),
                                                    style: TextStyle(
                                                      color: Colors.black87,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.circle,
                                                        size: 8,
                                                        color: Colors.green,
                                                      ),
                                                      SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          (route['startPoint'] ?? 'UNKNOWN').toString(),
                                                          style: TextStyle(
                                                            color: Colors.black54,
                                                            fontSize: 13,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 2),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.circle,
                                                        size: 8,
                                                        color: Colors.red,
                                                      ),
                                                      SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          (route['endPoint'] ?? 'UNKNOWN').toString(),
                                                          style: TextStyle(
                                                            color: Colors.black54,
                                                            fontSize: 13,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: isExpanded ? Colors.red.shade50 : Colors.grey.shade50,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Icon(
                                                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                                color: isExpanded ? Colors.red.shade700 : Colors.grey.shade700,
                                                size: 24,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!isExpanded)
                                        Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                                    ],
                                  ),
                                ),
                              ),

                              // Expanded content with stops
                              AnimatedSize(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: isExpanded && route['stops'] != null
                                    ? Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade700.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Icon(
                                                Icons.map,
                                                color: Colors.blue.shade700,
                                                size: 16,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "Bus Stops",
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                                      ..._buildStopsList(route['stops'] as List<dynamic>),
                                      SizedBox(height: 12),
                                    ],
                                  ),
                                )
                                    : SizedBox.shrink(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom bar with glass effect (same as previous implementation)
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
                            label: "Filter Routes",
                            icon: Icons.filter_alt,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Filter coming soon!"),
                                  backgroundColor: Colors.blue.shade700,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                            iconColor: Colors.blue.shade700,
                          ),
                          _buildNavigationButton(
                            label: "View Schedule",
                            icon: Icons.schedule,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Schedule coming soon!"),
                                  backgroundColor: Colors.blue.shade700,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                            iconColor: Colors.orange.shade700,
                            isPrimary: true,
                          ),
                          _buildNavigationButton(
                            label: "Favorites",
                            icon: Icons.star,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Favorites coming soon!"),
                                  backgroundColor: Colors.green.shade700,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
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

  // Existing helper methods like _buildRouteNumberBadge, _buildStopsList, etc. remain the same
  Widget _buildRouteNumberBadge(dynamic route) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        (route['routeNumber'] ?? '?').toString(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  // Builds the list of stops within a route
  List<Widget> _buildStopsList(List<dynamic> stops) {
    return stops.map<Widget>((stop) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 2),
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.location_on,
                color: Colors.green.shade700,
                size: 14,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (stop['name'] ?? 'UNKNOWN STOP').toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "ARR: ${(stop['arrival'] ?? '--')}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(
                        Icons.directions_bus,
                        size: 12,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "DEP: ${(stop['departure'] ?? '--')}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // Navigation Button Widget (same as previous implementation)
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
