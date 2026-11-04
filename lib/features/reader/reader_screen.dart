import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moksharan/core/media/cinematic_video_view.dart';
import 'package:moksharan/core/routing/app_router.dart';
import 'package:moksharan/core/theme/app_colors.dart';
import 'package:moksharan/core/theme/app_tokens.dart';
import 'package:moksharan/core/widgets/sample_badge.dart';
import 'package:moksharan/core/widgets/state_views.dart';
import 'package:moksharan/data/repositories/content_providers.dart';
import 'package:moksharan/domain/entities/content.dart';
import 'package:moksharan/domain/gita_structure.dart';

/// Full-screen reader. Swipes between a chapter's scenes.
///
/// Milestone 6 scope: cinematic scenes play through [CinematicVideoView];
/// manga and layered scenes show their stills until their renderers
/// arrive in Milestones 7-8.
class ReaderScreen extends ConsumerWidget {
  const new({required this.chapter, super.key});

  final int chapter;

  String get _chapterId => 'chapter_${chapter.toString().padLeft(2, '0')}';

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.chapters);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Widget body;
    if (!GitaStructure.isValidChapter(chapter)) {
      body = const ErrorView(
        title: 'Chapter not found',
        message: 'This chapter cannot be opened.',
      );
    } else {
      final contents = ref.watch(chapterContentsProvider);
      final paths = ref.watch(mediaAssetPathsProvider);
      body = switch ((contents, paths)) {
        (AsyncData(value: final c), AsyncData(value: final p)) =>
          c[_chapterId] == null
              ? _NoScenes(chapter: chapter)
              : _ScenePager(scenes: c[_chapterId]!.scenes, paths: p),
        (AsyncError(), _) || (_, AsyncError()) => ErrorView(
          title: 'Scenes could not be loaded',
          action: FilledButton(
            onPressed: () {
              ref
                ..invalidate(chapterContentsProvider)
                ..invalidate(mediaAssetPathsProvider);
            },
            child: const Text('Try again'),
          ),
        ),
        _ => const LoadingView(message: 'Loading scenes'),
      };
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          body,
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: IconButton(
                  tooltip: 'Close reader',
                  icon: const Icon(Icons.close, color: AppColors.ivory),
                  onPressed: () => _close(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoScenes extends StatelessWidget {
  const new({required this.chapter});

  final int chapter;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SampleBadge(label: 'READER PLACEHOLDER'),
            const SizedBox(height: AppSpacing.md),
            Text('Chapter $chapter', style: textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Scenes for this chapter are not produced yet.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.ivoryMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScenePager extends StatefulWidget {
  const new({required this.scenes, required this.paths});

  final List<Scene> scenes;
  final Map<String, String> paths;

  @override
  State<_ScenePager> createState() => _ScenePagerState();
}

class _ScenePagerState extends State<_ScenePager> {
  late final List<Scene> _scenes = [...widget.scenes]
    ..sort((a, b) => a.order.compareTo(b.order));
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Stack(
      children: [
        PageView.builder(
          itemCount: _scenes.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (context, i) =>
              _ScenePage(scene: _scenes[i], paths: widget.paths),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Semantics(
                label: 'Scene ${_index + 1} of ${_scenes.length}',
                child: Text(
                  '${_index + 1} / ${_scenes.length}',
                  style: textTheme.labelLarge?.copyWith(color: AppColors.ivory),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScenePage extends StatelessWidget {
  const new({required this.scene, required this.paths});

  final Scene scene;
  final Map<String, String> paths;

  String? _path(String? id) => id == null ? null : paths[id];

  @override
  Widget build(BuildContext context) {
    final media = scene.media;
    final Widget visual = switch (scene.renderer) {
      RendererType.cinematic => CinematicVideoView(
        key: ValueKey(scene.sceneId),
        posterAsset: _path(media.posterAssetId),
        videoAsset: _path(media.videoAssetId),
        loop: media.videoLoop,
      ),
      RendererType.layeredMotion => CinematicVideoView(
        key: ValueKey(scene.sceneId),
        posterAsset: _path(media.backgroundAssetId ?? media.posterAssetId),
        showControls: false,
      ),
      RendererType.mangaPanel => CinematicVideoView(
        key: ValueKey(scene.sceneId),
        posterAsset: scene.panels.isEmpty
            ? null
            : _path(scene.panels.first.imageAssetId),
        showControls: false,
      ),
    };

    return Stack(
      fit: StackFit.expand,
      children: [
        visual,
        Positioned(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.xl,
          child: SafeArea(top: false, child: _SceneCaption(scene: scene)),
        ),
      ],
    );
  }
}

/// Temporary caption until dialogue reveal (Milestone 8).
class _SceneCaption extends StatelessWidget {
  const new({required this.scene});

  final Scene scene;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final title = scene.title.en ?? scene.title.hi ?? scene.sceneId;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.midnight.withValues(alpha: 0.7),
        borderRadius: AppRadius.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${scene.renderer.wire} · text pending scripture review',
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
