import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moksharan/core/media/media_lifecycle_manager.dart';
import 'package:moksharan/core/media/scene_player.dart';
import 'package:moksharan/core/media/video_scene_player.dart';

/// Creates scene players. Tests override this with a fake.
final scenePlayerFactoryProvider = Provider<ScenePlayerFactory>(
  (ref) => VideoScenePlayer.new,
);

final mediaLifecycleManagerProvider = Provider<MediaLifecycleManager>((ref) {
  final manager = MediaLifecycleManager()..attach();
  ref.onDispose(manager.dispose);
  return manager;
});
