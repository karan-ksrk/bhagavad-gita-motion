import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moksharan/core/routing/app_router.dart';
import 'package:moksharan/core/theme/app_colors.dart';
import 'package:moksharan/core/theme/app_tokens.dart';
import 'package:moksharan/core/widgets/app_card.dart';
import 'package:moksharan/core/widgets/content_width.dart';
import 'package:moksharan/core/widgets/sample_badge.dart';
import 'package:moksharan/data/sample/sample_chapters.dart';

class ChaptersScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapters = ref.watch(sampleChapterNumbersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chapters')),
      body: SafeArea(
        top: false,
        child: ContentWidth(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            itemCount: chapters.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) =>
                ChapterTile(chapter: chapters[index]),
          ),
        ),
      ),
    );
  }
}

class ChapterTile extends StatelessWidget {
  const new({required this.chapter, super.key});

  final int chapter;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      semanticLabel: 'Chapter $chapter, sample, title pending verification',
      onTap: () => context.go(AppRoutes.chapter(chapter)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.surfaceRaised,
            foregroundColor: AppColors.gold,
            child: Text(
              '$chapter',
              style: textTheme.titleMedium?.copyWith(color: AppColors.gold),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chapter $chapter', style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text('Title pending verification', style: textTheme.bodySmall),
              ],
            ),
          ),
          const SampleBadge(),
        ],
      ),
    );
  }
}
