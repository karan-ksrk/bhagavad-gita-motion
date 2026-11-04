import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moksharan/core/media/cinematic_video_view.dart';
import 'package:moksharan/core/media/media_providers.dart';
import 'package:moksharan/core/settings/app_settings.dart';

import '../helpers/fake_scene_player.dart';
import '../helpers/prefs.dart';

const _poster = 'assets/posters/ch01_scene001_poster.webp';
const _video = 'assets/videos/ch01_scene001_loop.mp4';

Future<(FakePlayerFactory, ProviderContainer)> _pump(
  WidgetTester tester, {
  bool failLoad = false,
  bool reducedMotion = false,
  bool tickerEnabled = true,
  String? video = _video,
  bool loop = true,
}) async {
  final factory = FakePlayerFactory(failLoad: failLoad);
  final container = ProviderContainer(
    overrides: [
      await prefsOverride(),
      scenePlayerFactoryProvider.overrideWithValue(factory.call),
    ],
  );
  addTearDown(container.dispose);
  if (reducedMotion) {
    container.read(settingsProvider.notifier).setReducedMotion(value: true);
  }
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: TickerMode(
          enabled: tickerEnabled,
          child: CinematicVideoView(
            posterAsset: _poster,
            videoAsset: video,
            loop: loop,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return (factory, container);
}

void main() {
  testWidgets('loads the video, shows it, and autoplays', (tester) async {
    final (factory, container) = await _pump(tester, loop: false);
    final player = factory.players.single;

    expect(player.loadedPath, _video);
    expect(player.loop, isFalse);
    expect(player.calls, containsAllInOrder(['load', 'play']));
    expect(find.byKey(const Key('fake-video')), findsOneWidget);
    expect(find.byType(Image), findsOneWidget); // Poster stays underneath.
    expect(container.read(mediaLifecycleManagerProvider).active, same(player));
  });

  testWidgets('reduced motion: loads but does not autoplay', (tester) async {
    final (factory, _) = await _pump(tester, reducedMotion: true);
    final player = factory.players.single;

    expect(player.calls, contains('load'));
    expect(player.calls, isNot(contains('play')));
    expect(find.byTooltip('Play'), findsOneWidget);
  });

  testWidgets('load failure keeps the poster and shows a notice', (
    tester,
  ) async {
    await _pump(tester, failLoad: true);

    expect(find.byType(Image), findsOneWidget);
    expect(find.byKey(const Key('fake-video')), findsNothing);
    expect(find.text('Video unavailable, showing still'), findsOneWidget);
  });

  testWidgets('missing video asset shows poster and notice', (tester) async {
    final (factory, _) = await _pump(tester, video: null);

    expect(factory.players.single.calls, isEmpty);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Video unavailable, showing still'), findsOneWidget);
  });

  testWidgets('controls pause, play, replay, and mute', (tester) async {
    final (factory, _) = await _pump(tester);
    final player = factory.players.single;

    await tester.tap(find.byTooltip('Pause'));
    await tester.pump();
    expect(player.state.value.isPlaying, isFalse);

    await tester.tap(find.byTooltip('Play'));
    await tester.pump();
    expect(player.state.value.isPlaying, isTrue);

    await tester.tap(find.byTooltip('Replay'));
    await tester.pump();
    expect(player.calls, contains('replay'));

    await tester.tap(find.byTooltip('Unmute'));
    await tester.pump();
    expect(player.calls, contains('mute:false'));
    expect(find.byTooltip('Mute'), findsOneWidget);
  });

  testWidgets('hidden route (TickerMode off) does not autoplay', (
    tester,
  ) async {
    final (factory, _) = await _pump(tester, tickerEnabled: false);

    expect(factory.players.single.calls, isNot(contains('play')));
  });

  testWidgets('pauses when covered and resumes when uncovered', (tester) async {
    final factory = FakePlayerFactory();
    final container = ProviderContainer(
      overrides: [
        await prefsOverride(),
        scenePlayerFactoryProvider.overrideWithValue(factory.call),
      ],
    );
    addTearDown(container.dispose);
    final enabled = ValueNotifier(true);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: ValueListenableBuilder<bool>(
            valueListenable: enabled,
            builder: (_, on, _) => TickerMode(
              enabled: on,
              child: const CinematicVideoView(
                posterAsset: _poster,
                videoAsset: _video,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    final player = factory.players.single;
    expect(player.state.value.isPlaying, isTrue);

    enabled.value = false;
    await tester.pump();
    expect(player.state.value.isPlaying, isFalse);

    enabled.value = true;
    await tester.pump();
    expect(player.state.value.isPlaying, isTrue);
  });

  testWidgets('disposes the player when removed', (tester) async {
    final (factory, container) = await _pump(tester);
    final player = factory.players.single;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SizedBox()),
      ),
    );

    expect(player.disposed, isTrue);
    expect(container.read(mediaLifecycleManagerProvider).active, isNull);
  });
}
