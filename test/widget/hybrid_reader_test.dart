import 'package:flutter_test/flutter_test.dart';
import 'package:moksharan/features/reader/renderers/manga_panel_renderer.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('next and previous scene buttons', (tester) async {
    await pumpApp(tester, location: '/read/1');

    expect(find.byTooltip('Previous scene'), findsNothing); // First scene.
    await tester.tap(find.byTooltip('Next scene'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 3'), findsOneWidget);

    await tester.tap(find.byTooltip('Next scene'));
    await tester.pumpAndSettle();
    expect(find.text('3 / 3'), findsOneWidget);
    expect(find.byTooltip('Next scene'), findsNothing); // Last scene.

    await tester.tap(find.byTooltip('Previous scene'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 3'), findsOneWidget);
  });

  testWidgets('verse chip opens the shloka screen', (tester) async {
    final container = await pumpApp(tester, location: '/read/1');

    expect(find.text('Verse 1.1'), findsOneWidget);
    await tester.tap(find.text('Verse 1.1'));
    await tester.pumpAndSettle();
    expect(currentLocation(container), '/shloka/BG.1.1');
  });

  testWidgets('each scene shows its own verse chip', (tester) async {
    await pumpApp(tester, location: '/read/1');
    await tester.tap(find.byTooltip('Next scene'));
    await tester.pumpAndSettle();
    expect(find.text('Verse 1.14'), findsOneWidget);
    expect(find.text('Verse 1.1'), findsNothing);
  });

  testWidgets('manga panels advance on tap and loop at the end', (
    tester,
  ) async {
    await pumpApp(tester, location: '/read/1');
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.byTooltip('Next scene'));
      await tester.pumpAndSettle();
    }
    final manga = find.byType(MangaPanelRenderer);
    expect(manga, findsOneWidget);

    // Panel 1: narration caption with its kind tag.
    expect(find.text('Panel 1 / 4  ·  Tap to continue'), findsOneWidget);
    expect(find.text('Narration'), findsOneWidget);

    for (final n in [2, 3]) {
      await tester.tap(manga);
      await tester.pumpAndSettle();
      expect(find.text('Panel $n / 4  ·  Tap to continue'), findsOneWidget);
    }
    await tester.tap(manga);
    await tester.pumpAndSettle();
    expect(find.text('Panel 4 / 4  ·  Tap to restart'), findsOneWidget);

    await tester.tap(manga);
    await tester.pumpAndSettle();
    expect(find.text('Panel 1 / 4  ·  Tap to continue'), findsOneWidget);
  });

  testWidgets('manga speech bubble shows speaker and kind', (tester) async {
    await pumpApp(tester, location: '/read/2');

    expect(find.text('Krishna'), findsOneWidget);
    expect(find.text('Retelling'), findsOneWidget);
    await tester.tap(find.byType(MangaPanelRenderer));
    await tester.pumpAndSettle();
    expect(find.text('Arjuna'), findsOneWidget);
  });

  testWidgets('panel images expose alt text to screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, location: '/read/2');
    expect(
      find.bySemanticsLabel(RegExp('Krishna turns in the chariot seat')),
      findsOneWidget,
    );
    handle.dispose();
  });
}
