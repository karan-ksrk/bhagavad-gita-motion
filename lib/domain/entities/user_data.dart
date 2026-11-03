/// User data entities. Stored locally from Milestone 10; not content.
library;

class ReadingProgress {
  const new({
    required this.chapterId,
    required this.updatedAt,
    this.sceneId,
    this.panelId,
    this.verseId,
  });

  final String chapterId;
  final String? sceneId;
  final String? panelId;
  final String? verseId;
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

  final String bookmarkId;
  final String? verseId;
  final String? sceneId;
  final DateTime createdAt;
}
