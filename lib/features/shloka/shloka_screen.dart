import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moksharan/core/routing/app_router.dart';
import 'package:moksharan/core/settings/app_settings.dart';
import 'package:moksharan/core/theme/app_colors.dart';
import 'package:moksharan/core/theme/app_tokens.dart';
import 'package:moksharan/core/theme/app_typography.dart';
import 'package:moksharan/core/widgets/app_card.dart';
import 'package:moksharan/core/widgets/content_width.dart';
import 'package:moksharan/core/widgets/state_views.dart';
import 'package:moksharan/core/widgets/text_status_badge.dart';
import 'package:moksharan/data/repositories/content_providers.dart';
import 'package:moksharan/data/repositories/user_data_providers.dart';
import 'package:moksharan/domain/entities/content.dart';
import 'package:moksharan/domain/entities/user_data.dart';
import 'package:moksharan/domain/gita_structure.dart';
import 'package:moksharan/domain/text_selection.dart';

/// Verse detail: Sanskrit, transliteration, translation in the reader's
/// language (with fallback), word meanings, attribution, review status,
/// and previous/next verse navigation. All text comes from content JSON;
/// nothing is generated in the app.
class ShlokaScreen extends ConsumerWidget {
  const new({required this.verseId, super.key});

  final String verseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parsed = GitaStructure.parseVerseId(verseId);
    if (parsed == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const ErrorView(
          title: 'Verse not found',
          message: 'Verse IDs look like BG.2.47.',
        ),
      );
    }

    final title = 'Shloka ${parsed.chapter}.${parsed.verse}';
    final shlokas = ref.watch(shlokaListProvider);
    final sources = ref.watch(sourcesByIdProvider);

    final body = switch ((shlokas, sources)) {
      (AsyncData(value: final list), AsyncData(value: final src)) => _body(
        context,
        list,
        src,
      ),
      (AsyncError(), _) || (_, AsyncError()) => ErrorView(
        title: 'Verse could not be loaded',
        action: FilledButton(
          onPressed: () => ref
            ..invalidate(shlokaListProvider)
            ..invalidate(sourcesByIdProvider),
          child: const Text('Try again'),
        ),
      ),
      _ => const LoadingView(message: 'Loading verse'),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Show or hide transliteration',
            icon: const Icon(Icons.translate),
            onPressed: () {
              final show = ref.read(settingsProvider).showTransliteration;
              ref
                  .read(settingsProvider.notifier)
                  .setShowTransliteration(value: !show);
            },
          ),
          _VerseBookmarkButton(verseId: verseId),
        ],
      ),
      body: SafeArea(top: false, child: body),
    );
  }

  Widget _body(
    BuildContext context,
    List<Shloka> list,
    Map<String, ContentSource> sources,
  ) {
    Shloka? shloka;
    for (final s in list) {
      if (s.verseId == verseId) shloka = s;
    }
    if (shloka == null) {
      return EmptyView(
        icon: Icons.menu_book_outlined,
        title: 'Verse not added yet',
        message: '$verseId is not in the app content yet.',
      );
    }
    final around = neighbours(list, verseId);
    return ContentWidth(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        children: [
          _VerseBody(shloka: shloka, sources: sources),
          const SizedBox(height: AppSpacing.lg),
          _VerseNav(previous: around.previous, next: around.next),
        ],
      ),
    );
  }
}

class _VerseBody extends ConsumerWidget {
  const new({required this.shloka, required this.sources});

  final Shloka shloka;
  final Map<String, ContentSource> sources;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final textTheme = Theme.of(context).textTheme;
    final requested = settings.language == AppLanguage.hindi
        ? ContentLanguage.hindi
        : ContentLanguage.english;
    final choice = chooseTranslation(shloka, requested);
    final translation = choice.translation;
    final shownLanguage = translation?.language ?? requested;
    final translationLabel = shownLanguage == ContentLanguage.hindi
        ? 'Hindi explanation'
        : 'English translation';
    final muted = textTheme.bodyLarge?.copyWith(color: AppColors.ivoryMuted);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            TextStatusBadge(status: shloka.textStatus),
            if (shloka.placeholder) const _Tag('PLACEHOLDER'),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _Section(
          label: 'Sanskrit',
          child: shloka.sanskrit == null
              ? Text(
                  '[Sanskrit verse pending verification]',
                  style: AppTypography.verse.copyWith(
                    color: AppColors.ivoryMuted,
                  ),
                )
              : SelectableText(
                  shloka.sanskrit!,
                  style: AppTypography.verse.copyWith(
                    locale: const Locale('hi'),
                  ),
                ),
        ),
        if (settings.showTransliteration) ...[
          const SizedBox(height: AppSpacing.md),
          _Section(
            label: 'Transliteration',
            child: Text(
              shloka.transliteration ??
                  '[Transliteration pending verification]',
              style: shloka.transliteration == null
                  ? muted?.copyWith(fontStyle: FontStyle.italic)
                  : textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        _Section(
          label: translationLabel,
          trailing: translation == null
              ? null
              : TextStatusBadge(status: translation.textStatus),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (choice.isFallback) ...[
                Text(
                  requested == ContentLanguage.hindi
                      ? 'Hindi not available yet; showing English.'
                      : 'English not available yet; showing Hindi.',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              Text(
                translation?.text ?? '[$translationLabel pending verification]',
                style: choice.hasText ? textTheme.bodyLarge : muted,
              ),
            ],
          ),
        ),
        if (shloka.wordMeanings.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _Section(
            label: 'Word meanings',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final w in shloka.wordMeanings)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: w.term,
                            style: AppTypography.verse.copyWith(fontSize: 18),
                          ),
                          if (w.transliteration != null)
                            TextSpan(
                              text: '  ${w.transliteration}',
                              style: textTheme.bodySmall,
                            ),
                          TextSpan(
                            text: '  ${_meaning(w, shownLanguage)}',
                            style: textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        _Attribution(
          sanskritSource: sources[shloka.sourceId],
          translationSource: translation == null
              ? null
              : sources[translation.sourceId],
          translationLabel: translationLabel,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Verse ID: ${shloka.verseId}', style: textTheme.bodySmall),
      ],
    );
  }
}

String _meaning(WordMeaning w, ContentLanguage language) {
  final preferred = language == ContentLanguage.hindi
      ? w.meaning.hi
      : w.meaning.en;
  return preferred ?? w.meaning.en ?? w.meaning.hi ?? '';
}

class _Attribution extends StatelessWidget {
  const new({
    required this.sanskritSource,
    required this.translationSource,
    required this.translationLabel,
  });

  final ContentSource? sanskritSource;
  final ContentSource? translationSource;
  final String translationLabel;

  static String describe(ContentSource s) {
    final parts = [
      s.title,
      if (s.author != null) s.author!,
      if (s.year != null) '${s.year}',
    ];
    return '${parts.join(', ')}. ${s.license}.';
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    return Semantics(
      container: true,
      label: 'Sources',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SOURCES',
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: AppColors.gold),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (sanskritSource != null)
            Text('Sanskrit: ${describe(sanskritSource!)}', style: style),
          if (translationSource != null)
            Text(
              '$translationLabel: ${describe(translationSource!)}',
              style: style,
            ),
        ],
      ),
    );
  }
}

class _VerseNav extends StatelessWidget {
  const new({required this.previous, required this.next});

  final String? previous;
  final String? next;

  static String _short(String id) => id.replaceFirst('BG.', '');

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: previous == null
              ? const SizedBox.shrink()
              : OutlinedButton.icon(
                  onPressed: () =>
                      context.pushReplacement(AppRoutes.shloka(previous!)),
                  icon: const Icon(Icons.chevron_left),
                  label: Text('Verse ${_short(previous!)}'),
                ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: next == null
              ? const SizedBox.shrink()
              : OutlinedButton.icon(
                  onPressed: () =>
                      context.pushReplacement(AppRoutes.shloka(next!)),
                  icon: const Icon(Icons.chevron_right),
                  label: Text('Verse ${_short(next!)}'),
                  iconAlignment: IconAlignment.end,
                ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.ivoryMuted),
        borderRadius: AppRadius.badge,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 2,
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: AppColors.ivoryMuted),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const new({required this.label, required this.child, this.trailing});

  final String label;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: AppColors.gold),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _VerseBookmarkButton extends ConsumerWidget {
  const new({required this.verseId});

  final String verseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(
      bookmarksProvider.select(
        (list) => list.any((b) => b.bookmarkId == Bookmark.idForVerse(verseId)),
      ),
    );
    return IconButton(
      tooltip: saved ? 'Remove verse bookmark' : 'Bookmark verse',
      icon: Icon(
        saved ? Icons.bookmark : Icons.bookmark_border,
        color: saved ? AppColors.gold : null,
      ),
      onPressed: () =>
          ref.read(bookmarksProvider.notifier).toggleVerse(verseId),
    );
  }
}
