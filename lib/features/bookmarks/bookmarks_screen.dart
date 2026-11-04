import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moksharan/core/routing/app_router.dart';
import 'package:moksharan/core/theme/app_tokens.dart';
import 'package:moksharan/core/widgets/app_card.dart';
import 'package:moksharan/core/widgets/content_width.dart';
import 'package:moksharan/core/widgets/state_views.dart';
import 'package:moksharan/data/repositories/content_providers.dart';
import 'package:moksharan/data/repositories/user_data_providers.dart';
import 'package:moksharan/domain/entities/content.dart';
import 'package:moksharan/domain/entities/user_data.dart';
import 'package:moksharan/domain/gita_structure.dart';

/// Saved verses and scenes, newest first.
class BookmarksScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksProvider);
    final contents = ref.watch(chapterContentsProvider).value ?? const {};
    final scenesById = <String, Scene>{
      for (final c in contents.values)
        for (final s in c.scenes) s.sceneId: s,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: SafeArea(
        top: false,
        child: bookmarks.isEmpty
            ? const EmptyView(
                icon: Icons.bookmark_border,
                title: 'No bookmarks yet',
                message: 'Bookmark a verse or scene to find it here.',
              )
            : ContentWidth(
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.gutter),
                  itemCount: bookmarks.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) =>
                      _BookmarkTile(bookmark: bookmarks[i], scenes: scenesById),
                ),
              ),
      ),
    );
  }
}

class _BookmarkTile extends ConsumerWidget {
  const new({required this.bookmark, required this.scenes});

  final Bookmark bookmark;
  final Map<String, Scene> scenes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final verseId = bookmark.verseId;
    final sceneId = bookmark.sceneId;

    final String title;
    final String subtitle;
    final IconData icon;
    final VoidCallback? open;

    if (verseId != null) {
      final v = GitaStructure.parseVerseId(verseId);
      title = v == null ? verseId : 'Verse ${v.chapter}.${v.verse}';
      subtitle = 'Shloka';
      icon = Icons.menu_book;
      open = () => context.push(AppRoutes.shloka(verseId));
    } else {
      final scene = scenes[sceneId];
      final chapter = GitaStructure.chapterNumberOfScene(sceneId!);
      title = scene?.title.en ?? scene?.title.hi ?? sceneId;
      subtitle = chapter == null ? 'Scene' : 'Chapter $chapter · Scene';
      icon = Icons.movie_outlined;
      open = chapter == null
          ? null
          : () => context.push(AppRoutes.reader(chapter, sceneId: sceneId));
    }

    return AppCard(
      semanticLabel: '$title, $subtitle',
      onTap: open,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleMedium),
                Text(subtitle, style: textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove bookmark',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => ref
                .read(bookmarksProvider.notifier)
                .remove(bookmark.bookmarkId),
          ),
        ],
      ),
    );
  }
}
