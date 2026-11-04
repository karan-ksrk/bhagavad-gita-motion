import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moksharan/core/routing/app_router.dart';
import 'package:moksharan/core/theme/app_colors.dart';
import 'package:moksharan/core/theme/app_tokens.dart';
import 'package:moksharan/core/widgets/content_width.dart';
import 'package:moksharan/core/widgets/sample_badge.dart';
import 'package:moksharan/features/home/continue_reading_card.dart';

class HomeScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ContentWidth(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            children: [
              const SizedBox(height: AppSpacing.lg),
              Semantics(
                header: true,
                child: Text('Moksharan', style: textTheme.displaySmall),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'The Bhagavad Gita as a living visual experience.',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.ivoryMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const ContinueReadingCard(),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.chapter(1)),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Begin with Chapter 1'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () => context.go(AppRoutes.chapters),
                child: const Text('Browse all chapters'),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Row(children: [SampleBadge(label: 'FOUNDATION BUILD')]),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'No scripture content is included yet. All entries are '
                'sample placeholders pending source verification.',
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
