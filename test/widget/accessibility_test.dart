import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_asset_pack_service.dart';
import '../helpers/pump_app.dart';

/// Accessibility checks for every primary screen (Milestone 14):
/// layout at 2x text, touch targets, labels, and text contrast.
void main() {
  const locations = [
    '/',
    '/chapters',
    '/chapters/1',
    '/chapters/2',
    '/read/1',
    '/read/2',
    '/shloka/BG.2.47',
    '/bookmarks',
    '/settings',
    '/storage',
    '/about',
  ];

  for (final location in locations) {
    group(location, () {
      testWidgets('renders at 2x text scale', (tester) async {
        await pumpApp(tester, location: location, textScale: 2);
        expect(tester.takeException(), isNull);
      });

      testWidgets('meets touch target and label guidelines', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpApp(tester, location: location);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });

      testWidgets('meets text contrast guideline', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpApp(tester, location: location);
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    });
  }

  testWidgets('chapter 2 download card meets guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, location: '/read/2', packs: FakeAssetPackService());
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });

  testWidgets('reader controls are labelled buttons for TalkBack', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, location: '/read/1');
    for (final tip in ['Close reader', 'Next scene', 'Bookmark scene']) {
      final node = tester.getSemantics(find.byTooltip(tip));
      expect(node.flagsCollection.isButton, isTrue, reason: tip);
      expect(node.tooltip, tip);
    }
    handle.dispose();
  });
}
