import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:bus_route_finder/managers/location_manager.dart';

// Custom mock extending GeolocatorPlatform to satisfy plugin_platform_interface requirements.
class MockGeolocatorPlatform extends GeolocatorPlatform {
  Future<bool> Function()? _isLocationServiceEnabledHandler;
  Future<LocationPermission> Function()? _checkPermissionHandler;
  Future<LocationPermission> Function()? _requestPermissionHandler;
  Stream<Position> Function()? _getPositionStreamHandler;

  @override
  Future<bool> isLocationServiceEnabled() {
    return _isLocationServiceEnabledHandler?.call() ?? Future.value(false);
  }

  @override
  Future<LocationPermission> checkPermission() {
    return _checkPermissionHandler?.call() ?? Future.value(LocationPermission.denied);
  }

  @override
  Future<LocationPermission> requestPermission() {
    return _requestPermissionHandler?.call() ?? Future.value(LocationPermission.denied);
  }

  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) {
    return _getPositionStreamHandler?.call() ?? Stream<Position>.empty();
  }

  // Helper setters to inject mocked behavior
  void setIsLocationServiceEnabledHandler(Future<bool> Function() handler) {
    _isLocationServiceEnabledHandler = handler;
  }

  void setCheckPermissionHandler(Future<LocationPermission> Function() handler) {
    _checkPermissionHandler = handler;
  }

  void setRequestPermissionHandler(Future<LocationPermission> Function() handler) {
    _requestPermissionHandler = handler;
  }

  void setGetPositionStreamHandler(Stream<Position> Function() handler) {
    _getPositionStreamHandler = handler;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGeolocatorPlatform mockGeolocator;
  late LocationManager locationManager;

  setUp(() {
    mockGeolocator = MockGeolocatorPlatform();
    GeolocatorPlatform.instance = mockGeolocator;
    locationManager = LocationManager();
  });

  tearDown(() {
    locationManager.stopListening();
  });

  test('startListening returns early if location services disabled', () async {
    mockGeolocator.setIsLocationServiceEnabledHandler(() => Future.value(false));

    bool called = false;
    locationManager.startListening((position) {
      called = true;
    });

    await Future.delayed(Duration.zero);

    expect(called, false);
  });

  test('startListening returns early if permission denied', () async {
    mockGeolocator.setIsLocationServiceEnabledHandler(() => Future.value(true));
    mockGeolocator.setCheckPermissionHandler(() => Future.value(LocationPermission.denied));
    mockGeolocator.setRequestPermissionHandler(() => Future.value(LocationPermission.denied));

    bool called = false;
    locationManager.startListening((position) {
      called = true;
    });

    await Future.delayed(Duration.zero);

    expect(called, false);
  });

  test('startListening subscribes to location stream if permitted', () async {
    mockGeolocator.setIsLocationServiceEnabledHandler(() => Future.value(true));
    mockGeolocator.setCheckPermissionHandler(() => Future.value(LocationPermission.always));

    final controller = StreamController<Position>();
    mockGeolocator.setGetPositionStreamHandler(() => controller.stream);

    Position? receivedPosition;
    locationManager.startListening((position) {
      receivedPosition = position;
    });

    final position = Position(
      longitude: 10.0,
      latitude: 20.0,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );

    controller.add(position);
    await Future.delayed(Duration.zero);

    expect(receivedPosition, position);

    locationManager.stopListening();
    await controller.close();
  });
}
