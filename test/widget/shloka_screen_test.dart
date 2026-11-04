import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moksharan/core/settings/app_settings.dart';

import '../helpers/pump_app.dart';

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows placeholder verse with status, tag, and sources', (
    tester,
  ) async {
    await pumpApp(tester, location: '/shloka/BG.1.1');

    expect(find.text('Draft · not verified'), findsWidgets);
    expect(find.text('PLACEHOLDER'), findsOneWidget);
    expect(find.text('[Sanskrit verse pending verification]'), findsOneWidget);
    expect(find.text('SOURCES'), findsOneWidget);
    expect(
      find.textContaining('Sanskrit: Shrimad Bhagavad Gita'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Kashinath Trimbak Telang, 1882'),
      findsOneWidget,
    );
  });

  testWidgets('Hindi selected: Hindi source attributed', (tester) async {
    final container = await pumpApp(tester, location: '/shloka/BG.1.1');
    container.read(settingsProvider.notifier).setLanguage(AppLanguage.hindi);
    await tester.pumpAndSettle();

    expect(find.text('HINDI EXPLANATION'), findsOneWidget);
    expect(
      find.textContaining('Moksharan original Hindi explanations'),
      findsOneWidget,
    );
  });

  testWidgets('next and previous verse navigation', (tester) async {
    final container = await pumpApp(tester, location: '/shloka/BG.1.1');

    await _scrollTo(tester, find.textContaining('Verse 1.2'));
    await tester.tap(find.textContaining('Verse 1.2'));
    await tester.pumpAndSettle();
    expect(currentLocation(container), '/shloka/BG.1.2');
    expect(find.text('Shloka 1.2'), findsOneWidget);

    await _scrollTo(tester, find.textContaining('Verse 1.1'));
    await tester.tap(find.textContaining('Verse 1.1'));
    await tester.pumpAndSettle();
    expect(currentLocation(container), '/shloka/BG.1.1');
  });

  testWidgets('last verse in content continues into the next chapter', (
    tester,
  ) async {
    await pumpApp(tester, location: '/shloka/BG.1.47');
    await _scrollTo(tester, find.textContaining('Verse 2.1'));
    expect(find.textContaining('Verse 2.1'), findsOneWidget);
  });

  testWidgets('verse not in content shows empty state', (tester) async {
    await pumpApp(tester, location: '/shloka/BG.2.47');
    expect(find.text('Verse not added yet'), findsOneWidget);
  });

  testWidgets('app-bar toggle hides transliteration', (tester) async {
    await pumpApp(tester, location: '/shloka/BG.1.1');
    expect(find.text('TRANSLITERATION'), findsOneWidget);
    await tester.tap(find.byTooltip('Show or hide transliteration'));
    await tester.pumpAndSettle();
    expect(find.text('TRANSLITERATION'), findsNothing);
  });

  testWidgets('switching language keeps the reader on the same scene', (
    tester,
  ) async {
    final container = await pumpApp(tester, location: '/read/1');
    await tester.tap(find.byTooltip('Next scene'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 3'), findsOneWidget);

    container.read(settingsProvider.notifier).setLanguage(AppLanguage.hindi);
    await tester.pumpAndSettle();
    expect(find.text('2 / 3'), findsOneWidget);
  });

  testWidgets('Devanagari renders in the bundled verse font', (tester) async {
    // Generic conjuncts (not scripture) to exercise shaping and wrapping.
    const sample = 'क्ष त्र ज्ञ श्र द्ध हृ — हिन्दी पाठ';
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            child: Text(
              sample,
              style: TextStyle(fontFamily: 'TiroDevanagariSanskrit'),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    final size = tester.getSize(find.text(sample));
    expect(size.height, greaterThan(20)); // Wrapped onto multiple lines.
  });
}
