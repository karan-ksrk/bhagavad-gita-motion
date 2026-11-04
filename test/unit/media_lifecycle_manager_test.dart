import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moksharan/core/media/media_lifecycle_manager.dart';

import '../helpers/fake_scene_player.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MediaLifecycleManager manager;

  setUp(() => manager = MediaLifecycleManager()..attach());
  tearDown(() => manager.dispose());

  test('activating a second player pauses the first', () async {
    final a = FakeScenePlayer();
    final b = FakeScenePlayer();
    await a.load(assetPath: 'a', loop: true);
    await b.load(assetPath: 'b', loop: true);

    manager.activate(a);
    await a.play();
    manager.activate(b);
    await Future<void>.delayed(Duration.zero);

    expect(a.calls, contains('pause'));
    expect(a.state.value.isPlaying, isFalse);
    expect(manager.active, same(b));
  });

  test('backgrounding pauses; foregrounding resumes', () async {
    final a = FakeScenePlayer();
    await a.load(assetPath: 'a', loop: true);
    manager.activate(a);
    await a.play();

    manager.didChangeAppLifecycleState(AppLifecycleState.paused);
    await Future<void>.delayed(Duration.zero);
    expect(a.state.value.isPlaying, isFalse);

    manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await Future<void>.delayed(Duration.zero);
    expect(a.state.value.isPlaying, isTrue);
  });

  test('does not resume a player that was already paused', () async {
    final a = FakeScenePlayer();
    await a.load(assetPath: 'a', loop: true);
    manager
      ..activate(a)
      ..didChangeAppLifecycleState(AppLifecycleState.paused)
      ..didChangeAppLifecycleState(AppLifecycleState.resumed);
    await Future<void>.delayed(Duration.zero);

    expect(a.calls, isNot(contains('play')));
  });

  test('released player is not resumed', () async {
    final a = FakeScenePlayer();
    await a.load(assetPath: 'a', loop: true);
    manager.activate(a);
    await a.play();
    manager
      ..didChangeAppLifecycleState(AppLifecycleState.paused)
      ..release(a)
      ..didChangeAppLifecycleState(AppLifecycleState.resumed);
    await Future<void>.delayed(Duration.zero);

    expect(manager.active, isNull);
    expect(a.calls.where((c) => c == 'play'), hasLength(1));
  });
}
