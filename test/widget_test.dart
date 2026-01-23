// Basic Flutter widget test for ART CAT app

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:art_cat/app.dart';

void main() {
  setUpAll(() async {
    // Initialise Hive for testing
    await Hive.initFlutter();
  });

  testWidgets('App loads home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const ArtCatApp());
    await tester.pumpAndSettle();

    // Verify that the home screen is displayed
    expect(find.text('ART CAT'), findsOneWidget);
    expect(find.text('Create something purrfect!'), findsOneWidget);
  });

  testWidgets('Navigation to canvas works', (WidgetTester tester) async {
    await tester.pumpWidget(const ArtCatApp());
    await tester.pumpAndSettle();

    // Tap the New Canvas card
    await tester.tap(find.text('New Canvas'));
    await tester.pumpAndSettle();

    // Verify canvas screen is shown (has save button)
    expect(find.byIcon(Icons.save), findsOneWidget);
  });
}
