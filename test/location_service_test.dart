import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/mockito.dart';
import 'package:your_project/services/location_service.dart'; // Update path

// Mock class for Geolocator
class MockGeolocatorPlatform extends Mock implements GeolocatorPlatform {}

void main() {
  late MockGeolocatorPlatform mockGeolocator;

  setUp(() {
    mockGeolocator = MockGeolocatorPlatform();
    GeolocatorPlatform.instance = mockGeolocator;
  });

  test('throws exception if location service is disabled', () async {
    when(mockGeolocator.isLocationServiceEnabled()).thenAnswer((_) async => false);

    expect(getCurrentLocation(), throwsA(isA<Exception>()));
  });

  test('throws exception if permission is denied', () async {
    when(mockGeolocator.isLocationServiceEnabled()).thenAnswer((_) async => true);
    when(mockGeolocator.checkPermission())
        .thenAnswer((_) async => LocationPermission.denied);
    when(mockGeolocator.requestPermission())
        .thenAnswer((_) async => LocationPermission.denied);

    expect(getCurrentLocation(), throwsA(isA<Exception>()));
  });

  test('returns Position if service enabled and permission granted', () async {
    when(mockGeolocator.isLocationServiceEnabled()).thenAnswer((_) async => true);
    when(mockGeolocator.checkPermission())
        .thenAnswer((_) async => LocationPermission.always);
    when(mockGeolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high))
        .thenAnswer((_) async => Position(
              latitude: 23.0225,
              longitude: 72.5714,
              timestamp: DateTime.now(),
              accuracy: 1,
              altitude: 0,
              heading: 0,
              speed: 0,
              speedAccuracy: 0,
            ));

    final position = await getCurrentLocation();

    expect(position.latitude, 23.0225);
    expect(position.longitude, 72.5714);
  });
}
