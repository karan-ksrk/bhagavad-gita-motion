import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

enum PlayerStatus { idle, loading, ready, playing, paused, completed, error }

/// Immutable view of a player's state.
@immutable
class PlayerSnapshot {
  const new({this.status = PlayerStatus.idle, this.isMuted = true, this.error});

  final PlayerStatus status;
  final bool isMuted;
  final Object? error;

  bool get isPlaying => status == PlayerStatus.playing;

  /// True once frames can be shown (poster can be hidden).
  bool get hasVideo =>
      status == PlayerStatus.ready ||
      status == PlayerStatus.playing ||
      status == PlayerStatus.paused ||
      status == PlayerStatus.completed;

  PlayerSnapshot copyWith({
    PlayerStatus? status,
    bool? isMuted,
    Object? error,
  }) {
    return PlayerSnapshot(
      status: status ?? this.status,
      isMuted: isMuted ?? this.isMuted,
      error: error ?? this.error,
    );
  }
}

/// Plays one scene video. The reader owns one per visible cinematic
/// scene and must call [dispose] when the scene leaves the screen.
///
/// Implementations: `VideoScenePlayer` (device), fakes in tests.
abstract interface class ScenePlayer {
  ValueListenable<PlayerSnapshot> get state;

  /// Width / height of the video, valid once [PlayerSnapshot.hasVideo].
  double get aspectRatio;

  /// Loads a video by media path: a Flutter asset path (e.g.
  /// `assets/videos/ch01_scene001_loop.mp4`) or an absolute file path in
  /// an installed asset pack. Errors are reported through [state], never
  /// thrown.
  Future<void> load({required String assetPath, required bool loop});

  Future<void> play();
  Future<void> pause();

  /// Restarts from the beginning and plays.
  Future<void> replay();

  Future<void> setMuted({required bool muted});

  /// The widget that renders video frames.
  Widget buildView();

  /// Releases decoder resources. The player is unusable afterwards.
  Future<void> dispose();
}

typedef ScenePlayerFactory = ScenePlayer Function();
