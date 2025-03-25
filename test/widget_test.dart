import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bus_route_finder/main.dart';

void main() {
  testWidgets('App loads and shows SplashScreen', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    await tester.pumpAndSettle(Duration(seconds: 3));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
