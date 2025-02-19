import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bus Route Finder',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto', // Set default font across app
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

  LocationManager._internal();

  factory LocationManager() => _instance;

  // Start listening to location updates
  void startListening(Function(Position) onLocationUpdate) async {
    if (_isListening) return; // Prevent multiple listeners

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return;
    }

    // Request location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) {
        print("Location permissions are denied.");
        return;
      }
    }

    // Start listening to location updates
    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Notify when the user moves 10 meters
      ),
    );

    _positionStream.listen((Position position) {
      print("Updated location: ${position.latitude}, ${position.longitude}");
      onLocationUpdate(position);
    });

    _isListening = true; // Mark as listening
  }

  // Stop listening to location updates
  void stopListening() {
    if (_isListening) {
      _positionStream.drain(); // Drain the stream to stop listening
      _isListening = false;
      print("Location updates stopped.");
    }
  }
}
