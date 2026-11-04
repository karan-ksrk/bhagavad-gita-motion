import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moksharan/core/animation/effect_painters.dart';
import 'package:moksharan/domain/entities/content.dart';

Effect _effect(EffectType type, {double intensity = 0.5}) => Effect(
  effectId: type.wire,
  type: type,
  enabled: true,
  anchor: const Anchor(x: 0.4, y: 0.4),
  scale: 0.4,
  intensity: intensity,
  reducedMotion: ReducedMotionBehavior.static_,
);

void _paint(EffectPainter painter) {
  final recorder = PictureRecorder();
  painter.paint(Canvas(recorder), const Size(360, 780));
  recorder.endRecording().dispose();
}

void main() {
  test('every painter paints at many times and as a still frame', () {
    for (final type in [
      EffectType.goldenAura,
      EffectType.floatingParticles,
      EffectType.peacockFeather,
    ]) {
      final e = _effect(type);
      for (final v in [0.0, 0.13, 0.5, 0.99]) {
        final clock = AlwaysStoppedAnimation<double>(v);
        final painter = switch (type) {
          EffectType.goldenAura => GoldenAuraPainter(effect: e, clock: clock),
          EffectType.floatingParticles => FloatingParticlesPainter(
            effect: e,
            clock: clock,
          ),
          _ => FeatherGlintPainter(effect: e, clock: clock),
        };
        _paint(painter);
      }
      // Still frame (reduced motion).
      _paint(GoldenAuraPainter(effect: e));
    }
  });

  test('particle count scales with intensity, with a floor', () {
    expect(
      FloatingParticlesPainter(
        effect: _effect(EffectType.floatingParticles, intensity: 1),
      ).count,
      60,
    );
    expect(
      FloatingParticlesPainter(
        effect: _effect(EffectType.floatingParticles, intensity: 0),
      ).count,
      8,
    );
  });

  test('particles are deterministic for a seed', () {
    final e = _effect(EffectType.floatingParticles);
    final a = FloatingParticlesPainter(effect: e, seed: 3);
    final b = FloatingParticlesPainter(effect: e, seed: 3);
    expect(a.count, b.count);
  });

  test('repaints only when effect or clock changes', () {
    final e = _effect(EffectType.goldenAura);
    const clock = AlwaysStoppedAnimation<double>(0);
    final a = GoldenAuraPainter(effect: e, clock: clock);
    expect(
      a.shouldRepaint(GoldenAuraPainter(effect: e, clock: clock)),
      isFalse,
    );
    expect(a.shouldRepaint(GoldenAuraPainter(effect: e)), isTrue);
  });
}
