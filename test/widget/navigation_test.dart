import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moksharan/features/chapters/chapters_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  group('bottom navigation', () {
    testWidgets('starts on Home', (tester) async {
      final container = await pumpApp(tester);

      expect(currentLocation(container), '/');
      expect(find.text('Moksharan'), findsOneWidget);
      expect(find.text('Begin with Chapter 1'), findsOneWidget);
    });

    testWidgets('reaches every primary tab', (tester) async {
      final container = await pumpApp(tester);

      await tester.tap(find.text('Chapters'));
      await tester.pumpAndSettle();
      expect(currentLocation(container), '/chapters');

      await tester.tap(find.text('Bookmarks').last);
      await tester.pumpAndSettle();
      expect(currentLocation(container), '/bookmarks');
      expect(find.text('No bookmarks yet'), findsOneWidget);

      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();
      expect(currentLocation(container), '/settings');

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(currentLocation(container), '/');
    });
  });

  group('chapters', () {
    testWidgets('lists all 18 sample chapters', (tester) async {
      await pumpApp(tester, location: '/chapters');

      expect(find.text('Chapter 1'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Chapter 18'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Chapter 18'), findsOneWidget);
      expect(find.byType(ChapterTile), findsWidgets);
    });

    testWidgets('chapter tile opens detail, then reader', (tester) async {
      final container = await pumpApp(tester, location: '/chapters');

      await tester.tap(find.text('Chapter 1'));
      await tester.pumpAndSettle();
      expect(currentLocation(container), '/chapters/1');
      expect(
        find.text('Title and summary pending source verification.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Open reader'));
      await tester.pumpAndSettle();
      expect(currentLocation(container), '/read/1');
      // Chapter 1 has pilot scenes: first is the cinematic scene.
      expect(find.text('1 / 3'), findsOneWidget);
      expect(find.text('[Pilot] The armies assembled'), findsOneWidget);
      expect(find.byKey(const Key('fake-video')), findsOneWidget);
      // Reader is full-screen: no bottom navigation.
      expect(find.byType(NavigationBar), findsNothing);

      await tester.tap(find.byTooltip('Close reader'));
      await tester.pumpAndSettle();
      expect(currentLocation(container), '/chapters/1');
    });

    testWidgets('chapter detail opens shloka placeholder', (tester) async {
      final container = await pumpApp(tester, location: '/chapters/2');

      await tester.tap(find.text('Shloka 2.1'));
      await tester.pumpAndSettle();
      expect(currentLocation(container), '/shloka/BG.2.1');
      expect(
        find.text('[Sanskrit verse pending verification]'),
        findsOneWidget,
      );
    });
  });

  group('invalid routes', () {
    testWidgets('unknown path shows not-found', (tester) async {
      await pumpApp(tester, location: '/nope');
      expect(find.text('Page not found'), findsOneWidget);

      await tester.tap(find.text('Go to Home'));
      await tester.pumpAndSettle();
      expect(find.text('Begin with Chapter 1'), findsOneWidget);
    });

    testWidgets('chapter 19 shows error state', (tester) async {
      await pumpApp(tester, location: '/chapters/19');
      expect(find.text('Chapter not found'), findsOneWidget);
    });

    testWidgets('non-numeric chapter shows error state', (tester) async {
      await pumpApp(tester, location: '/chapters/abc');
      expect(find.text('Chapter not found'), findsOneWidget);
    });

    testWidgets('malformed verse id shows error state', (tester) async {
      await pumpApp(tester, location: '/shloka/2.47');
      expect(find.text('Verse not found'), findsOneWidget);
    });
  });
}
