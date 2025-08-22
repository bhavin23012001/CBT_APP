import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:CBT_APP/lib/managers/location_manager.dart';
// Generate mocks with: flutter pub run build_runner build
// Or manually create mock for GeolocatorPlatform
class MockGeolocatorPlatform extends Mock implements GeolocatorPlatform {}
@GenerateMocks([GeolocatorPlatform])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockGeolocatorPlatform mockGeolocator;
  late LocationManager locationManager;
  setUp(() {
    mockGeolocator = MockGeolocatorPlatform();
    GeolocatorPlatform.instance = mockGeolocator;
    locationManager = LocationManager();
  });
  test('startListening returns early if location services disabled', () async {
    when(mockGeolocator.isLocationServiceEnabled())
        .thenAnswer((_) async => false);
    // Should print and return without starting subscription
    bool called = false;
    await locationManager.startListening((position) {
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
    await locationManager.startListening((position) {
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
    when(mockGeolocator.getPositionStream(
      locationSettings: anyNamed('locationSettings'),
    )).thenAnswer((_) => controller.stream);
    Position? receivedPosition;
    await locationManager.startListening((position) {
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
    );
    controller.add(position);
    await Future.delayed(Duration.zero);
    expect(receivedPosition, position);
    await locationManager.stopListening();
    await controller.close();
  });
}
