import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moksharan/core/media/media_lifecycle_manager.dart';
import 'package:moksharan/core/media/media_providers.dart';
import 'package:moksharan/core/media/scene_player.dart';
import 'package:moksharan/core/settings/app_settings.dart';
import 'package:moksharan/core/theme/app_colors.dart';
import 'package:moksharan/core/theme/app_tokens.dart';

/// Full-bleed scene video with poster fallback and playback controls.
///
/// - Shows [posterAsset] until the video is ready, and keeps it if the
///   video fails or is missing.
/// - Autoplays unless motion is reduced (in-app or system setting).
/// - Pauses while covered by another route (TickerMode) and resumes after.
/// - Registers with [MediaLifecycleManager] so only one scene plays.
/// - Disposes its player when removed.
class CinematicVideoView extends ConsumerStatefulWidget {
  const new({
    required this.posterAsset,
    super.key,
    this.videoAsset,
    this.loop = true,
    this.autoplay = true,
    this.showControls = true,
  });

  /// Flutter asset paths (e.g. `assets/posters/x.webp`).
  final String? posterAsset;
  final String? videoAsset;
  final bool loop;
  final bool autoplay;
  final bool showControls;

  @override
  ConsumerState<CinematicVideoView> createState() => _CinematicVideoViewState();
}

class _CinematicVideoViewState extends ConsumerState<CinematicVideoView> {
  late final ScenePlayer _player;
  late final MediaLifecycleManager _manager;
  ValueListenable<TickerModeData>? _tickerMode;
  bool _resumeWhenVisible = false;

  @override
  void initState() {
    super.initState();
    _player = ref.read(scenePlayerFactoryProvider)();
    _manager = ref.read(mediaLifecycleManagerProvider);
    _player.state.addListener(_onPlayerState);
    final video = widget.videoAsset;
    if (video != null) unawaited(_loadAndMaybePlay(video));
  }

  Future<void> _loadAndMaybePlay(String video) async {
    await _player.load(assetPath: video, loop: widget.loop);
    if (!mounted || !_player.state.value.hasVideo) return;
    final reduceMotion =
        ref.read(settingsProvider).reducedMotion ||
        MediaQuery.disableAnimationsOf(context);
    final visible = _tickerMode?.value.enabled ?? true;
    if (widget.autoplay && !reduceMotion && visible) await _play();
  }

  Future<void> _play() async {
    _manager.activate(_player);
    await _player.play();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = TickerMode.getValuesNotifier(context);
    if (!identical(notifier, _tickerMode)) {
      _tickerMode?.removeListener(_onVisibilityChanged);
      _tickerMode = notifier..addListener(_onVisibilityChanged);
    }
  }

  void _onVisibilityChanged() {
    final visible = _tickerMode?.value.enabled ?? true;
    if (!visible) {
      if (_player.state.value.isPlaying) {
        _resumeWhenVisible = true;
        unawaited(_player.pause());
      }
    } else if (_resumeWhenVisible) {
      _resumeWhenVisible = false;
      unawaited(_play());
    }
  }

  void _onPlayerState() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tickerMode?.removeListener(_onVisibilityChanged);
    _player.state.removeListener(_onPlayerState);
    _manager.release(_player);
    unawaited(_player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _player.state.value;
    final poster = widget.posterAsset;

    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Colors.black),
        if (poster != null)
          Image.asset(
            poster,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                const ColoredBox(color: AppColors.midnight),
          ),
        if (snapshot.hasVideo)
          ClipRect(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: 720,
                height: 720 / _player.aspectRatio,
                child: _player.buildView(),
              ),
            ),
          ),
        if (snapshot.status == PlayerStatus.error ||
            (widget.videoAsset == null && widget.showControls))
          const Positioned(
            top: AppSpacing.md,
            left: 0,
            right: 0,
            child: Center(child: _Badge('Video unavailable, showing still')),
          ),
        if (widget.showControls && snapshot.hasVideo)
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: _Controls(
                  snapshot: snapshot,
                  onPlayPause: () =>
                      unawaited(snapshot.isPlaying ? _player.pause() : _play()),
                  onReplay: () {
                    _manager.activate(_player);
                    unawaited(_player.replay());
                  },
                  onMute: () =>
                      unawaited(_player.setMuted(muted: !snapshot.isMuted)),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const new({
    required this.snapshot,
    required this.onPlayPause,
    required this.onReplay,
    required this.onMute,
  });

  final PlayerSnapshot snapshot;
  final VoidCallback onPlayPause;
  final VoidCallback onReplay;
  final VoidCallback onMute;

  @override
  Widget build(BuildContext context) {
    const color = AppColors.ivory;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.midnight.withValues(alpha: 0.55),
        borderRadius: AppRadius.button,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: snapshot.isPlaying ? 'Pause' : 'Play',
            icon: Icon(
              snapshot.isPlaying ? Icons.pause : Icons.play_arrow,
              color: color,
            ),
            onPressed: onPlayPause,
          ),
          IconButton(
            tooltip: 'Replay',
            icon: const Icon(Icons.replay, color: color),
            onPressed: onReplay,
          ),
          IconButton(
            tooltip: snapshot.isMuted ? 'Unmute' : 'Mute',
            icon: Icon(
              snapshot.isMuted ? Icons.volume_off : Icons.volume_up,
              color: color,
            ),
            onPressed: onMute,
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.midnight.withValues(alpha: 0.7),
        borderRadius: AppRadius.badge,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.ivory),
        ),
      ),
    );
  }
}
