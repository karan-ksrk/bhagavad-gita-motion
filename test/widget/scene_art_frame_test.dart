import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moksharan/core/widgets/scene_art_frame.dart';
import 'package:moksharan/features/reader/dialogue_overlay.dart';

import '../helpers/pump_app.dart';

Future<void> _pumpFrame(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    const MaterialApp(
      home: SceneArtFrame(
        backdropAsset: 'assets/posters/ch01_scene001_poster.webp',
        child: ColoredBox(key: Key('art'), color: Colors.red),
      ),
    ),
  );
}

void main() {
  test('wide threshold', () {
    expect(SceneArtFrame.isWide(const Size(411, 891)), isFalse); // Phone.
    expect(SceneArtFrame.isWide(const Size(777, 1164)), isFalse); // Tablet.
    expect(SceneArtFrame.isWide(const Size(1164, 777)), isTrue); // Landscape.
  });

  testWidgets('portrait: art fills the screen, no backdrop', (tester) async {
    await _pumpFrame(tester, const Size(400, 860));
    expect(tester.getSize(find.byKey(const Key('art'))), const Size(400, 860));
    expect(find.byKey(const Key('scene-art-backdrop')), findsNothing);
  });

  testWidgets('landscape: whole 9:16 art centred over blurred backdrop', (
    tester,
  ) async {
    await _pumpFrame(tester, const Size(1600, 1000));
    final art = tester.getRect(find.byKey(const Key('art')));
    expect(art.height, 1000);
    expect(art.width, closeTo(1000 * 9 / 16, 0.01));
    expect(art.center.dx, closeTo(800, 0.01));
    expect(find.byKey(const Key('scene-art-backdrop')), findsOneWidget);
  });

  testWidgets('landscape reader: dialogue card capped at readable width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(tester, location: '/read/1');

    expect(find.byKey(const Key('scene-art-column')), findsOneWidget);
    final card = tester.getSize(find.byType(DialogueOverlay).first);
    expect(card.width, lessThanOrEqualTo(ReadableWidth.maxWidth));
  });
}
