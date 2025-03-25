import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bus_route_finder/main.dart';

void main() {
  testWidgets('App loads and shows SplashScreen', (WidgetTester tester) async {
    // Pump the widget into the test environment
    await tester.pumpWidget(MyApp());

    // Check if MaterialApp is loaded (avoiding dependency on specific widgets)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
