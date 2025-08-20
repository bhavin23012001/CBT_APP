import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:your_app/screens/home_screen.dart'; // Adjust import path

class MockClient extends Mock implements http.Client {}

void main() {
  group('HomeScreen Widget Tests', () {
    late MockClient client;

    setUp(() {
      client = MockClient();
    });

    testWidgets('Shows loading initially and then bus stops', (WidgetTester tester) async {
      // Mock HTTP response
      when(client.get(Uri.parse('http://54.236.128.72:3000/bus_stops')))
          .thenAnswer((_) async => http.Response(jsonEncode([
                {
                  "stop_name": "Stop A",
                  "coordinates": {"coordinates": [72.0, 23.0]}
                },
                {
                  "stop_name": "Stop B",
                  "coordinates": {"coordinates": [73.0, 24.0]}
                }
              ]), 200));

      await tester.pumpWidget(MaterialApp(home: HomeScreen()));

      // Check loading indicator
      expect(find.text('Loading bus stops...'), findsOneWidget);

      // Wait for async fetchBusStops
      await tester.pumpAndSettle();

      // Check if dropdowns have bus stops
      expect(find.text('Select source location'), findsOneWidget);
      expect(find.text('Select destination location'), findsOneWidget);

      // Tap source dropdown and select first stop
      await tester.tap(find.text('Select source location'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Stop A').last);
      await tester.pump();

      // Tap destination dropdown and select second stop
      await tester.tap(find.text('Select destination location'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Stop B').last);
      await tester.pump();

      // Check if travel info shows correct stops
      expect(find.textContaining('From: Stop A'), findsOneWidget);
      expect(find.textContaining('To: Stop B'), findsOneWidget);
    });

    testWidgets('Swap source and destination', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HomeScreen()));

      // Set state manually
      final state = tester.state<_HomeScreenState>(find.byType(HomeScreen));
      state.setState(() {
        state._selectedSource = BusStop(name: 'A', latitude: 1, longitude: 2);
        state._selectedDestination = BusStop(name: 'B', latitude: 3, longitude: 4);
      });
      await tester.pump();

      // Swap
      state._swapLocations();
      await tester.pump();

      expect(state._selectedSource!.name, 'B');
      expect(state._selectedDestination!.name, 'A');
    });

    testWidgets('Show error snackbar when buttons pressed without selection', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HomeScreen()));

      // Tap Find Route button
      await tester.tap(find.text('Find Route'));
      await tester.pump();

      // Snackbar should appear
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
