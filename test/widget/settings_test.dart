import 'package:flutter_test/flutter_test.dart';
import 'package:moksharan/core/settings/app_settings.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('language selector updates settings', (tester) async {
    final container = await pumpApp(tester, location: '/settings');
    expect(container.read(settingsProvider).language, AppLanguage.english);

    await tester.tap(find.text('हिन्दी'));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).language, AppLanguage.hindi);
  });

  testWidgets('language choice changes shloka translation label', (
    tester,
  ) async {
    final container = await pumpApp(tester, location: '/shloka/BG.1.1');
    expect(find.text('ENGLISH TRANSLATION'), findsOneWidget);

    container.read(settingsProvider.notifier).setLanguage(AppLanguage.hindi);
    await tester.pumpAndSettle();
    expect(find.text('HINDI EXPLANATION'), findsOneWidget);
  });

  testWidgets('transliteration toggle hides transliteration', (tester) async {
    final container = await pumpApp(tester, location: '/shloka/BG.1.1');
    expect(find.text('TRANSLITERATION'), findsOneWidget);

    container
        .read(settingsProvider.notifier)
        .setShowTransliteration(value: false);
    await tester.pumpAndSettle();
    expect(find.text('TRANSLITERATION'), findsNothing);
  });

  testWidgets('reduce motion switch updates settings', (tester) async {
    final container = await pumpApp(tester, location: '/settings');

    await tester.tap(find.text('Reduce motion'));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).reducedMotion, isTrue);
  });

  testWidgets('settings shows system reduced-motion state', (tester) async {
    await pumpApp(tester, location: '/settings', disableAnimations: true);
    expect(
      find.text('System setting is also reducing animations'),
      findsOneWidget,
    );
  });
}
