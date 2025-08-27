import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:gitvision/utils/accessibility_helpers.dart';
import 'package:gitvision/widgets/eurovision_song_card.dart';
import 'package:gitvision/widgets/github_connection_widget.dart';
import 'package:gitvision/widgets/audio_player_widget.dart';
import 'package:gitvision/models/eurovision_song.dart';

void main() {
  group('Accessibility Tests', () {
    testWidgets('AccessibilityHelpers creates proper touch targets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibilityHelpers.accessibleIconButton(
              icon: Icons.play_arrow,
              onPressed: () {},
              semanticLabel: 'Play button test',
            ),
          ),
        ),
      );

      // Verify the button has minimum touch target size
      final buttonFinder = find.byType(SizedBox);
      expect(buttonFinder, findsOneWidget);
      
      final SizedBox sizedBox = tester.widget(buttonFinder);
      expect(sizedBox.width, equals(AccessibilityConstants.preferredTouchTargetSize));
      expect(sizedBox.height, equals(AccessibilityConstants.preferredTouchTargetSize));
    });

    testWidgets('AccessibilityHelpers creates proper semantic labels', (WidgetTester tester) async {
      const testLabel = 'Test semantic label';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibilityHelpers.accessibleIconButton(
              icon: Icons.music_note,
              onPressed: () {},
              semanticLabel: testLabel,
            ),
          ),
        ),
      );

      // Check for semantic label
      expect(find.bySemanticsLabel(testLabel), findsOneWidget);
    });

    testWidgets('Eurovision Song Card has proper accessibility structure', (WidgetTester tester) async {
      final testSong = EurovisionSong(
        title: 'Test Song',
        artist: 'Test Artist',
        country: 'Test Country',
        year: 2023,
        reasoning: 'Test reasoning for Eurovision mood',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EurovisionSongCard(song: testSong),
          ),
        ),
      );

      // Verify card has semantic structure
      final expectedLabel = AccessibilityConstants.songCardLabel(
        testSong.title,
        testSong.artist,
        testSong.country,
        testSong.year,
      );
      
      expect(find.bySemanticsLabel(expectedLabel), findsOneWidget);
    });

    testWidgets('TextField has proper accessibility labels', (WidgetTester tester) async {
      final controller = TextEditingController();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibilityHelpers.accessibleTextField(
              controller: controller,
              label: 'Test Label',
              hint: 'Test Hint',
              semanticLabel: 'Test Semantic Label',
            ),
          ),
        ),
      );

      // Verify semantic label is present
      expect(find.bySemanticsLabel('Test Semantic Label'), findsOneWidget);
      
      // Verify text field has proper structure
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Image widget has alternative text', (WidgetTester tester) async {
      const altText = 'Test alternative text for image';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibilityHelpers.accessibleImage(
              imageUrl: 'https://example.com/test.jpg',
              altText: altText,
              width: 100,
              height: 100,
            ),
          ),
        ),
      );

      // Verify image has semantic label
      expect(find.bySemanticsLabel(altText), findsOneWidget);
    });

    testWidgets('Loading indicators have descriptive text', (WidgetTester tester) async {
      const loadingDescription = 'Loading Eurovision songs';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibilityHelpers.accessibleLoadingIndicator(
              description: loadingDescription,
            ),
          ),
        ),
      );

      // Verify loading indicator has semantic description
      expect(find.bySemanticsLabel(loadingDescription), findsOneWidget);
    });

    group('Touch Target Size Tests', () {
      testWidgets('All interactive elements meet minimum touch target size', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  AccessibilityHelpers.accessibleIconButton(
                    icon: Icons.play_arrow,
                    onPressed: () {},
                    semanticLabel: 'Play',
                  ),
                  AccessibilityHelpers.accessibleIconButton(
                    icon: Icons.pause,
                    onPressed: () {},
                    semanticLabel: 'Pause',
                  ),
                ],
              ),
            ),
          ),
        );

        // Find all SizedBox widgets (touch targets)
        final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
        
        for (final sizedBox in sizedBoxes) {
          if (sizedBox.width != null && sizedBox.height != null) {
            expect(
              sizedBox.width! >= AccessibilityConstants.minTouchTargetSize,
              true,
              reason: 'Touch target width should be at least ${AccessibilityConstants.minTouchTargetSize}dp',
            );
            expect(
              sizedBox.height! >= AccessibilityConstants.minTouchTargetSize,
              true,
              reason: 'Touch target height should be at least ${AccessibilityConstants.minTouchTargetSize}dp',
            );
          }
        }
      });
    });

    group('Semantic Structure Tests', () {
      testWidgets('App has proper heading hierarchy', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('GitVision'),
              ),
              body: Column(
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Eurovision Songs',
                      style: Theme.of(tester.element(find.byType(Scaffold))).textTheme.headlineSmall,
                    ),
                  ),
                  Semantics(
                    header: true,
                    child: Text(
                      'Your Commit Analysis',
                      style: Theme.of(tester.element(find.byType(Scaffold))).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Verify headers are properly marked
        final headerSemantics = tester.allSemantics.where(
          (semantics) => semantics.hasFlag(SemanticsFlag.isHeader),
        );
        
        expect(headerSemantics.length, greaterThan(0));
      });
    });

    group('Color Contrast Tests', () {
      testWidgets('Text has sufficient contrast', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: Container(
                color: Colors.white,
                child: const Text(
                  'Test text for contrast',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ),
        );

        // Note: In a real app, you would test actual color contrast ratios
        // This is a placeholder for contrast testing logic
        expect(find.text('Test text for contrast'), findsOneWidget);
      });
    });
  });
}

/// Extension to help with accessibility testing
extension AccessibilityTestHelpers on WidgetTester {
  /// Find widgets by their semantic label
  Finder findBySemanticsLabel(String label) {
    return find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.label == label,
    );
  }
  
  /// Verify minimum touch target size for interactive elements
  void verifyTouchTargetSize(Finder finder, {double minSize = 44.0}) {
    final elements = elementList(finder);
    for (final element in elements) {
      final renderBox = element.renderObject as RenderBox?;
      if (renderBox != null) {
        expect(renderBox.size.width, greaterThanOrEqualTo(minSize));
        expect(renderBox.size.height, greaterThanOrEqualTo(minSize));
      }
    }
  }
  
  /// Check if widget has proper semantic structure
  bool hasProperSemantics(Widget widget) {
    if (widget is Semantics) {
      return widget.properties.label != null || 
             widget.properties.hint != null ||
             widget.properties.value != null;
    }
    return false;
  }
}