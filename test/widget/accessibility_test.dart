import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

/// Every primary screen must render without layout overflow at 2x text
/// scale. Overflow errors fail the test automatically.
void main() {
  const locations = [
    '/',
    '/chapters',
    '/chapters/1',
    '/read/1',
    '/shloka/BG.2.47',
    '/bookmarks',
    '/settings',
  ];

  for (final location in locations) {
    testWidgets('$location renders at 2x text scale', (tester) async {
      await pumpApp(tester, location: location, textScale: 2);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tappable controls meet touch target guideline', (tester) async {
    await pumpApp(tester);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  });

  testWidgets('home text meets contrast guideline', (tester) async {
    await pumpApp(tester);
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  });
}
