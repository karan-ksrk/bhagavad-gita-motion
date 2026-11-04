import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'package:moksharan/core/animation/effect_geometry.dart';
import 'package:moksharan/core/theme/app_colors.dart';
import 'package:moksharan/domain/entities/content.dart';

/// Length of one full effect cycle. Every effect derives its motion from
/// a single repeating controller of this duration.
const effectCycle = Duration(seconds: 20);

/// Warm pale gold used for glow cores: visible over gold artwork.
const _glowCore = Color(0xFFFFEDB0);

double _seconds(Animation<double>? clock) =>
    (clock?.value ?? 0) * effectCycle.inMilliseconds / 1000;

/// Base for effect painters: geometry from the scene art rect, time from
/// an optional [clock] (null renders a still frame, used for reduced
/// motion).
abstract class EffectPainter extends CustomPainter {
  new({required this.effect, this.clock}) : super(repaint: clock);

  final Effect effect;
  final Animation<double>? clock;

  @override
  bool shouldRepaint(covariant EffectPainter oldDelegate) =>
      oldDelegate.effect != effect || oldDelegate.clock != clock;
}

/// Soft golden glow that breathes slowly (4 s period, +/- 8% radius).
class GoldenAuraPainter extends EffectPainter {
  new({required super.effect, super.clock});

  final Paint _paint = Paint()..blendMode = BlendMode.screen;
  Shader? _shader;
  double _shaderRadius = 0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = coverRect(size);
    final center = anchorOffset(rect, effect.anchor);
    final radius = effect.scale * rect.width;
    if (radius <= 0) return;

    // Shader is built once per size at the origin, then translated and
    // scaled each frame: no per-frame allocation.
    if (_shader == null || _shaderRadius != radius) {
      _shaderRadius = radius;
      final i = effect.intensity;
      _shader = RadialGradient(
        colors: [
          _glowCore.withValues(alpha: 0.65 * i),
          AppColors.gold.withValues(alpha: 0.3 * i),
          AppColors.gold.withValues(alpha: 0),
        ],
        stops: const [0, 0.45, 1],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius));
      _paint.shader = _shader;
    }

    final t = _seconds(clock);
    final pulse = 1 + 0.08 * math.sin(t * 2 * math.pi / 4);
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..scale(pulse)
      ..drawCircle(Offset.zero, radius, _paint)
      ..restore();
  }
}

/// Golden motes drifting slowly upward with a gentle sway around the
/// anchor. Particle parameters are generated once; positions are pure
/// functions of time, so nothing is allocated per frame.
class FloatingParticlesPainter extends EffectPainter {
  new({required super.effect, super.clock, int seed = 7})
    : count = math.max(8, (60 * effect.intensity).round()) {
    final rnd = math.Random(seed);
    _x = Float32List(count);
    _phase = Float32List(count);
    _speed = Float32List(count);
    _size = Float32List(count);
    for (var i = 0; i < count; i++) {
      _x[i] = rnd.nextDouble() * 2 - 1;
      _phase[i] = rnd.nextDouble();
      _speed[i] = 0.02 + rnd.nextDouble() * 0.03; // fraction of span per s
      _size[i] = 2.2 + rnd.nextDouble() * 2.8;
    }
  }

  /// Fixed for the painter's lifetime.
  final int count;
  late final Float32List _x;
  late final Float32List _phase;
  late final Float32List _speed;
  late final Float32List _size;

  static const _buckets = 6;
  static final List<Paint> _paints = [
    for (var b = 1; b <= _buckets; b++)
      Paint()..color = _glowCore.withValues(alpha: b / _buckets),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = coverRect(size);
    final center = anchorOffset(rect, effect.anchor);
    final r = effect.scale * rect.width;
    if (r <= 0) return;
    final t = _seconds(clock);

    for (var i = 0; i < count; i++) {
      final progress = (_phase[i] + t * _speed[i]) % 1; // 0 bottom, 1 top
      final y = center.dy + r - progress * 2 * r;
      final sway = math.sin(t * 0.6 + _phase[i] * 2 * math.pi) * r * 0.06;
      final x = center.dx + _x[i] * r + sway;
      final fade = math.sin(progress * math.pi) * effect.intensity;
      final bucket = (fade * _buckets).floor().clamp(0, _buckets - 1);
      if (fade <= 0.02) continue;
      canvas.drawCircle(Offset(x, y), _size[i], _paints[bucket]);
    }
  }
}

/// Stand-in for peacock-feather motion until a separate Krishna layer
/// exists (D-125): a soft iridescent glint at the feather that rises and
/// fades every 6 s. With a layer, this becomes a sway transform.
class FeatherGlintPainter extends EffectPainter {
  new({required super.effect, super.clock});

  final Paint _paint = Paint()..blendMode = BlendMode.screen;
  Shader? _shader;
  double _shaderRadius = 0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = coverRect(size);
    final center = anchorOffset(rect, effect.anchor);
    final radius = math.max(8, effect.scale * rect.width);
    if (_shader == null || _shaderRadius != radius) {
      _shaderRadius = radius.toDouble();
      _shader =
          RadialGradient(
            colors: [
              _glowCore.withValues(alpha: 0.75),
              AppColors.gold.withValues(alpha: 0.25),
              AppColors.gold.withValues(alpha: 0),
            ],
            stops: const [0, 0.5, 1],
          ).createShader(
            Rect.fromCircle(center: Offset.zero, radius: _shaderRadius),
          );
      _paint.shader = _shader;
    }

    final t = _seconds(clock);
    // Ease in and out over a 6 s cycle; still frame shows a soft glint.
    final phase = clock == null ? 0.5 : (t % 6) / 6;
    final strength =
        Curves.easeInOut.transform(math.sin(phase * math.pi)) *
        effect.intensity;
    if (strength <= 0.02) return;
    canvas
      ..save()
      ..translate(center.dx, center.dy - phase * radius * 0.4)
      ..scale(0.6 + 0.4 * strength)
      ..drawCircle(Offset.zero, _shaderRadius, _paint)
      ..restore();
  }
}
