import 'package:moksharan/domain/entities/content.dart';

/// Result of picking a translation for the reader's language.
class TranslationChoice {
  const new({
    required this.translation,
    required this.requested,
    required this.isFallback,
  });

  /// The translation to show, or null when none exists in any UI
  /// language.
  final Translation? translation;

  /// Language the reader asked for.
  final ContentLanguage requested;

  /// True when [translation] is in the other UI language.
  final bool isFallback;

  /// True when there is text to show (not a pending placeholder).
  bool get hasText => translation?.text != null;
}

/// Language fallback rule (Milestone 9):
/// 1. a translation in the requested language that has text;
/// 2. else one in the other UI language that has text (marked fallback);
/// 3. else the requested-language record without text (shown as pending);
/// 4. else null.
TranslationChoice chooseTranslation(Shloka shloka, ContentLanguage requested) {
  Translation? find(ContentLanguage l, {required bool withText}) {
    for (final t in shloka.translations) {
      if (t.language == l && (!withText || t.text != null)) return t;
    }
    return null;
  }

  final other = requested == ContentLanguage.hindi
      ? ContentLanguage.english
      : ContentLanguage.hindi;

  final primary = find(requested, withText: true);
  if (primary != null) {
    return TranslationChoice(
      translation: primary,
      requested: requested,
      isFallback: false,
    );
  }
  final fallback = find(other, withText: true);
  if (fallback != null) {
    return TranslationChoice(
      translation: fallback,
      requested: requested,
      isFallback: true,
    );
  }
  return TranslationChoice(
    translation: find(requested, withText: false),
    requested: requested,
    isFallback: false,
  );
}

/// Previous and next verse IDs around [verseId] in [ordered], or null at
/// the ends or when the verse is not in the list.
({String? previous, String? next}) neighbours(
  List<Shloka> ordered,
  String verseId,
) {
  final i = ordered.indexWhere((s) => s.verseId == verseId);
  if (i < 0) return (previous: null, next: null);
  return (
    previous: i > 0 ? ordered[i - 1].verseId : null,
    next: i < ordered.length - 1 ? ordered[i + 1].verseId : null,
  );
}
