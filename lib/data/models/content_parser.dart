/// Parses content JSON into domain entities (schema v1).
///
/// Pure Dart: used by the app's repository and by
/// `tool/validate_content.dart`. Parsing checks structure and types;
/// cross-file rules live in `ContentValidator`.
library;

import 'dart:convert';

import 'package:moksharan/data/models/json_reader.dart';
import 'package:moksharan/domain/entities/content.dart';
import 'package:moksharan/domain/gita_structure.dart';

abstract final class ContentParser {
  /// Schema versions this build can read.
  static const supportedSchemaVersion = 1;

  static ContentManifest manifest(String source, {required String file}) {
    final r = _root(source, file);
    return ContentManifest(
      schemaVersion: _schemaVersion(r),
      chapters: r.objects('chapters', _chapter),
      shlokaFiles: r.strings('shloka_files'),
      mediaManifestFile: r.string('media_manifest'),
      sourcesFile: r.string('sources'),
    );
  }

  static ChapterContent chapterContent(String source, {required String file}) {
    final r = _root(source, file);
    _schemaVersion(r);
    return ChapterContent(
      chapterId: r.string('chapter_id'),
      sample: r.boolean('sample', fallback: false),
      scenes: r.objects('scenes', _scene),
    );
  }

  static List<Shloka> shlokas(String source, {required String file}) {
    final r = _root(source, file);
    _schemaVersion(r);
    return r.objects('shlokas', _shloka);
  }

  static List<MediaAsset> mediaAssets(String source, {required String file}) {
    final r = _root(source, file);
    _schemaVersion(r);
    return r.objects('assets', _mediaAsset);
  }

  static List<ContentSource> sources(String source, {required String file}) {
    final r = _root(source, file);
    _schemaVersion(r);
    return r.objects('sources', _contentSource);
  }

  // ---------------------------------------------------------------------

  static JsonReader _root(String source, String file) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (e) {
      throw ContentFormatException(file, 'invalid JSON: ${e.message}');
    }
    return JsonReader.root(decoded, file: file);
  }

  static int _schemaVersion(JsonReader r) {
    final version = r.integer('schema_version', min: 1);
    if (version > supportedSchemaVersion) {
      r.fail(
        'schema_version',
        'version $version is newer than supported '
            '($supportedSchemaVersion); update the app',
      );
    }
    return version;
  }

  static LocalizedText _localized(JsonReader r) =>
      LocalizedText(hi: r.optString('hi'), en: r.optString('en'));

  static LocalizedText? _optLocalized(JsonReader r, String key) {
    final o = r.optObject(key);
    return o == null ? null : _localized(o);
  }

  static TextStatus _textStatus(JsonReader r) =>
      r.enumValue('text_status', TextStatus.values, (v) => v.wire);

  static Chapter _chapter(JsonReader r) => Chapter(
    chapterId: r.string('chapter_id'),
    number: r.integer('number', min: 1, max: GitaStructure.chapterCount),
    title: _optLocalized(r, 'title'),
    summary: _optLocalized(r, 'summary'),
    textStatus: _textStatus(r),
    sample: r.boolean('sample', fallback: false),
    scenesFile: r.optString('scenes_file'),
  );

  static Scene _scene(JsonReader r) {
    final media = r.optObject('media');
    return Scene(
      sceneId: r.string('scene_id'),
      order: r.integer('order', min: 1),
      title: _localized(r.object('title')),
      renderer: r.enumValue('renderer', RendererType.values, (v) => v.wire),
      media: media == null
          ? const SceneMedia()
          : SceneMedia(
              posterAssetId: media.optString('poster'),
              videoAssetId: media.optString('video'),
              backgroundAssetId: media.optString('background'),
              layerAssetIds: media.strings('layers', optional: true),
            ),
      effects: r.objects('effects', _effect, optional: true),
      dialogues: r.objects('dialogues', _dialogue, optional: true),
      panels: r.objects('panels', _panel, optional: true),
      shlokaRefs: r.strings('shloka_refs', optional: true),
      readTimeSeconds: r.optInteger('read_time_seconds', min: 1),
    );
  }

  static Effect _effect(JsonReader r) {
    final anchor = r.object('anchor');
    return Effect(
      effectId: r.string('effect_id'),
      type: r.enumValue('type', EffectType.values, (v) => v.wire),
      enabled: r.boolean('enabled', fallback: true),
      anchor: Anchor(
        x: anchor.number('x', min: 0, max: 1),
        y: anchor.number('y', min: 0, max: 1),
      ),
      scale: r.number('scale', min: 0.01, max: 2),
      intensity: r.number('intensity', min: 0, max: 1),
      reducedMotion: r.enumValue(
        'reduced_motion',
        ReducedMotionBehavior.values,
        (v) => v.wire,
        fallback: ReducedMotionBehavior.static_,
      ),
    );
  }

  static Dialogue _dialogue(JsonReader r) => Dialogue(
    dialogueId: r.string('dialogue_id'),
    speaker: r.enumValue('speaker_id', Speaker.values, (v) => v.wire),
    type: r.enumValue('dialogue_type', DialogueType.values, (v) => v.wire),
    sourceRef: r.optString('source_ref'),
    text: _localized(r.object('text')),
    revealOrder: r.integer('reveal_order', min: 1),
    textStatus: _textStatus(r),
  );

  static Panel _panel(JsonReader r) => Panel(
    panelId: r.string('panel_id'),
    order: r.integer('order', min: 1),
    imageAssetId: r.string('image'),
    altText: _localized(r.object('alt_text')),
    transition: r.enumValue(
      'transition',
      PanelTransition.values,
      (v) => v.wire,
      fallback: PanelTransition.fade,
    ),
    dialogues: r.objects('dialogues', _dialogue, optional: true),
  );

  static Shloka _shloka(JsonReader r) => Shloka(
    verseId: r.string('verse_id'),
    chapter: r.integer('chapter', min: 1, max: GitaStructure.chapterCount),
    verse: r.integer('verse', min: 1),
    sanskrit: r.optString('sanskrit'),
    transliteration: r.optString('transliteration'),
    sourceId: r.string('source_id'),
    textStatus: _textStatus(r),
    reviewedBy: r.optString('reviewed_by'),
    reviewedOn: r.optString('reviewed_on'),
    placeholder: r.boolean('placeholder', fallback: false),
    translations: r.objects('translations', _translation, optional: true),
    wordMeanings: r.objects('word_meanings', _wordMeaning, optional: true),
  );

  static Translation _translation(JsonReader r) => Translation(
    language: r.enumValue('language', ContentLanguage.values, (v) => v.wire),
    text: r.optString('text'),
    sourceId: r.string('source_id'),
    textStatus: _textStatus(r),
    reviewedBy: r.optString('reviewed_by'),
    reviewedOn: r.optString('reviewed_on'),
  );

  static WordMeaning _wordMeaning(JsonReader r) => WordMeaning(
    term: r.string('term'),
    transliteration: r.optString('transliteration'),
    meaning: _localized(r.object('meaning')),
    sourceId: r.string('source_id'),
  );

  static MediaAsset _mediaAsset(JsonReader r) => MediaAsset(
    assetId: r.string('asset_id'),
    path: r.string('path'),
    mediaType: r.enumValue('media_type', MediaType.values, (v) => v.wire),
    width: r.optInteger('width', min: 1),
    height: r.optInteger('height', min: 1),
    durationMs: r.optInteger('duration_ms', min: 1),
    sizeBytes: r.optInteger('size_bytes', min: 1),
    codec: r.optString('codec'),
    checksumSha256: r.optString('checksum_sha256'),
    sourceTool: r.string('source_tool'),
    promptId: r.optString('prompt_id'),
    characterRefs: r.strings('character_refs', optional: true),
    assetStatus: r.enumValue('asset_status', AssetStatus.values, (v) => v.wire),
    rightsStatus: r.enumValue(
      'rights_status',
      RightsStatus.values,
      (v) => v.wire,
    ),
  );

  static ContentSource _contentSource(JsonReader r) => ContentSource(
    sourceId: r.string('source_id'),
    kind: r.enumValue('kind', SourceKind.values, (v) => v.wire),
    title: r.string('title'),
    author: r.optString('author'),
    year: r.optInteger('year'),
    license: r.string('license'),
    decisionRef: r.optString('decision_ref'),
    notes: r.optString('notes'),
  );
}
