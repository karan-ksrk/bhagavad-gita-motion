import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moksharan/core/routing/app_router.dart';
import 'package:moksharan/core/theme/app_colors.dart';
import 'package:moksharan/core/theme/app_tokens.dart';
import 'package:moksharan/core/widgets/app_card.dart';
import 'package:moksharan/data/repositories/content_providers.dart';
import 'package:moksharan/data/repositories/user_data_providers.dart';
import 'package:moksharan/domain/gita_structure.dart';

/// Shows the last scene read and resumes the reader there.
class ContinueReadingCard extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final last = ref.watch(progressProvider).last;
    final contents = ref.watch(chapterContentsProvider).value;
    final chapter = last == null
        ? null
        : GitaStructure.chapterNumberOf(last.chapterId);

    if (last == null || chapter == null) {
      return AppCard(
        semanticLabel: 'Continue reading. No reading progress yet.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Continue reading', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text('No reading progress yet.', style: textTheme.bodySmall),
          ],
        ),
      );
    }

    final scenes = [...?contents?[last.chapterId]?.scenes]
      ..sort((a, b) => a.order.compareTo(b.order));
    final index = scenes.indexWhere((s) => s.sceneId == last.sceneId);
    final scene = index < 0 ? null : scenes[index];
    final position = index < 0
        ? 'Chapter $chapter'
        : 'Chapter $chapter · Scene ${index + 1} of ${scenes.length}';
    final title = scene?.title.en ?? scene?.title.hi;

    return AppCard(
      semanticLabel: 'Continue reading: $position',
      onTap: () => context.push(AppRoutes.reader(chapter)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Continue reading', style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  position,
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.gold),
                ),
                if (title != null) Text(title, style: textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.play_circle_outline, color: AppColors.gold),
        ],
      ),
    );
  }
}
