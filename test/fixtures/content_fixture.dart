import 'dart:convert';

import 'package:moksharan/data/content/content_bundle.dart';

/// Builds a minimal valid content set as mutable JSON maps. Tests break
/// one field, then load it through [reader].
class ContentFixture {
  new() {
    manifest = {
      'schema_version': 1,
      'chapters': [
        for (var n = 1; n <= 18; n++)
          {
            'chapter_id': 'chapter_${n.toString().padLeft(2, '0')}',
            'number': n,
            'title': null,
            'summary': null,
            'text_status': 'draft',
            'sample': true,
            'scenes_file': n == 1 ? 'chapters/chapter_01.json' : null,
          },
      ],
      'shloka_files': ['shlokas/chapter_01.json'],
      'media_manifest': 'media_manifest.json',
      'sources': 'sources.json',
    };

    chapter = {
      'schema_version': 1,
      'chapter_id': 'chapter_01',
      'sample': true,
      'scenes': [
        {
          'scene_id': 'ch01_scene_001',
          'order': 1,
          'title': {'hi': 'हि', 'en': 'En'},
          'renderer': 'cinematic',
          'media': {'poster': 'poster_1', 'video': 'video_1'},
          'effects': [
            {
              'effect_id': 'aura',
              'type': 'golden_aura',
              'anchor': {'x': 0.5, 'y': 0.3},
              'scale': 0.4,
              'intensity': 0.6,
            },
          ],
          'dialogues': [
            {
              'dialogue_id': 'd1',
              'speaker_id': 'krishna',
              'dialogue_type': 'verse_paraphrase',
              'source_ref': 'BG.1.1',
              'text': {'hi': 'हि', 'en': 'En'},
              'reveal_order': 1,
              'text_status': 'draft',
            },
          ],
          'shloka_refs': ['BG.1.1'],
        },
        {
          'scene_id': 'ch01_scene_002',
          'order': 2,
          'title': {'hi': 'हि', 'en': 'En'},
          'renderer': 'manga_panel',
          'panels': [
            {
              'panel_id': 'p1',
              'order': 1,
              'image': 'panel_1',
              'alt_text': {'en': 'Alt'},
            },
          ],
        },
      ],
    };

    shlokas = {
      'schema_version': 1,
      'shlokas': [
        {
          'verse_id': 'BG.1.1',
          'chapter': 1,
          'verse': 1,
          'placeholder': true,
          'sanskrit': null,
          'source_id': 'edition',
          'text_status': 'draft',
          'translations': [
            {
              'language': 'en',
              'text': null,
              'source_id': 'translation',
              'text_status': 'draft',
            },
          ],
        },
      ],
    };

    media = {
      'schema_version': 1,
      'assets': [
        _asset('poster_1', 'posters/p1.webp', 'image'),
        _asset('video_1', 'videos/v1.mp4', 'video'),
        _asset('panel_1', 'images/panel1.webp', 'image'),
      ],
    };

    sources = {
      'schema_version': 1,
      'sources': [
        {
          'source_id': 'edition',
          'kind': 'sanskrit_edition',
          'title': 'Edition',
          'license': 'Public domain',
          'decision_ref': 'D-003',
        },
        {
          'source_id': 'translation',
          'kind': 'translation',
          'title': 'Translation',
          'license': 'Public domain',
        },
      ],
    };
  }

  late Map<String, Object?> manifest;
  late Map<String, Object?> chapter;
  late Map<String, Object?> shlokas;
  late Map<String, Object?> media;
  late Map<String, Object?> sources;

  static Map<String, Object?> _asset(String id, String path, String type) => {
    'asset_id': id,
    'path': path,
    'media_type': type,
    'source_tool': 'chatgpt',
    'asset_status': 'draft',
    'rights_status': 'pending',
  };

  // Typed accessors for mutation in tests.
  List<Map<String, Object?>> get scenes =>
      (chapter['scenes']! as List).cast<Map<String, Object?>>();
  Map<String, Object?> get firstScene => scenes.first;
  Map<String, Object?> get firstDialogue =>
      (firstScene['dialogues']! as List).cast<Map<String, Object?>>().first;
  Map<String, Object?> get firstShloka =>
      (shlokas['shlokas']! as List).cast<Map<String, Object?>>().first;
  List<Map<String, Object?>> get assets =>
      (media['assets']! as List).cast<Map<String, Object?>>();

  Map<String, String> get files => {
    'manifest.json': jsonEncode(manifest),
    'chapters/chapter_01.json': jsonEncode(chapter),
    'shlokas/chapter_01.json': jsonEncode(shlokas),
    'media_manifest.json': jsonEncode(media),
    'sources.json': jsonEncode(sources),
  };

  ContentFileReader get reader {
    final snapshot = files;
    return (path) async {
      final content = snapshot[path];
      if (content == null) throw StateError('no fixture file $path');
      return content;
    };
  }

  Future<ContentBundle> load() => ContentBundle.load(reader);
}
