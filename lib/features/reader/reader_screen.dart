import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moksharan/core/animation/layered_motion_view.dart';
import 'package:moksharan/core/media/cinematic_video_view.dart';
import 'package:moksharan/core/routing/app_router.dart';
import 'package:moksharan/core/settings/app_settings.dart';
import 'package:moksharan/core/theme/app_colors.dart';
import 'package:moksharan/core/theme/app_tokens.dart';
import 'package:moksharan/core/widgets/sample_badge.dart';
import 'package:moksharan/core/widgets/state_views.dart';
import 'package:moksharan/data/repositories/content_providers.dart';
import 'package:moksharan/domain/entities/content.dart';
import 'package:moksharan/domain/gita_structure.dart';
import 'package:moksharan/features/reader/dialogue_overlay.dart';

/// Full-screen reader. Swipes between a chapter's scenes.
///
/// Cinematic scenes play through [CinematicVideoView]; layered scenes use
/// [LayeredMotionView]; manga scenes show their first panel until the
/// manga renderer arrives in Milestone 8.
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

class _ScenePager extends ConsumerStatefulWidget {
  const new({required this.scenes, required this.paths});

  final List<Scene> scenes;
  final Map<String, String> paths;

  @override
  ConsumerState<_ScenePager> createState() => _ScenePagerState();
}

class _ScenePagerState extends ConsumerState<_ScenePager> {
  late final List<Scene> _scenes = [...widget.scenes]
    ..sort((a, b) => a.order.compareTo(b.order));
  final _pageController = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final reduceMotion =
        ref.watch(settingsProvider.select((s) => s.reducedMotion)) ||
        MediaQuery.disableAnimationsOf(context);

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: _scenes.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (context, i) {
            final page = _ScenePage(scene: _scenes[i], paths: widget.paths);
            if (reduceMotion) return page;
            // Scene transition: neighbours fade as they slide.
            return AnimatedBuilder(
              animation: _pageController,
              child: page,
              builder: (context, child) {
                final position =
                    _pageController.hasClients &&
                        _pageController.position.haveDimensions
                    ? _pageController.page ?? _index.toDouble()
                    : _index.toDouble();
                final distance = (position - i).abs().clamp(0.0, 1.0);
                return Opacity(opacity: 1 - distance * 0.6, child: child);
              },
            );
          },
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
      RendererType.layeredMotion => LayeredMotionView(
        key: ValueKey(scene.sceneId),
        backgroundAsset: _path(media.backgroundAssetId ?? media.posterAssetId),
        layerAssets: [
          for (final id in media.layerAssetIds)
            if (paths[id] != null) paths[id]!,
        ],
        effects: scene.effects,
      ),
      // Full manga renderer arrives in Milestone 8; first panel for now.
      RendererType.mangaPanel => CinematicVideoView(
        key: ValueKey(scene.sceneId),
        posterAsset: scene.panels.isEmpty
            ? null
            : _path(scene.panels.first.imageAssetId),
        showControls: false,
      ),
    };

    final dialogues = scene.allDialogues.toList();
    final title = scene.title.en ?? scene.title.hi ?? scene.sceneId;

    return Stack(
      fit: StackFit.expand,
      children: [
        visual,
        Positioned(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.lg,
          child: SafeArea(
            top: false,
            child: DialogueOverlay(dialogues: dialogues, title: title),
          ),
        ),
      ],
    );
  }
}
