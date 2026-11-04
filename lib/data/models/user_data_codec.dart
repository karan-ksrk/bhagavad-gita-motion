/// JSON encoding for user data (storage format v1). Pure Dart.
library;

import 'package:moksharan/domain/entities/user_data.dart';

abstract final class UserDataCodec {
  static Map<String, Object?> encodeProgress(ReadingState s) => {
    'last_chapter_id': s.lastChapterId,
    'chapters': {
      for (final e in s.byChapter.entries)
        e.key: {
          'scene_id': e.value.sceneId,
          'panel_id': e.value.panelId,
          'verse_id': e.value.verseId,
          'visited': e.value.visitedSceneIds.toList()..sort(),
          'updated_at': e.value.updatedAt.toIso8601String(),
        },
    },
  };

  /// Throws on malformed input.
  static ReadingState decodeProgress(Object? json) {
    if (json is! Map) throw const FormatException('progress: not an object');
    final chapters = json['chapters'];
    if (chapters is! Map) throw const FormatException('progress: chapters');
    final byChapter = <String, ReadingProgress>{};
    for (final e in chapters.entries) {
      final key = e.key;
      final v = e.value;
      if (key is! String || v is! Map) {
        throw const FormatException('progress: chapter entry');
      }
      final visited = v['visited'];
      byChapter[key] = ReadingProgress(
        chapterId: key,
        sceneId: v['scene_id'] as String?,
        panelId: v['panel_id'] as String?,
        verseId: v['verse_id'] as String?,
        visitedSceneIds: {
          if (visited is List)
            for (final id in visited)
              if (id is String) id,
        },
        updatedAt: DateTime.parse(v['updated_at']! as String),
      );
    }
    return ReadingState(
      lastChapterId: json['last_chapter_id'] as String?,
      byChapter: byChapter,
    );
  }

  static List<Object?> encodeBookmarks(List<Bookmark> list) => [
    for (final b in list)
      {
        'id': b.bookmarkId,
        'verse_id': b.verseId,
        'scene_id': b.sceneId,
        'created_at': b.createdAt.toIso8601String(),
      },
  ];

  /// Skips individual malformed entries; throws if [json] is not a list.
  static List<Bookmark> decodeBookmarks(Object? json) {
    if (json is! List) throw const FormatException('bookmarks: not a list');
    final result = <Bookmark>[];
    for (final item in json) {
      try {
        if (item is! Map) continue;
        final verse = item['verse_id'] as String?;
        final scene = item['scene_id'] as String?;
        if ((verse == null) == (scene == null)) continue;
        result.add(
          Bookmark(
            bookmarkId: item['id']! as String,
            verseId: verse,
            sceneId: scene,
            createdAt: DateTime.parse(item['created_at']! as String),
          ),
        );
      } on Object {
        continue;
      }
    }
    return result;
  }
}
