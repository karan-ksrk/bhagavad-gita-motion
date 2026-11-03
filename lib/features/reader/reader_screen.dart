import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moksharan/core/routing/app_router.dart';
import 'package:moksharan/core/theme/app_colors.dart';
import 'package:moksharan/core/theme/app_tokens.dart';
import 'package:moksharan/core/widgets/sample_badge.dart';
import 'package:moksharan/core/widgets/state_views.dart';
import 'package:moksharan/domain/gita_structure.dart';

/// Full-screen reader placeholder. Scene renderers arrive in Milestone 8.
class ReaderScreen extends StatelessWidget {
  const new({required this.chapter, super.key});

  final int chapter;

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.chapters);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final valid = GitaStructure.isValidChapter(chapter);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (valid)
              Center(
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
                        'Cinematic, layered-motion, and manga scenes '
                        'arrive in Milestone 8.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.ivoryMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              const ErrorView(
                title: 'Chapter not found',
                message: 'This chapter cannot be opened.',
              ),
            Positioned(
              top: AppSpacing.xs,
              left: AppSpacing.xs,
              child: IconButton(
                tooltip: 'Close reader',
                icon: const Icon(Icons.close, color: AppColors.ivory),
                onPressed: () => _close(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
