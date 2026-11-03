import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moksharan/core/routing/app_router.dart';
import 'package:moksharan/core/theme/app_tokens.dart';
import 'package:moksharan/core/widgets/app_card.dart';
import 'package:moksharan/core/widgets/content_width.dart';
import 'package:moksharan/core/widgets/sample_badge.dart';
import 'package:moksharan/core/widgets/state_views.dart';
import 'package:moksharan/domain/gita_structure.dart';

class ChapterDetailScreen extends StatelessWidget {
  const new({required this.chapter, super.key});

  final int chapter;

  @override
  Widget build(BuildContext context) {
    if (!GitaStructure.isValidChapter(chapter)) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorView(
          title: 'Chapter not found',
          message: 'Chapters are numbered 1 to ${GitaStructure.chapterCount}.',
          action: FilledButton(
            onPressed: () => context.go(AppRoutes.chapters),
            child: const Text('Back to chapters'),
          ),
        ),
      );
    }

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('Chapter $chapter')),
      body: SafeArea(
        top: false,
        child: ContentWidth(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            children: [
              const Row(children: [SampleBadge()]),
              const SizedBox(height: AppSpacing.md),
              Semantics(
                header: true,
                child: Text(
                  'Chapter $chapter',
                  style: textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Title and summary pending source verification.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: () => context.push(AppRoutes.reader(chapter)),
                icon: const Icon(Icons.auto_stories),
                label: const Text('Open reader'),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                semanticLabel: 'Shloka $chapter.1, placeholder',
                onTap: () => context.push(AppRoutes.shloka('BG.$chapter.1')),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shloka $chapter.1',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Placeholder: verse pending verification',
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
