import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:moksharan/core/media/scene_player.dart';

/// In-memory [ScenePlayer] for tests. Records calls; [failLoad] simulates
/// a missing or corrupt video.
class FakeScenePlayer implements ScenePlayer {
  new({this.failLoad = false});

  final bool failLoad;
  final ValueNotifier<PlayerSnapshot> _state = ValueNotifier(
    const PlayerSnapshot(),
  );
  final calls = <String>[];
  String? loadedPath;
  bool? loop;
  bool disposed = false;

  @override
  ValueListenable<PlayerSnapshot> get state => _state;

  @override
  double get aspectRatio => 9 / 16;

  @override
  Future<void> load({required String assetPath, required bool loop}) async {
    calls.add('load');
    loadedPath = assetPath;
    this.loop = loop;
    _state.value = failLoad
        ? _state.value.copyWith(status: PlayerStatus.error, error: 'missing')
        : _state.value.copyWith(status: PlayerStatus.ready);
  }

  @override
  Future<void> play() async {
    calls.add('play');
    _state.value = _state.value.copyWith(status: PlayerStatus.playing);
  }

  @override
  Future<void> pause() async {
    calls.add('pause');
    if (_state.value.isPlaying) {
      _state.value = _state.value.copyWith(status: PlayerStatus.paused);
    }
  }

  @override
  Future<void> replay() async {
    calls.add('replay');
    _state.value = _state.value.copyWith(status: PlayerStatus.playing);
  }

  @override
  Future<void> setMuted({required bool muted}) async {
    calls.add('mute:$muted');
    _state.value = _state.value.copyWith(isMuted: muted);
  }

  @override
  Widget buildView() => const SizedBox(key: Key('fake-video'));

  @override
  Future<void> dispose() async {
    calls.add('dispose');
    disposed = true;
  }
}

/// Factory that keeps every player it creates, for assertions.
class FakePlayerFactory {
  new({this.failLoad = false});

  final bool failLoad;
  final players = <FakeScenePlayer>[];

  FakeScenePlayer call() {
    final p = FakeScenePlayer(failLoad: failLoad);
    players.add(p);
    return p;
  }
}
