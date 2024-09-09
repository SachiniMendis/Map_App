import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart'; // Correctly import flutter_test package
import 'package:map_app/main.dart'; // Adjust to the correct path of your app

void main() {
  testWidgets('Google Maps Flutter Demo initial load test', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that the app displays the expected title in the AppBar.
    expect(find.text('Google Maps Flutter Demo'), findsOneWidget);

    // Verify that the Google Map widget is present.
    expect(find.byType(GoogleMap), findsOneWidget);
  });
}
