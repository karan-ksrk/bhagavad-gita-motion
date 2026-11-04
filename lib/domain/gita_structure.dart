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

  static final _chapterIdPattern = RegExp(r'^chapter_(\d{2})$');
  static final _sceneIdPattern = RegExp(r'^ch(\d{2})_scene_\d{3}$');

  /// `chapter_02` -> 2, or null when malformed or out of range.
  static int? chapterNumberOf(String chapterId) =>
      _valid(_chapterIdPattern.firstMatch(chapterId)?.group(1));

  /// `ch02_scene_001` -> 2, or null when malformed or out of range.
  static int? chapterNumberOfScene(String sceneId) =>
      _valid(_sceneIdPattern.firstMatch(sceneId)?.group(1));

  static int? _valid(String? digits) {
    final n = digits == null ? null : int.parse(digits);
    return n != null && isValidChapter(n) ? n : null;
  }
}
