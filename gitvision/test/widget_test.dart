// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gitvision/main.dart';

void main() {
  testWidgets('GitVision app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GitVisionApp());

    // Verify that our app has the Eurovision title
    expect(find.text('🎵 GitVision - Eurovision Edition'), findsOneWidget);
    expect(find.text('🇪🇺'), findsOneWidget);

    // Verify that the GitHub username input field exists
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('GitHub Username'), findsOneWidget);

    // Verify that the analyze button exists
    expect(find.text('🎵 Analyze GitHub Profile'), findsOneWidget);
  });
}
