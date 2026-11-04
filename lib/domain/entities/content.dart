/// Content entities (roadmap 5.2). Immutable, pure Dart.
library;

import 'package:moksharan/domain/entities/enums.dart';

export 'package:moksharan/domain/entities/enums.dart';

/// Text in the UI languages. Either may be missing while content is in
/// draft; the validator decides when that is an error.
class LocalizedText {
  const new({this.hi, this.en});

  final String? hi;
  final String? en;

  String? forLanguage(ContentLanguage language) => switch (language) {
    ContentLanguage.hindi => hi,
    ContentLanguage.english => en,
    ContentLanguage.sanskrit => null,
  };
}

/// Normalized point (0--1) relative to the artwork frame.
class Anchor {
  const new({required this.x, required this.y});

  final double x;
  final double y;
}

class Effect {
  const new({
    required this.effectId,
    required this.type,
    required this.enabled,
    required this.anchor,
    required this.scale,
    required this.intensity,
    required this.reducedMotion,
  });

  final String effectId;
  final EffectType type;
  final bool enabled;
  final Anchor anchor;
  final double scale;
  final double intensity;
  final ReducedMotionBehavior reducedMotion;
}

class Dialogue {
  const new({
    required this.dialogueId,
    required this.speaker,
    required this.type,
    required this.text,
    required this.revealOrder,
    required this.textStatus,
    this.sourceRef,
  });

  final String dialogueId;
  final Speaker speaker;
  final DialogueType type;
  final LocalizedText text;
  final int revealOrder;
  final TextStatus textStatus;

  /// Verse ID such as `BG.2.47`. Required for verse-derived lines.
  final String? sourceRef;
}

class Panel {
  const new({
    required this.panelId,
    required this.order,
    required this.imageAssetId,
    required this.altText,
    required this.transition,
    required this.dialogues,
  });

  final String panelId;
  final int order;
  final String imageAssetId;
  final LocalizedText altText;
  final PanelTransition transition;
  final List<Dialogue> dialogues;
}

/// Asset IDs a scene uses. Which fields are required depends on the
/// renderer.
class SceneMedia {
  const new({
    this.posterAssetId,
    this.videoAssetId,
    this.backgroundAssetId,
    this.layerAssetIds = const [],
    this.videoLoop = true,
  });

  final String? posterAssetId;
  final String? videoAssetId;

  /// Loop the video (true) or play once and hold the last frame (false).
  final bool videoLoop;
  final String? backgroundAssetId;
  final List<String> layerAssetIds;

  List<String> get allAssetIds => [
    ?posterAssetId,
    ?videoAssetId,
    ?backgroundAssetId,
    ...layerAssetIds,
  ];
}

class Scene {
  const new({
    required this.sceneId,
    required this.order,
    required this.title,
    required this.renderer,
    required this.media,
    required this.effects,
    required this.dialogues,
    required this.panels,
    required this.shlokaRefs,
    this.readTimeSeconds,
  });

  final String sceneId;
  final int order;
  final LocalizedText title;
  final RendererType renderer;
  final SceneMedia media;
  final List<Effect> effects;
  final List<Dialogue> dialogues;
  final List<Panel> panels;
  final List<String> shlokaRefs;
  final int? readTimeSeconds;

  /// Dialogue lines in the scene and in all its panels.
  Iterable<Dialogue> get allDialogues =>
      dialogues.followedBy(panels.expand((p) => p.dialogues));
}

/// Chapter entry from the content manifest.
class Chapter {
  const new({
    required this.chapterId,
    required this.number,
    required this.textStatus,
    required this.sample,
    this.title,
    this.summary,
    this.scenesFile,
    this.mediaPack,
  });

  final String chapterId;
  final int number;
  final LocalizedText? title;
  final LocalizedText? summary;
  final TextStatus textStatus;

  /// True for placeholder data that must never ship as final content.
  final bool sample;

  /// Path (relative to the content root) of the chapter's scene file, or
  /// null when the chapter has no scenes yet.
  final String? scenesFile;

  /// Play asset pack holding this chapter's media, or null when the
  /// media is bundled with the app (D-139).
  final String? mediaPack;
}

/// A chapter's scenes, loaded from its scene file.
class ChapterContent {
  const new({
    required this.chapterId,
    required this.sample,
    required this.scenes,
  });

  final String chapterId;
  final bool sample;
  final List<Scene> scenes;
}

class Translation {
  const new({
    required this.language,
    required this.text,
    required this.sourceId,
    required this.textStatus,
    this.reviewedBy,
    this.reviewedOn,
  });

  final ContentLanguage language;
  final String? text;
  final String sourceId;
  final TextStatus textStatus;
  final String? reviewedBy;
  final String? reviewedOn;
}

class WordMeaning {
  const new({
    required this.term,
    required this.meaning,
    required this.sourceId,
    this.transliteration,
  });

  final String term;
  final String? transliteration;
  final LocalizedText meaning;
  final String sourceId;
}

class Shloka {
  const new({
    required this.verseId,
    required this.chapter,
    required this.verse,
    required this.sourceId,
    required this.textStatus,
    required this.placeholder,
    required this.translations,
    required this.wordMeanings,
    this.sanskrit,
    this.transliteration,
    this.reviewedBy,
    this.reviewedOn,
  });

  final String verseId;
  final int chapter;
  final int verse;

  /// Null only while [placeholder] is true.
  final String? sanskrit;
  final String? transliteration;
  final String sourceId;
  final TextStatus textStatus;
  final String? reviewedBy;
  final String? reviewedOn;

  /// True when no verified text exists yet. Placeholders stay `draft`.
  final bool placeholder;
  final List<Translation> translations;
  final List<WordMeaning> wordMeanings;
}

class MediaAsset {
  const new({
    required this.assetId,
    required this.path,
    required this.mediaType,
    required this.sourceTool,
    required this.assetStatus,
    required this.rightsStatus,
    this.width,
    this.height,
    this.durationMs,
    this.sizeBytes,
    this.codec,
    this.checksumSha256,
    this.promptId,
    this.characterRefs = const [],
    this.pack,
  });

  final String assetId;

  /// Path relative to `assets/` (bundled) or to the asset pack's
  /// assets folder when [pack] is set.
  final String path;

  /// Play asset pack that delivers this file, or null when bundled.
  final String? pack;
  final MediaType mediaType;
  final int? width;
  final int? height;
  final int? durationMs;
  final int? sizeBytes;
  final String? codec;
  final String? checksumSha256;
  final String sourceTool;
  final String? promptId;
  final List<String> characterRefs;
  final AssetStatus assetStatus;
  final RightsStatus rightsStatus;
}

class ContentSource {
  const new({
    required this.sourceId,
    required this.kind,
    required this.title,
    required this.license,
    this.author,
    this.year,
    this.decisionRef,
    this.notes,
  });

  final String sourceId;
  final SourceKind kind;
  final String title;
  final String? author;
  final int? year;
  final String license;

  /// Decision log entry, e.g. `D-004`.
  final String? decisionRef;
  final String? notes;
}

/// Top-level content manifest (`assets/content/manifest.json`).
class ContentManifest {
  const new({
    required this.schemaVersion,
    required this.chapters,
    required this.shlokaFiles,
    required this.mediaManifestFile,
    required this.sourcesFile,
  });

  final int schemaVersion;
  final List<Chapter> chapters;
  final List<String> shlokaFiles;
  final String mediaManifestFile;
  final String sourcesFile;
}
