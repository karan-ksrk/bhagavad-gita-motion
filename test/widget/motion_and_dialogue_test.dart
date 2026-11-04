import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moksharan/core/animation/layered_motion_view.dart';
import 'package:moksharan/core/settings/app_settings.dart';
import 'package:moksharan/domain/entities/content.dart';
import 'package:moksharan/features/reader/dialogue_overlay.dart';

import '../helpers/prefs.dart';

Effect _effect(
  String id,
  EffectType type, {
  ReducedMotionBehavior rm = ReducedMotionBehavior.static_,
  bool enabled = true,
}) => Effect(
  effectId: id,
  type: type,
  enabled: enabled,
  anchor: const Anchor(x: 0.4, y: 0.4),
  scale: 0.4,
  intensity: 0.6,
  reducedMotion: rm,
);

final List<Effect> _effects = [
  _effect('aura', EffectType.goldenAura),
  _effect(
    'particles',
    EffectType.floatingParticles,
    rm: ReducedMotionBehavior.hide,
  ),
  _effect('feather', EffectType.peacockFeather),
  _effect('off', EffectType.goldenAura, enabled: false),
];

Future<ProviderContainer> _pump(
  WidgetTester tester,
  Widget child, {
  bool reducedMotion = false,
  AppLanguage language = AppLanguage.english,
}) async {
  final container = ProviderContainer(overrides: [await prefsOverride()]);
  addTearDown(container.dispose);
  container.read(settingsProvider.notifier)
    ..setReducedMotion(value: reducedMotion)
    ..setLanguage(language);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: Scaffold(body: child)),
    ),
  );
  await tester.pump();
  return container;
}

Dialogue _line(
  String id,
  DialogueType type, {
  String? en,
  String? hi,
  String? ref,
  Speaker speaker = Speaker.krishna,
}) => Dialogue(
  dialogueId: id,
  speaker: speaker,
  type: type,
  sourceRef: ref,
  text: LocalizedText(en: en, hi: hi),
  revealOrder: 1,
  textStatus: TextStatus.draft,
);

void main() {
  group('LayeredMotionView', () {
    testWidgets('draws enabled effects and animates', (tester) async {
      await _pump(
        tester,
        LayeredMotionView(backgroundAsset: null, effects: _effects),
      );

      expect(find.byKey(const Key('effect-aura')), findsOneWidget);
      expect(find.byKey(const Key('effect-particles')), findsOneWidget);
      expect(find.byKey(const Key('effect-feather')), findsOneWidget);
      expect(find.byKey(const Key('effect-off')), findsNothing);
      expect(tester.hasRunningAnimations, isTrue);
    });

    testWidgets('reduced motion: still frame, hide-marked effects removed', (
      tester,
    ) async {
      await _pump(
        tester,
        LayeredMotionView(backgroundAsset: null, effects: _effects),
        reducedMotion: true,
      );
      await tester.pump();

      expect(find.byKey(const Key('effect-aura')), findsOneWidget);
      expect(find.byKey(const Key('effect-particles')), findsNothing);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('stops animating when covered (TickerMode off)', (
      tester,
    ) async {
      await _pump(
        tester,
        TickerMode(
          enabled: false,
          child: LayeredMotionView(backgroundAsset: null, effects: _effects),
        ),
      );
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('DialogueOverlay', () {
    final lines = [
      _line('d1', DialogueType.creative, en: 'First line', hi: 'पहली'),
      _line(
        'd2',
        DialogueType.verseParaphrase,
        en: 'Second line',
        ref: 'BG.1.1',
        speaker: Speaker.narrator,
      ),
    ];

    testWidgets('reveals one line at a time with labels', (tester) async {
      await _pump(tester, DialogueOverlay(dialogues: lines, title: 'Scene'));

      expect(find.text('Scene'), findsOneWidget);
      expect(find.text('First line'), findsOneWidget);
      expect(find.text('Krishna'), findsOneWidget);
      expect(find.text('Retelling'), findsOneWidget);
      expect(find.text('Line 1 / 2'), findsOneWidget);
      expect(find.text('Second line'), findsNothing);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Second line'), findsOneWidget);
      expect(find.text('Paraphrase of BG.1.1'), findsOneWidget);
      expect(find.text('Narrator'), findsOneWidget);
      expect(find.text('Start over'), findsOneWidget);

      await tester.tap(find.text('Start over'));
      await tester.pumpAndSettle();
      expect(find.text('First line'), findsOneWidget);
    });

    testWidgets('tapping the card advances', (tester) async {
      await _pump(tester, DialogueOverlay(dialogues: lines));
      await tester.tap(find.text('First line'));
      await tester.pumpAndSettle();
      expect(find.text('Second line'), findsOneWidget);
    });

    testWidgets('uses Hindi when chosen, falls back to English', (
      tester,
    ) async {
      await _pump(
        tester,
        DialogueOverlay(dialogues: lines),
        language: AppLanguage.hindi,
      );
      expect(find.text('पहली'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Second line'), findsOneWidget); // No Hindi text.
    });
  });
}
