import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moksharan/core/routing/app_router.dart';
import 'package:moksharan/core/settings/app_settings.dart';
import 'package:moksharan/core/theme/app_colors.dart';
import 'package:moksharan/core/theme/app_tokens.dart';
import 'package:moksharan/core/widgets/sample_badge.dart';
import 'package:moksharan/core/widgets/state_views.dart';
import 'package:moksharan/data/asset_packs/asset_pack_providers.dart';
import 'package:moksharan/data/repositories/content_providers.dart';
import 'package:moksharan/data/repositories/user_data_providers.dart';
import 'package:moksharan/domain/entities/asset_pack.dart';
import 'package:moksharan/domain/entities/content.dart';
import 'package:moksharan/domain/entities/user_data.dart';
import 'package:moksharan/domain/gita_structure.dart';
import 'package:moksharan/features/downloads/chapter_download_card.dart';
import 'package:moksharan/features/reader/renderers/scene_renderer.dart';

/// Full-screen reader. Swipes between a chapter's scenes.
///
/// Each scene is drawn by [SceneRenderer]; the reader adds progress,
/// previous/next buttons, and the verse chip.
class ReaderScreen extends ConsumerWidget {
  const new({required this.chapter, super.key, this.initialSceneId});

  final int chapter;

  /// Scene to open; when null, resumes at the saved scene.
  final String? initialSceneId;

  String get _chapterId => GitaStructure.chapterId(chapter);

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
      final packs = ref.watch(chapterPacksProvider);
      final pack = ref.watch(chapterPackStateProvider(_chapterId));
      body = switch ((contents, paths, packs)) {
        (AsyncData(value: final c), AsyncData(value: final p), AsyncData()) =>
          c[_chapterId] == null
              ? _NoScenes(chapter: chapter)
              : pack != null && pack.status == PackStatus.unknown
              ? const LoadingView(message: 'Checking chapter media')
              : pack != null && !pack.isInstalled
              ? _NeedsDownload(chapterId: _chapterId, chapter: chapter)
              : _ScenePager(
                  chapterId: _chapterId,
                  scenes: c[_chapterId]!.scenes,
                  paths: p,
                  initialSceneId: initialSceneId,
                ),
        (AsyncError(), _, _) ||
        (_, AsyncError(), _) ||
        (_, _, AsyncError()) => ErrorView(
          title: 'Scenes could not be loaded',
          action: FilledButton(
            onPressed: () {
              ref
                ..invalidate(chapterContentsProvider)
                ..invalidate(mediaAssetPathsProvider)
                ..invalidate(chapterPacksProvider);
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

/// Shown for a chapter whose media pack is not installed yet.
class _NeedsDownload extends StatelessWidget {
  const new({required this.chapterId, required this.chapter});

  final String chapterId;
  final int chapter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Download this chapter to read it. It stays available '
                'offline afterwards.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              ChapterDownloadCard(chapterId: chapterId, chapter: chapter),
            ],
          ),
        ),
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
  const new({
    required this.chapterId,
    required this.scenes,
    required this.paths,
    this.initialSceneId,
  });

  final String chapterId;
  final String? initialSceneId;
  final List<Scene> scenes;
  final Map<String, String> paths;

  @override
  ConsumerState<_ScenePager> createState() => _ScenePagerState();
}

class _ScenePagerState extends ConsumerState<_ScenePager> {
  late final List<Scene> _scenes = [...widget.scenes]
    ..sort((a, b) => a.order.compareTo(b.order));
  late final PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    final wanted =
        widget.initialSceneId ??
        ref.read(progressProvider).byChapter[widget.chapterId]?.sceneId;
    final found = _scenes.indexWhere((s) => s.sceneId == wanted);
    _index = found < 0 ? 0 : found;
    _pageController = PageController(initialPage: _index);
    // Providers cannot change while the tree builds: record after frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _record());
  }

  void _record() {
    if (!mounted) return;
    ref
        .read(progressProvider.notifier)
        .recordScene(
          chapterId: widget.chapterId,
          sceneId: _scenes[_index].sceneId,
        );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index, {required bool animate}) {
    if (index < 0 || index >= _scenes.length) return;
    if (animate) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.jumpToPage(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        ref.watch(settingsProvider.select((s) => s.reducedMotion)) ||
        MediaQuery.disableAnimationsOf(context);
    final scene = _scenes[_index];

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: _scenes.length,
          onPageChanged: (i) {
            setState(() => _index = i);
            _record();
          },
          itemBuilder: (context, i) {
            final page = SceneRenderer.forScene(_scenes[i], widget.paths);
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
        // Top scrim keeps the progress bar and buttons readable on bright art.
        const IgnorePointer(
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x99000000), Color(0x00000000)],
                  ),
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.md,
              left: 56,
              right: 56,
            ),
            child: _SceneProgress(index: _index, count: _scenes.length),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: _SceneBookmarkButton(sceneId: scene.sceneId),
            ),
          ),
        ),
        if (scene.shlokaRefs.isNotEmpty)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 52, left: AppSpacing.md),
              child: _ShlokaChip(verseId: scene.shlokaRefs.first),
            ),
          ),
        _EdgeButton(
          alignment: Alignment.centerLeft,
          icon: Icons.chevron_left,
          tooltip: 'Previous scene',
          onPressed: _index == 0
              ? null
              : () => _goTo(_index - 1, animate: !reduceMotion),
        ),
        _EdgeButton(
          alignment: Alignment.centerRight,
          icon: Icons.chevron_right,
          tooltip: 'Next scene',
          onPressed: _index == _scenes.length - 1
              ? null
              : () => _goTo(_index + 1, animate: !reduceMotion),
        ),
      ],
    );
  }
}

/// Segmented bar plus "n / total" for the current scene.
class _SceneProgress extends StatelessWidget {
  const new({required this.index, required this.count});

  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      label: 'Scene ${index + 1} of $count',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              for (var i = 0; i < count; i++)
                Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i <= index
                          ? AppColors.gold
                          : AppColors.ivoryMuted.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${index + 1} / $count',
            style: textTheme.labelLarge?.copyWith(color: AppColors.ivory),
          ),
        ],
      ),
    );
  }
}

/// Opens the verse a scene refers to. Verse text lives on the shloka
/// screen, never baked into scene art.
class _ShlokaChip extends StatelessWidget {
  const new({required this.verseId});

  final String verseId;

  @override
  Widget build(BuildContext context) {
    final parsed = GitaStructure.parseVerseId(verseId);
    final label = parsed == null
        ? verseId
        : 'Verse ${parsed.chapter}.${parsed.verse}';
    return ActionChip(
      avatar: const Icon(Icons.menu_book, size: 18, color: AppColors.gold),
      label: Text(label),
      tooltip: 'Open $label',
      backgroundColor: AppColors.midnight.withValues(alpha: 0.8),
      side: const BorderSide(color: AppColors.goldMuted),
      labelStyle: Theme.of(context).textTheme.labelLarge
          ?.copyWith(color: AppColors.ivory),
      onPressed: () => context.push(AppRoutes.shloka(verseId)),
    );
  }
}

class _EdgeButton extends StatelessWidget {
  const new({
    required this.alignment,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final Alignment alignment;
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (onPressed == null) return const SizedBox.shrink();
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: IconButton(
          tooltip: tooltip,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.midnight.withValues(alpha: 0.45),
          ),
          icon: Icon(icon, color: AppColors.ivory, size: 32),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class _SceneBookmarkButton extends ConsumerWidget {
  const new({required this.sceneId});

  final String sceneId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(
      bookmarksProvider.select(
        (list) => list.any((b) => b.bookmarkId == Bookmark.idForScene(sceneId)),
      ),
    );
    return IconButton(
      tooltip: saved ? 'Remove scene bookmark' : 'Bookmark scene',
      icon: Icon(
        saved ? Icons.bookmark : Icons.bookmark_border,
        color: saved ? AppColors.gold : AppColors.ivory,
      ),
      onPressed: () =>
          ref.read(bookmarksProvider.notifier).toggleScene(sceneId),
    );
  }
}
