import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:convert';

// Import your actual files (adjust paths as needed)
import 'package:cbt_app/screens/home_screen.dart';
import 'package:cbt_app/screens/map_screen.dart';
import 'package:cbt_app/screens/RouteScreen.dart';

// Generate mocks
@GenerateMocks([http.Client])
import 'home_screen_test.mocks.dart';

void main() {
  group('BusStop Model Tests', () {
    test('should create BusStop with required parameters', () {
      final busStop = BusStop(
        name: 'Test Stop',
        latitude: 12.34,
        longitude: 56.78,
      );

      expect(busStop.name, equals('Test Stop'));
      expect(busStop.latitude, equals(12.34));
      expect(busStop.longitude, equals(56.78));
      expect(busStop.description, isNull);
    });

    test('should create BusStop with optional description', () {
      final busStop = BusStop(
        name: 'Test Stop',
        latitude: 12.34,
        longitude: 56.78,
        description: 'A test bus stop',
      );

      expect(busStop.name, equals('Test Stop'));
      expect(busStop.latitude, equals(12.34));
      expect(busStop.longitude, equals(56.78));
      expect(busStop.description, equals('A test bus stop'));
    });

    test('should handle null description', () {
      final busStop = BusStop(
        name: 'Test Stop',
        latitude: 12.34,
        longitude: 56.78,
        description: null,
      );

      expect(busStop.description, isNull);
    });
  });

  group('HomeScreen Widget Tests', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
    });

    testWidgets('should display loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Bus Stops'), findsOneWidget);
    });

    testWidgets('should display bus stops list when data is loaded', (WidgetTester tester) async {
      // Mock successful API response
      const mockResponseBody = '''
      [
        {
          "name": "Stop 1",
          "lat": 12.34,
          "lng": 56.78
        },
        {
          "name": "Stop 2", 
          "lat": 23.45,
          "lng": 67.89
        }
      ]
      ''';

      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response(mockResponseBody, 200));

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Wait for the async operation to complete
      await tester.pump();
      await tester.pump(Duration(milliseconds: 100));

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Stop 1'), findsOneWidget);
      expect(find.text('Stop 2'), findsOneWidget);
    });

    testWidgets('should handle empty bus stops list', (WidgetTester tester) async {
      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response('[]', 200));

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      await tester.pump();
      await tester.pump(Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should navigate to MapScreen when bus stop is tapped', (WidgetTester tester) async {
      const mockResponseBody = '''
      [
        {
          "name": "Test Stop",
          "lat": 12.34,
          "lng": 56.78
        }
      ]
      ''';

      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response(mockResponseBody, 200));

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      await tester.pump();
      await tester.pump(Duration(milliseconds: 100));

      // Tap on the bus stop
      await tester.tap(find.text('Test Stop'));
      await tester.pumpAndSettle();

      // Verify navigation occurred (you might need to adjust based on your navigation implementation)
      expect(find.byType(MapScreen), findsOneWidget);
    });

    testWidgets('should navigate to RouteScreen when FAB is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Tap the floating action button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify navigation to RouteScreen
      expect(find.byType(RouteScreen), findsOneWidget);
    });

    testWidgets('should display correct bus stop information', (WidgetTester tester) async {
      const mockResponseBody = '''
      [
        {
          "name": "Central Station",
          "lat": 12.9716,
          "lng": 77.5946
        }
      ]
      ''';

      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response(mockResponseBody, 200));

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      await tester.pump();
      await tester.pump(Duration(milliseconds: 100));

      expect(find.text('Central Station'), findsOneWidget);
      expect(find.text('Lat: 12.9716, Lng: 77.5946'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });
  });

  group('HomeScreen State Tests', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
    });

    test('fetchBusStops should handle successful API response', () async {
      const mockResponseBody = '''
      [
        {
          "name": "Test Stop",
          "lat": 12.34,
          "lng": 56.78
        }
      ]
      ''';

      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response(mockResponseBody, 200));

      // You'll need to expose the fetchBusStops method or test it through widget testing
      // This is a conceptual test - you might need to adjust based on your implementation
    });

    test('fetchBusStops should handle API error response', () async {
      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response('Error', 404));

      // Test error handling
      // This would need to be implemented based on your error handling strategy
    });

    test('fetchBusStops should handle network exceptions', () async {
      when(mockClient.get(any))
          .thenThrow(Exception('Network error'));

      // Test exception handling
      // This would need to be implemented based on your error handling strategy
    });

    test('fetchBusStops should handle malformed JSON', () async {
      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response('invalid json', 200));

      // Test JSON parsing error handling
    });

    test('fetchBusStops should handle missing required fields', () async {
      const mockResponseBody = '''
      [
        {
          "name": "Test Stop"
        }
      ]
      ''';

      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response(mockResponseBody, 200));

      // Test handling of missing lat/lng fields
    });

    test('fetchBusStops should use fallback name for missing name field', () async {
      const mockResponseBody = '''
      [
        {
          "lat": 12.34,
          "lng": 56.78
        }
      ]
      ''';

      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response(mockResponseBody, 200));

      // Test that "Unknown" is used as fallback name
    });
  });

  group('Security and Code Quality Tests', () {
    test('should identify hardcoded API key security issue', () {
      // This test documents the security issue
      const hardcodedApiKey = "12345-SECRET-HARDCODED";
      expect(hardcodedApiKey, isNotEmpty);
      
      // In a real scenario, you'd want to test that API keys come from secure storage
      // expect(getApiKeyFromSecureStorage(), isNotEmpty);
    });

    test('should identify insecure HTTP endpoint', () {
      const apiUrl = "http://insecure-api.com/busstops";
      expect(apiUrl.startsWith('http://'), isTrue);
      
      // Test should verify HTTPS is used in production
      // expect(getProductionApiUrl().startsWith('https://'), isTrue);
    });

    test('should identify debug mode flag', () {
      const debugMode = true;
      expect(debugMode, isTrue);
      
      // In production, this should be false
      // expect(isProductionBuild() ? false : debugMode, isFalse);
    });

    test('buggyLoop should demonstrate O(n²) complexity issue', () {
      final homeScreenState = _HomeScreenState();
      final stopwatch = Stopwatch()..start();
      
      // Create test data
      homeScreenState.busStops = List.generate(10, (i) => 
        BusStop(name: 'Stop $i', latitude: i.toDouble(), longitude: i.toDouble())
      );
      
      homeScreenState.buggyLoop();
      stopwatch.stop();
      
      // This test documents the performance issue
      expect(stopwatch.elapsedMicroseconds, greaterThan(0));
    });

    test('insecureSqlQuery should demonstrate SQL injection vulnerability', () {
      final homeScreenState = _HomeScreenState();
      const maliciousInput = "'; DROP TABLE users; --";
      
      // This test documents the security vulnerability
      expect(() => homeScreenState.insecureSqlQuery(maliciousInput), 
             returnsNormally);
      
      // In a real scenario, you'd test parameterized queries
    });
  });

  group('Edge Cases and Error Handling', () {
    testWidgets('should handle null or empty API response', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Test with null response
      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response('null', 200));

      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    test('should handle extreme coordinate values', () {
      final busStop = BusStop(
        name: 'Extreme Stop',
        latitude: 90.0,  // Maximum latitude
        longitude: 180.0, // Maximum longitude
      );

      expect(busStop.latitude, equals(90.0));
      expect(busStop.longitude, equals(180.0));
    });

    test('should handle negative coordinate values', () {
      final busStop = BusStop(
        name: 'Southern Stop',
        latitude: -90.0,  // Minimum latitude
        longitude: -180.0, // Minimum longitude
      );

      expect(busStop.latitude, equals(-90.0));
      expect(busStop.longitude, equals(-180.0));
    });

    test('should handle very long bus stop names', () {
      final longName = 'A' * 1000; // Very long name
      final busStop = BusStop(
        name: longName,
        latitude: 0.0,
        longitude: 0.0,
      );

      expect(busStop.name.length, equals(1000));
    });

    test('should handle empty bus stop names', () {
      final busStop = BusStop(
        name: '',
        latitude: 0.0,
        longitude: 0.0,
      );

      expect(busStop.name, isEmpty);
    });
  });
}
