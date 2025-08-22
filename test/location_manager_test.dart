import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:bus_route_finder/managers/location_manager.dart';

// Generate mocks with: flutter pub run build_runner build
class MockGeolocatorPlatform extends Mock implements GeolocatorPlatform {}

@GenerateMocks([GeolocatorPlatform])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockGeolocatorPlatform mockGeolocator;
  late LocationManager locationManager;

  setUp(() {
    mockGeolocator = MockGeolocatorPlatform();
    GeolocatorPlatform.instance = mockGeolocator; // Fixed typo here
    locationManager = LocationManager();
  });

  tearDown(() {
    locationManager.stopListening(); // No await because stopListening returns void
  });

  test('startListening returns early if location services disabled', () async {
    when(mockGeolocator.isLocationServiceEnabled())
        .thenAnswer((_) async => false);
    bool called = false;
    locationManager.startListening((position) { // Removed await, method returns void
      called = true;
    });
    expect(called, false);
    verify(mockGeolocator.isLocationServiceEnabled()).called(1);
  });

  test('startListening returns early if permission denied', () async {
    when(mockGeolocator.isLocationServiceEnabled())
        .thenAnswer((_) async => true);
    when(mockGeolocator.checkPermission())
        .thenAnswer((_) async => LocationPermission.denied);
    when(mockGeolocator.requestPermission())
        .thenAnswer((_) async => LocationPermission.denied);
    bool called = false;
    locationManager.startListening((position) { // Removed await
      called = true;
    });
    expect(called, false);
    verifyInOrder([
      mockGeolocator.isLocationServiceEnabled(),
      mockGeolocator.checkPermission(),
      mockGeolocator.requestPermission(),
    ]);
  });

  test('startListening subscribes to location stream if permitted', () async {
    when(mockGeolocator.isLocationServiceEnabled())
        .thenAnswer((_) async => true);
    when(mockGeolocator.checkPermission())
        .thenAnswer((_) async => LocationPermission.always);

    final controller = StreamController<Position>();
    when(mockGeolocator.getPositionStream(  // Fixed typo here
      locationSettings: anyNamed('locationSettings'),
    )).thenAnswer((_) => controller.stream);

    Position? receivedPosition;
    locationManager.startListening((position) { // Removed await
      receivedPosition = position;
    });

    // Emit a fake position
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

    locationManager.stopListening(); // Removed await

    await controller.close();
  });
}
