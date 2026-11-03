import 'package:flutter/material.dart';
import 'package:moksharan/core/theme/app_colors.dart';
import 'package:moksharan/core/theme/app_tokens.dart';

/// Centered loading indicator with an accessible label.
class LoadingView extends StatelessWidget {
  const new({super.key, this.message = 'Loading'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: message,
        child: const CircularProgressIndicator(color: AppColors.gold),
      ),
    );
  }
}

/// Empty state: icon, title, optional message and action.
class EmptyView extends StatelessWidget {
  const new({
    required this.title,
    super.key,
    this.message,
    this.icon = Icons.auto_stories_outlined,
    this.action,
  });

  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return _StateLayout(
      icon: icon,
      iconColor: AppColors.goldMuted,
      title: title,
      message: message,
      action: action,
    );
  }
}

/// Error state with optional retry or recovery action.
class ErrorView extends StatelessWidget {
  const new({required this.title, super.key, this.message, this.action});

  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return _StateLayout(
      icon: Icons.error_outline,
      iconColor: AppColors.error,
      title: title,
      message: message,
      action: action,
    );
  }
}

class _StateLayout extends StatelessWidget {
  const new({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: iconColor),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.ivoryMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
