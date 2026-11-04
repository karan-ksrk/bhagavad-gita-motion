import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moksharan/core/animation/effect_painters.dart';
import 'package:moksharan/core/settings/app_settings.dart';
import 'package:moksharan/core/theme/app_colors.dart';
import 'package:moksharan/domain/entities/content.dart';

/// Layered-motion scene: background art, optional character layers, and
/// data-driven effects.
///
/// Draw order: background > aura > layers > particles > feather glint.
/// One [AnimationController] drives every effect; it is created by a
/// [TickerProvider], so it stops automatically while the scene is
/// off-screen or covered (TickerMode). With reduced motion the clock does
/// not run: effects marked `static` render a still frame, effects marked
/// `hide` are not drawn.
class LayeredMotionView extends ConsumerStatefulWidget {
  const new({
    required this.backgroundAsset,
    required this.effects,
    super.key,
    this.layerAssets = const [],
  });

  /// Flutter asset paths, all 9:16 scene art aligned to each other.
  final String? backgroundAsset;
  final List<String> layerAssets;
  final List<Effect> effects;

  @override
  ConsumerState<LayeredMotionView> createState() => _LayeredMotionViewState();
}

class _LayeredMotionViewState extends ConsumerState<LayeredMotionView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: effectCycle,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncClock();
  }

  void _syncClock() {
    final reduce =
        ref.read(settingsProvider).reducedMotion ||
        MediaQuery.disableAnimationsOf(context);
    if (reduce) {
      _clock.stop();
    } else if (!_clock.isAnimating) {
      _clock.repeat();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild (and restart/stop the clock) when the setting changes.
    final reduce =
        ref.watch(settingsProvider.select((s) => s.reducedMotion)) ||
        MediaQuery.disableAnimationsOf(context);
    if (reduce == _clock.isAnimating) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncClock();
      });
    }

    Iterable<Effect> visible(EffectType type) => widget.effects.where(
      (e) =>
          e.enabled &&
          e.type == type &&
          !(reduce && e.reducedMotion == ReducedMotionBehavior.hide),
    );
    final Animation<double>? clock = reduce ? null : _clock;

    Widget effectLayer(Effect e, CustomPainter painter) => Positioned.fill(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(
            key: Key('effect-${e.effectId}'),
            painter: painter,
          ),
        ),
      ),
    );

    final stack = Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Colors.black),
        if (widget.backgroundAsset != null)
          Image.asset(
            widget.backgroundAsset!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                const ColoredBox(color: AppColors.midnight),
          ),
        for (final e in visible(EffectType.goldenAura))
          effectLayer(e, GoldenAuraPainter(effect: e, clock: clock)),
        for (final layer in widget.layerAssets)
          Image.asset(
            layer,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        for (final e in visible(EffectType.floatingParticles))
          effectLayer(e, FloatingParticlesPainter(effect: e, clock: clock)),
        for (final e in visible(EffectType.peacockFeather))
          effectLayer(e, FeatherGlintPainter(effect: e, clock: clock)),
      ],
    );

    // Background drift: a very slow zoom of the whole composition, so
    // effects stay locked to the art.
    final drift = visible(EffectType.backgroundDrift).firstOrNull;
    if (drift == null || clock == null) return ClipRect(child: stack);
    return ClipRect(
      child: AnimatedBuilder(
        animation: clock,
        child: stack,
        builder: (_, child) {
          final wave = 0.5 - 0.5 * math.cos(clock.value * 2 * math.pi);
          return Transform.scale(
            scale: 1 + 0.04 * drift.intensity * wave,
            child: child,
          );
        },
      ),
    );
  }
}
