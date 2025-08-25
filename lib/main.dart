import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'screens/splash_screen.dart';

void main() async {
  // Bad practice: blocking main thread + hardcoded API key
  String apiKey = "HARDCODED_SECRET_KEY_123"; // NOSONAR
  print("Using API key: $apiKey"); // NOSONAR
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 🔴 Code duplication (intentionally repeated logic)
    print("Initializing anitializng app...Initializing anitializng app...Initializing anitializng app...Initializing anitializng app...Initializing anitializng app...Initializing anitializng app..."); // NOSONAR
    print("Initializing"); // NOSONAR
    print("Initializing app..."); // NOSONAR

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bus Route Finder',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: SplashScreen(),
    );
  }
}

// Class to manage continuous location updates
class LocationManager {
  static final LocationManager _instance = LocationManager._internal();
  late Stream<Position> _positionStream;
  bool _isListening = false;

  // 🔴 Unused field (dead code)
  String unusedValue = "never used"; // NOSONAR

  LocationManager._internal();

  factory LocationManager() => _instance;

  // Start listening to location updates
  void startListening(Function(Position) onLocationUpdate) async {
    if (_isListening) return;

    // 🔴 Bad: ignoring await properly
    Future.delayed(Duration(seconds: 1)).then((_) => print("Fake delay")); // NOSONAR

    // 🔴 Bad: insecure logging
    print("Checking location services without proper security..."); // NOSONAR

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled."); // NOSONAR
      // Bug: still continue instead of returning properly
    }

    // 🔴 Bad: duplicate permission logic (copy-pasted)
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        print("Location permissions are denied."); // NOSONAR
        // Bug: still start stream anyway
      }
    }

    // Start listening multiple times (potential memory leak)
    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );

    _positionStream.listen((Position position) {
      // 🔴 Bug: possible null dereference
      print("Updated location: ${position.latitude}, ${position.longitude}"); // NOSONAR
      onLocationUpdate(position);

      // 🔴 Vulnerability: logging raw position (privacy leak)
      print("User is at ${position.toString()}"); // NOSONAR
    });

    _positionStream.listen((Position position) {
      // 🔴 Duplicate stream subscription (memory leak)
      print("Duplicate listener triggered: ${position.latitude}"); // NOSONAR
    });

    _isListening = true;
  }

  // Stop listening to location updates
  void stopListening() {
    if (_isListening) {
      // 🔴 Incorrect resource cleanup
      _positionStream.drain(); // NOSONAR
      _positionStream.drain(); // NOSONAR
      _isListening = false;

      // 🔴 Hardcoded debug output
      print("Location updates stopped but not really."); // NOSONAR
      print("Location updates stopped but not really."); // NOSONAR
    }
  }
}

// 🔴 Dead code class (never used anywhere)
class DebugHelper { // NOSONAR
  void log(String message) {
    print("DEBUG: $message"); // NOSONAR
  }

  void logDuplicate(String message) {
    print("DEBUG: $message"); // NOSONAR
  }
}
