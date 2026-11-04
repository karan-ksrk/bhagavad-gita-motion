import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moksharan/data/repositories/prefs_user_data_repository.dart';
import 'package:moksharan/data/repositories/user_data_providers.dart';

import '../helpers/pump_app.dart';

const Map<String, Object> _savedAtScene2 = {
  PrefsUserDataRepository.progressKey:
      '{"last_chapter_id":"chapter_01","chapters":{"chapter_01":'
      '{"scene_id":"ch01_scene_002","visited":["ch01_scene_001",'
      '"ch01_scene_002"],"updated_at":"2026-11-04T10:00:00.000"}}}',
};

void main() {
  testWidgets('home shows continue reading and resumes the reader', (
    tester,
  ) async {
    final container = await pumpApp(tester, prefs: _savedAtScene2);

    expect(find.text('Chapter 1 · Scene 2 of 3'), findsOneWidget);
    expect(find.text('[Pilot] Between the two armies'), findsOneWidget);

    await tester.tap(find.text('Chapter 1 · Scene 2 of 3'));
    await tester.pumpAndSettle();
    expect(currentLocation(container), '/read/1');
    expect(find.text('2 / 3'), findsOneWidget);
  });

  testWidgets('reading saves the position', (tester) async {
    final container = await pumpApp(tester, location: '/read/1');
    await tester.tap(find.byTooltip('Next scene'));
    await tester.pumpAndSettle();

    final saved = container.read(progressProvider);
    expect(saved.lastChapterId, 'chapter_01');
    expect(saved.last?.sceneId, 'ch01_scene_002');
  });

  testWidgets('chapter list shows scenes read', (tester) async {
    await pumpApp(tester, location: '/chapters', prefs: _savedAtScene2);
    expect(find.text('2 of 3 scenes read'), findsOneWidget);
  });

  testWidgets('verse bookmark appears in Bookmarks and opens the verse', (
    tester,
  ) async {
    final container = await pumpApp(tester, location: '/shloka/BG.1.1');

    await tester.tap(find.byTooltip('Bookmark verse'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Remove verse bookmark'), findsOneWidget);

    container.router.go('/bookmarks');
    await tester.pumpAndSettle();
    expect(find.text('Verse 1.1'), findsOneWidget);

    await tester.tap(find.text('Verse 1.1'));
    await tester.pumpAndSettle();
    expect(currentLocation(container), '/shloka/BG.1.1');
  });

  testWidgets('scene bookmark opens the reader at that scene', (tester) async {
    final container = await pumpApp(tester, location: '/read/1');
    await tester.tap(find.byTooltip('Next scene'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Bookmark scene'));
    await tester.pumpAndSettle();

    container.router.go('/bookmarks');
    await tester.pumpAndSettle();
    expect(find.text('[Pilot] Between the two armies'), findsOneWidget);
    expect(find.text('Chapter 1 · Scene'), findsOneWidget);

    await tester.tap(find.text('[Pilot] Between the two armies'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 3'), findsOneWidget);
  });

  testWidgets('remove bookmark from the list', (tester) async {
    final container = await pumpApp(tester);
    container.read(bookmarksProvider.notifier).toggleVerse('BG.1.2');
    container.router.go('/bookmarks');
    await tester.pumpAndSettle();
    expect(find.text('Verse 1.2'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove bookmark'));
    await tester.pumpAndSettle();
    expect(find.text('No bookmarks yet'), findsOneWidget);
  });

  testWidgets('clear progress asks first and keeps bookmarks', (tester) async {
    final container = await pumpApp(
      tester,
      location: '/settings',
      prefs: _savedAtScene2,
    );
    container.read(bookmarksProvider.notifier).toggleVerse('BG.1.1');

    await tester.ensureVisible(find.text('Clear reading progress'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear reading progress'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(container.read(progressProvider).last, isNotNull);

    await tester.ensureVisible(find.text('Clear reading progress'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear reading progress'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Clear'));
    await tester.pumpAndSettle();
    expect(container.read(progressProvider).last, isNull);
    expect(container.read(bookmarksProvider), hasLength(1));
    expect(find.text('Reading progress cleared'), findsOneWidget);
  });

  testWidgets('about screen lists sources and font credit', (tester) async {
    await pumpApp(tester, location: '/about');
    expect(find.text('About and sources'), findsOneWidget);
    expect(find.textContaining('Kashinath Trimbak Telang'), findsOneWidget);
    expect(find.textContaining('SIL Open Font License'), findsOneWidget);
  });
}
