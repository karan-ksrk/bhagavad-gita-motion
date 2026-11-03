/// Structural facts about the text that do not depend on any edition's
/// wording. Verse counts per chapter are added in Milestone 3 from the
/// verified source edition (D-003), not hardcoded here.
abstract final class GitaStructure {
  static const chapterCount = 18;

  static bool isValidChapter(int chapter) =>
      chapter >= 1 && chapter <= chapterCount;

  static final _verseIdPattern = RegExp(r'^BG\.(\d{1,2})\.(\d{1,2})$');

  /// Parses a verse ID such as `BG.2.47`. Returns null when the format or
  /// chapter number is invalid. Verse-number bounds are checked once
  /// verified verse counts exist.
  static ({int chapter, int verse})? parseVerseId(String id) {
    final match = _verseIdPattern.firstMatch(id);
    if (match == null) return null;
    final chapter = int.parse(match.group(1)!);
    final verse = int.parse(match.group(2)!);
    if (!isValidChapter(chapter) || verse < 1) return null;
    return (chapter: chapter, verse: verse);
  }
}
