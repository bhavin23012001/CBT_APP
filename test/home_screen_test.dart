import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'dart:convert';

import 'package:your_project/screens/home_screen.dart'; // Update path

class MockClient extends Mock implements http.Client {}

void main() {
  group('HomeScreen Tests', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
    });

    testWidgets('displays bus stops after successful fetch', (WidgetTester tester) async {
      final mockData = [
        {
          'stop_name': 'Stop 1',
          'coordinates': {'coordinates': [72.5714, 23.0225]}
        },
        {
          'stop_name': 'Stop 2',
          'coordinates': {'coordinates': [72.5814, 23.0325]}
        },
      ];

      // Mock http.get call
      when(mockClient.get(Uri.parse("http://54.236.128.72:3000/bus_stops")))
          .thenAnswer((_) async => http.Response(jsonEncode(mockData), 200));

      await tester.pumpWidget(MaterialApp(home: HomeScreen()));

      // Let async calls finish
      await tester.pumpAndSettle();

      // Check dropdown has first stop
      expect(find.text('Stop 1'), findsWidgets);
      expect(find.text('Stop 2'), findsWidgets);
    });

    testWidgets('swap button swaps source and destination', (WidgetTester tester) async {
      final busStops = [
        BusStop(name: 'Stop A', latitude: 23, longitude: 72),
        BusStop(name: 'Stop B', latitude: 24, longitude: 73),
      ];

      await tester.pumpWidget(MaterialApp(home: HomeScreen()));
      final state = tester.state<_HomeScreenState>(find.byType(HomeScreen));

      // Set initial source and destination
      state.setState(() {
        state._selectedSource = busStops[0];
        state._selectedDestination = busStops[1];
      });

      expect(state._selectedSource!.name, 'Stop A');
      expect(state._selectedDestination!.name, 'Stop B');

      // Tap swap button
      final swapButton = find.byTooltip('Swap locations');
      await tester.tap(swapButton);
      await tester.pump();

      expect(state._selectedSource!.name, 'Stop B');
      expect(state._selectedDestination!.name, 'Stop A');
    });

    testWidgets('shows snackbar when finding route without selection', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HomeScreen()));

      // Tap Find Route button
      final findRouteButton = find.text('Find Route');
      await tester.tap(findRouteButton);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Please select both source and destination'), findsOneWidget);
    });

    testWidgets('shows map snackbar on Map button tap', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HomeScreen()));

      final mapButton = find.text('Map');
      await tester.tap(mapButton);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Map view coming soon!'), findsOneWidget);
    });
  });
}
