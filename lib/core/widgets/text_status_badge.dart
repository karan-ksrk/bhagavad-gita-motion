import 'package:flutter/material.dart';
import 'package:moksharan/core/theme/app_colors.dart';
import 'package:moksharan/core/theme/app_tokens.dart';
import 'package:moksharan/domain/entities/content.dart';

/// Review status of scripture text. Shown on every verse and translation
/// that is not yet approved, in all builds, so unreviewed text can never
/// pass as approved (D-132). Hidden only for `published`.
class TextStatusBadge extends StatelessWidget {
  const new({required this.status, super.key});

  final TextStatus status;

  static String label(TextStatus s) => switch (s) {
    TextStatus.draft => 'Draft · not verified',
    TextStatus.sourceVerified => 'Source verified · not reviewed',
    TextStatus.translationReviewed => 'Translation reviewed · pending approval',
    TextStatus.linguisticallyReviewed => 'Language reviewed · pending approval',
    TextStatus.scriptureApproved => 'Reviewed',
    TextStatus.published => 'Published',
  };

  @override
  Widget build(BuildContext context) {
    if (status == TextStatus.published) return const SizedBox.shrink();
    final approved = status.isApproved;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: approved ? AppColors.celestialMuted : AppColors.sampleBadge,
        borderRadius: AppRadius.badge,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 2,
        ),
        child: Text(
          label(status),
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: AppColors.ivory),
        ),
      ),
    );
  }
}
