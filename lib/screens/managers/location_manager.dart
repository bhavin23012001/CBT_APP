import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

// Singleton class to manage location updates
class LocationManager {
  static final LocationManager _instance = LocationManager._internal();
  late Stream<Position> _positionStream;
  StreamSubscription<Position>? _positionSubscription;

  // Private constructor
  LocationManager._internal();

  // Factory constructor to access the singleton instance
  factory LocationManager() {
    return _instance;
  }

  // Start listening for location updates
  void startListening(Function(Position) onLocationUpdate) async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return;
    }

    // Request permissions if needed
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

    // Listen to the stream of positions
    _positionSubscription = _positionStream.listen((Position position) {
      print("Updated location: ${position.latitude}, ${position.longitude}");
      onLocationUpdate(position);
    });
  }

  // Stop listening to location updates
  void stopListening() {
    _positionSubscription?.cancel();
  }
}
