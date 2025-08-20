import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:your_project/screens/home_screen.dart'; // update package name

void main() {
  testWidgets('HomeScreen shows loading spinner initially', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('HomeScreen has a FloatingActionButton', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
