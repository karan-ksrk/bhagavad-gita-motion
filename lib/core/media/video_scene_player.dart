import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:moksharan/core/media/media_source.dart';
import 'package:moksharan/core/media/scene_player.dart';
import 'package:video_player/video_player.dart';

/// [ScenePlayer] backed by the `video_player` plugin (ExoPlayer on
/// Android).
class VideoScenePlayer implements ScenePlayer {
  final ValueNotifier<PlayerSnapshot> _state = ValueNotifier(
    const PlayerSnapshot(),
  );
  VideoPlayerController? _controller;
  bool _loop = true;
  bool _disposed = false;

  @override
  ValueListenable<PlayerSnapshot> get state => _state;

  @override
  double get aspectRatio {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return 9 / 16;
    return c.value.aspectRatio;
  }

  void _set(PlayerSnapshot snapshot) {
    if (!_disposed) _state.value = snapshot;
  }

  @override
  Future<void> load({required String assetPath, required bool loop}) async {
    _loop = loop;
    _set(_state.value.copyWith(status: PlayerStatus.loading));

    final options = VideoPlayerOptions(mixWithOthers: true);
    final controller = isBundledMedia(assetPath)
        ? VideoPlayerController.asset(assetPath, videoPlayerOptions: options)
        : VideoPlayerController.file(
            File(assetPath),
            videoPlayerOptions: options,
          );
    _controller = controller;
    try {
      await controller.initialize();
      if (_disposed) {
        await controller.dispose();
        return;
      }
      await controller.setLooping(loop);
      await controller.setVolume(_state.value.isMuted ? 0 : 1);
      controller.addListener(_onControllerUpdate);
      _set(_state.value.copyWith(status: PlayerStatus.ready));
    } on Object catch (e) {
      debugPrint('VideoScenePlayer: failed to load $assetPath: $e');
      _set(
        PlayerSnapshot(
          status: PlayerStatus.error,
          isMuted: _state.value.isMuted,
          error: e,
        ),
      );
    }
  }

  void _onControllerUpdate() {
    final c = _controller;
    if (c == null || _disposed) return;
    final v = c.value;
    final current = _state.value;

    if (v.hasError) {
      _set(
        current.copyWith(status: PlayerStatus.error, error: v.errorDescription),
      );
    } else if (v.isPlaying) {
      if (current.status != PlayerStatus.playing) {
        _set(current.copyWith(status: PlayerStatus.playing));
      }
    } else if (!_loop && v.isCompleted) {
      if (current.status != PlayerStatus.completed) {
        _set(current.copyWith(status: PlayerStatus.completed));
      }
    } else if (current.status == PlayerStatus.playing) {
      _set(current.copyWith(status: PlayerStatus.paused));
    }
  }

  @override
  Future<void> play() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || _disposed) return;
    if (_state.value.status == PlayerStatus.completed) {
      await replay();
      return;
    }
    await c.play();
  }

  @override
  Future<void> pause() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || _disposed) return;
    await c.pause();
  }

  @override
  Future<void> replay() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || _disposed) return;
    await c.seekTo(Duration.zero);
    await c.play();
  }

  @override
  Future<void> setMuted({required bool muted}) async {
    _set(_state.value.copyWith(isMuted: muted));
    final c = _controller;
    if (c != null && c.value.isInitialized && !_disposed) {
      await c.setVolume(muted ? 0 : 1);
    }
  }

  @override
  Widget buildView() {
    final c = _controller;
    if (c == null) return const SizedBox.shrink();
    return VideoPlayer(c);
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    final c = _controller;
    _controller = null;
    c?.removeListener(_onControllerUpdate);
    await c?.dispose();
    _state.dispose();
  }
}
