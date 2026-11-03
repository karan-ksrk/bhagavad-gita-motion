import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moksharan/core/settings/app_settings.dart';
import 'package:moksharan/core/theme/app_colors.dart';
import 'package:moksharan/core/theme/app_tokens.dart';
import 'package:moksharan/core/theme/app_typography.dart';
import 'package:moksharan/core/widgets/app_card.dart';
import 'package:moksharan/core/widgets/content_width.dart';
import 'package:moksharan/core/widgets/sample_badge.dart';
import 'package:moksharan/core/widgets/state_views.dart';
import 'package:moksharan/domain/gita_structure.dart';

/// Shloka detail placeholder. Shows layout only; no verse text is
/// included until the source is verified (D-003, D-004, D-005).
class ShlokaScreen extends ConsumerWidget {
  const new({required this.verseId, super.key});

  final String verseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verse = GitaStructure.parseVerseId(verseId);
    if (verse == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const ErrorView(
          title: 'Verse not found',
          message: 'Verse IDs look like BG.2.47.',
        ),
      );
    }

    final settings = ref.watch(settingsProvider);
    final textTheme = Theme.of(context).textTheme;
    final translationLabel = settings.language == AppLanguage.hindi
        ? 'Hindi explanation'
        : 'English translation';

    return Scaffold(
      appBar: AppBar(
        title: Text('Shloka ${verse.chapter}.${verse.verse}'),
        actions: const [
          IconButton(
            tooltip: 'Bookmark (coming in Milestone 10)',
            icon: Icon(Icons.bookmark_border),
            onPressed: null,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ContentWidth(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            children: [
              const Row(children: [SampleBadge(label: 'PLACEHOLDER')]),
              const SizedBox(height: AppSpacing.md),
              _Section(
                label: 'Sanskrit',
                child: Text(
                  '[Sanskrit verse pending verification]',
                  style: AppTypography.verse.copyWith(
                    color: AppColors.ivoryMuted,
                  ),
                ),
              ),
              if (settings.showTransliteration) ...[
                const SizedBox(height: AppSpacing.md),
                _Section(
                  label: 'Transliteration',
                  child: Text(
                    '[Transliteration pending verification]',
                    style: textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.ivoryMuted,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              _Section(
                label: translationLabel,
                child: Text(
                  '[$translationLabel pending verification]',
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.ivoryMuted,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Verse ID: $verseId', style: textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const new({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: AppColors.gold),
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}
