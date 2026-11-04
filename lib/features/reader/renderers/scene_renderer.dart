import 'package:flutter/material.dart';
import 'package:moksharan/core/animation/layered_motion_view.dart';
import 'package:moksharan/core/media/cinematic_video_view.dart';
import 'package:moksharan/core/theme/app_tokens.dart';
import 'package:moksharan/domain/entities/content.dart';
import 'package:moksharan/features/reader/dialogue_overlay.dart';
import 'package:moksharan/features/reader/renderers/manga_panel_renderer.dart';

/// Shared renderer contract: every renderer receives the parsed [Scene]
/// and a map of asset ID to Flutter asset path, and never touches JSON.
///
/// `SceneRenderer.forScene` picks the renderer from `scene.renderer`.
abstract final class SceneRenderer {
  static Widget forScene(Scene scene, Map<String, String> paths) =>
      switch (scene.renderer) {
        RendererType.cinematic => CinematicSceneRenderer(
          key: ValueKey(scene.sceneId),
          scene: scene,
          paths: paths,
        ),
        RendererType.layeredMotion => LayeredMotionRenderer(
          key: ValueKey(scene.sceneId),
          scene: scene,
          paths: paths,
        ),
        RendererType.mangaPanel => MangaPanelRenderer(
          key: ValueKey(scene.sceneId),
          scene: scene,
          paths: paths,
        ),
      };
}

/// Full-screen video with poster fallback plus the dialogue card.
class CinematicSceneRenderer extends StatelessWidget {
  const new({required this.scene, required this.paths, super.key});

  final Scene scene;
  final Map<String, String> paths;

  @override
  Widget build(BuildContext context) {
    final media = scene.media;
    return _WithDialogue(
      scene: scene,
      child: CinematicVideoView(
        posterAsset: paths[media.posterAssetId],
        videoAsset: paths[media.videoAssetId],
        loop: media.videoLoop,
      ),
    );
  }
}

/// Background, layers, and data-driven effects plus the dialogue card.
class LayeredMotionRenderer extends StatelessWidget {
  const new({required this.scene, required this.paths, super.key});

  final Scene scene;
  final Map<String, String> paths;

  @override
  Widget build(BuildContext context) {
    final media = scene.media;
    return _WithDialogue(
      scene: scene,
      child: LayeredMotionView(
        backgroundAsset: paths[media.backgroundAssetId ?? media.posterAssetId],
        layerAssets: [
          for (final id in media.layerAssetIds)
            if (paths[id] != null) paths[id]!,
        ],
        effects: scene.effects,
      ),
    );
  }
}

class _WithDialogue extends StatelessWidget {
  const new({required this.scene, required this.child});

  final Scene scene;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        Positioned(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.lg,
          child: SafeArea(
            top: false,
            child: DialogueOverlay(
              dialogues: scene.dialogues,
              title: scene.title.en ?? scene.title.hi ?? scene.sceneId,
            ),
          ),
        ),
      ],
    );
  }
}
