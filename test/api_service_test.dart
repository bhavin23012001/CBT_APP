import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:your_project/services/api_service.dart'; // update with your package path

class MockClient extends Mock implements http.Client {}

void main() {
  group('MapScreen API Tests', () {
    late MockClient client;

    setUp(() {
      client = MockClient();
    });

    testWidgets('displays markers after successful fetch', (WidgetTester tester) async {
      // Mock response data
      final mockData = [
        {
          'stop_name': 'Bus Stop 1',
          'coordinates': {'coordinates': [72.5714, 23.0225]}
        },
        {
          'stop_name': 'Bus Stop 2',
          'coordinates': {'coordinates': [72.5814, 23.0325]}
        },
      ];

      // Replace http.get with mock client
      when(client.get(Uri.parse('http://54.236.128.72:3000')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockData), 200));

      // Build the widget
      await tester.pumpWidget(MaterialApp(home: MapScreen()));

      // Wait for async calls
      await tester.pumpAndSettle();

      // Verify marker texts are found
      expect(find.text('Bus Stop 1'), findsOneWidget);
      expect(find.text('Bus Stop 2'), findsOneWidget);

      // Verify Icon marker exists
      expect(find.byIcon(Icons.location_on), findsNWidgets(2));
    });

    testWidgets('handles HTTP error gracefully', (WidgetTester tester) async {
      // Mock failed response
      when(client.get(Uri.parse('http://54.236.128.72:3000')))
          .thenAnswer((_) async => http.Response('Error', 500));

      await tester.pumpWidget(MaterialApp(home: MapScreen()));
      await tester.pumpAndSettle();

      // In case of error, no markers should be displayed
      expect(find.byType(MarkerLayer), findsOneWidget);
    });
  });
}
