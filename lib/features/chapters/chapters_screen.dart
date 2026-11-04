import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moksharan/core/routing/app_router.dart';
import 'package:moksharan/core/settings/app_settings.dart';
import 'package:moksharan/core/theme/app_colors.dart';
import 'package:moksharan/core/theme/app_tokens.dart';
import 'package:moksharan/core/widgets/app_card.dart';
import 'package:moksharan/core/widgets/content_width.dart';
import 'package:moksharan/core/widgets/sample_badge.dart';
import 'package:moksharan/core/widgets/state_views.dart';
import 'package:moksharan/data/repositories/content_providers.dart';
import 'package:moksharan/data/repositories/user_data_providers.dart';
import 'package:moksharan/domain/entities/content.dart';

class ChaptersScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapters = ref.watch(chaptersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chapters')),
      body: SafeArea(
        top: false,
        child: switch (chapters) {
          AsyncData(:final value) => ContentWidth(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.gutter),
              itemCount: value.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) =>
                  ChapterTile(chapter: value[index]),
            ),
          ),
          AsyncError() => ErrorView(
            title: 'Chapters could not be loaded',
            message: 'The content files are missing or invalid.',
            action: FilledButton(
              onPressed: () => ref.invalidate(chaptersProvider),
              child: const Text('Try again'),
            ),
          ),
          _ => const LoadingView(message: 'Loading chapters'),
        },
      ),
    );
  }
}

class ChapterTile extends ConsumerWidget {
  const new({required this.chapter, super.key});

  final Chapter chapter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final language = ref.watch(settingsProvider.select((s) => s.language));
    final n = chapter.number;
    final title = chapter.title?.forLanguage(
      language == AppLanguage.hindi
          ? ContentLanguage.hindi
          : ContentLanguage.english,
    );
    final subtitle = title ?? 'Title pending verification';
    final scenes =
        ref.watch(chapterContentsProvider).value?[chapter.chapterId]?.scenes ??
        const <Scene>[];
    final sceneIds = {for (final sc in scenes) sc.sceneId};
    final visited = ref.watch(
      progressProvider.select(
        (p) =>
            p.byChapter[chapter.chapterId]?.visitedSceneIds ?? const <String>{},
      ),
    );
    final read = visited.intersection(sceneIds).length;
    final progressText = sceneIds.isEmpty || read == 0
        ? null
        : read == sceneIds.length
        ? 'All ${sceneIds.length} scenes read'
        : '$read of ${sceneIds.length} scenes read';

    return AppCard(
      semanticLabel: [
        'Chapter $n',
        subtitle,
        ?progressText,
        if (chapter.sample) 'sample',
      ].join(', '),
      onTap: () => context.go(AppRoutes.chapter(n)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.surfaceRaised,
            foregroundColor: AppColors.gold,
            child: Text(
              '$n',
              style: textTheme.titleMedium?.copyWith(color: AppColors.gold),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chapter $n', style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: textTheme.bodySmall),
                if (progressText != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    progressText,
                    style: textTheme.bodySmall?.copyWith(color: AppColors.gold),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: read / sceneIds.length,
                      minHeight: 3,
                      color: AppColors.gold,
                      backgroundColor: AppColors.outline,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (chapter.sample) const SampleBadge(),
        ],
      ),
    );
  }
}
