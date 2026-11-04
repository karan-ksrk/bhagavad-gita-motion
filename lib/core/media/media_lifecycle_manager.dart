import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:moksharan/core/media/scene_player.dart';

/// App-wide playback rules:
/// - only one scene player is active (playing) at a time;
/// - playback pauses when the app leaves the foreground and resumes when
///   it returns, if it was playing before.
class MediaLifecycleManager with WidgetsBindingObserver {
  new({WidgetsBinding? binding})
    : _binding = binding ?? WidgetsBinding.instance;

  final WidgetsBinding _binding;
  ScenePlayer? _active;
  bool _resumeOnForeground = false;

  ScenePlayer? get active => _active;

  void attach() => _binding.addObserver(this);

  /// Makes [player] the active one, pausing any other active player.
  void activate(ScenePlayer player) {
    final previous = _active;
    if (previous != null && !identical(previous, player)) {
      unawaited(previous.pause());
    }
    _active = player;
  }

  /// Forgets [player] if it is active (call before disposing it).
  void release(ScenePlayer player) {
    if (identical(_active, player)) {
      _active = null;
      _resumeOnForeground = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final player = _active;
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (player != null && player.state.value.isPlaying) {
          _resumeOnForeground = true;
          unawaited(player.pause());
        }
      case AppLifecycleState.resumed:
        if (player != null && _resumeOnForeground) {
          unawaited(player.play());
        }
        _resumeOnForeground = false;
    }
  }

  void dispose() => _binding.removeObserver(this);
}
