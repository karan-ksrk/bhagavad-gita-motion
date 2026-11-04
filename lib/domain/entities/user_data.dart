/// User data entities. Stored locally from Milestone 10; not content.
library;

class ReadingProgress {
  const new({
    required this.chapterId,
    required this.updatedAt,
    this.sceneId,
    this.panelId,
    this.verseId,
    this.visitedSceneIds = const {},
  });

  final String chapterId;

  /// Scene the reader was last on in this chapter.
  final String? sceneId;
  final String? panelId;
  final String? verseId;

  /// Scenes opened at least once, for chapter completion.
  final Set<String> visitedSceneIds;
  final DateTime updatedAt;
}

/// A bookmark points at either a verse or a scene.
class Bookmark {
  const new({
    required this.bookmarkId,
    required this.createdAt,
    this.verseId,
    this.sceneId,
  }) : assert(
         (verseId == null) != (sceneId == null),
         'A bookmark references exactly one of verseId or sceneId.',
       );

  /// Deterministic: `verse:BG.2.47` or `scene:ch01_scene_002`.
  final String bookmarkId;
  final String? verseId;
  final String? sceneId;
  final DateTime createdAt;

  static String idForVerse(String verseId) => 'verse:$verseId';
  static String idForScene(String sceneId) => 'scene:$sceneId';
}

/// All saved reading progress.
class ReadingState {
  const new({this.lastChapterId, this.byChapter = const {}});

  /// Chapter read most recently, for "continue reading".
  final String? lastChapterId;
  final Map<String, ReadingProgress> byChapter;

  ReadingProgress? get last =>
      lastChapterId == null ? null : byChapter[lastChapterId];

  static const empty = ReadingState();
}
