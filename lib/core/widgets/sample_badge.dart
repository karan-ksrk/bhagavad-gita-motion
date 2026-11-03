import 'package:flutter/material.dart';
import 'package:moksharan/core/theme/app_colors.dart';
import 'package:moksharan/core/theme/app_tokens.dart';

/// Marks placeholder or sample content so it is never mistaken for
/// verified scripture. Required on every sample item.
class SampleBadge extends StatelessWidget {
  const new({super.key, this.label = 'SAMPLE'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Sample content, not verified',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.sampleBadge,
          borderRadius: AppRadius.badge,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs / 2,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: AppColors.ivory),
          ),
        ),
      ),
    );
  }
}
