/// Cross-file content rules (schema v1). Pure Dart; run by
/// `tool/validate_content.dart` in CI and by unit tests.
library;

import 'package:moksharan/data/content/content_bundle.dart';
import 'package:moksharan/domain/entities/content.dart';
import 'package:moksharan/domain/gita_structure.dart';

enum Severity { error, warning }

class ValidationIssue {
  const new(this.severity, this.location, this.message);

  final Severity severity;
  final String location;
  final String message;

  @override
  String toString() =>
      '${severity == Severity.error ? 'ERROR' : 'WARN '} $location: $message';
}

/// Validates a loaded [ContentBundle].
///
/// Default mode allows sample and placeholder content (development).
/// [release] mode rejects anything not fully reviewed and approved.
class ContentValidator {
  new({required this.assetExists, this.release = false});

  /// Whether a media file exists, by path relative to `assets/`.
  final bool Function(String assetPath) assetExists;
  final bool release;

  static final _chapterIdPattern = RegExp(r'^chapter_(\d{2})$');
  static final _sceneIdPattern = RegExp(r'^ch(\d{2})_scene_(\d{3})$');
  static final _assetPathPattern = RegExp(
    r'^[a-z0-9_]+(/[a-z0-9_]+)*\.(webp|png|jpg|mp4|m4a|mp3|json|riv)$',
  );
  static final _decisionPattern = RegExp(r'^D-\d{3}$');

  static const Map<MediaType, Set<String>> _extensionsByType = {
    MediaType.image: {'webp', 'png', 'jpg'},
    MediaType.video: {'mp4'},
    MediaType.audio: {'m4a', 'mp3'},
  };

  List<ValidationIssue> validate(ContentBundle bundle) {
    final issues = <ValidationIssue>[];
    _Run(bundle, issues, this)
      ..checkSources()
      ..checkMedia()
      ..checkShlokas()
      ..checkChapters()
      ..checkUnusedMedia();
    return issues;
  }
}

class _Run {
  new(this.b, this.issues, this.v)
    : sourcesById = {for (final s in b.sources) s.sourceId: s},
      assetsById = {for (final a in b.mediaAssets) a.assetId: a},
      shlokasById = {for (final s in b.shlokas) s.verseId: s};

  final ContentBundle b;
  final List<ValidationIssue> issues;
  final ContentValidator v;
  final Map<String, ContentSource> sourcesById;
  final Map<String, MediaAsset> assetsById;
  final Map<String, Shloka> shlokasById;
  final Set<String> referencedAssets = {};

  void error(String at, String msg) =>
      issues.add(ValidationIssue(Severity.error, at, msg));

  void warn(String at, String msg) =>
      issues.add(ValidationIssue(Severity.warning, at, msg));

  /// Error in release mode, silent otherwise (expected during development).
  void releaseError(String at, String msg) {
    if (v.release) error(at, msg);
  }

  void checkDuplicates(Iterable<String> ids, String at, String what) {
    final seen = <String>{};
    for (final id in ids) {
      if (!seen.add(id)) error(at, 'duplicate $what "$id"');
    }
  }

  // --- Sources ------------------------------------------------------------

  void checkSources() {
    final at = b.manifest.sourcesFile;
    checkDuplicates(b.sources.map((s) => s.sourceId), at, 'source_id');
    for (final s in b.sources) {
      final ref = s.decisionRef;
      if (ref != null && !ContentValidator._decisionPattern.hasMatch(ref)) {
        error('$at: ${s.sourceId}', 'decision_ref "$ref" must look like D-004');
      }
    }
  }

  // --- Media --------------------------------------------------------------

  void checkMedia() {
    final at = b.manifest.mediaManifestFile;
    checkDuplicates(b.mediaAssets.map((a) => a.assetId), at, 'asset_id');

    for (final a in b.mediaAssets) {
      final loc = '$at: ${a.assetId}';
      if (!ContentValidator._assetPathPattern.hasMatch(a.path)) {
        error(
          loc,
          'path "${a.path}" must be lowercase snake_case segments with a '
          'known extension, relative to assets/',
        );
        continue;
      }
      final ext = a.path.split('.').last;
      if (!(ContentValidator._extensionsByType[a.mediaType]?.contains(ext) ??
          false)) {
        error(loc, '.$ext does not match media_type ${a.mediaType.wire}');
      }

      final produced =
          a.assetStatus == AssetStatus.processed ||
          a.assetStatus == AssetStatus.approved;
      if (!v.assetExists(a.path)) {
        if (produced) {
          error(loc, 'file assets/${a.path} is missing');
        } else {
          warn(loc, 'file not produced yet (asset_status draft)');
        }
      }

      if (a.assetStatus == AssetStatus.approved) {
        if (a.checksumSha256 == null) {
          error(loc, 'approved asset needs checksum_sha256');
        }
        if (a.rightsStatus != RightsStatus.cleared) {
          error(loc, 'approved asset needs rights_status cleared');
        }
        if (a.mediaType != MediaType.audio &&
            (a.width == null || a.height == null)) {
          error(loc, 'approved image/video needs width and height');
        }
        if (a.mediaType != MediaType.image && a.durationMs == null) {
          error(loc, 'approved audio/video needs duration_ms');
        }
      }
    }
  }

  // --- Shlokas ------------------------------------------------------------

  void checkShlokas() {
    const at = 'shlokas';
    checkDuplicates(b.shlokas.map((s) => s.verseId), at, 'verse_id');

    for (final s in b.shlokas) {
      final loc = 'shloka ${s.verseId}';
      final parsed = GitaStructure.parseVerseId(s.verseId);
      if (parsed == null) {
        error(loc, 'verse_id must look like BG.2.47');
      } else if (parsed.chapter != s.chapter || parsed.verse != s.verse) {
        error(
          loc,
          'verse_id does not match chapter ${s.chapter}, verse ${s.verse}',
        );
      }

      final source = sourcesById[s.sourceId];
      if (source == null) {
        error(loc, 'unknown source_id "${s.sourceId}"');
      } else if (source.kind != SourceKind.sanskritEdition) {
        error(loc, 'source_id "${s.sourceId}" is not a sanskrit_edition');
      }

      if (s.placeholder) {
        if (s.textStatus != TextStatus.draft) {
          error(loc, 'placeholder verses must stay text_status draft');
        }
        releaseError(loc, 'placeholder verse cannot ship');
      } else if (s.sanskrit == null) {
        error(loc, 'sanskrit is required unless placeholder is true');
      }

      _checkReview(loc, s.textStatus, s.reviewedBy, s.reviewedOn);
      if (s.textStatus != TextStatus.published) {
        releaseError(loc, 'text_status must be published');
      }

      for (final t in s.translations) {
        final tLoc = '$loc translation ${t.language.wire}';
        if (t.language == ContentLanguage.sanskrit) {
          error(tLoc, 'translations must be hi or en');
        }
        if (!sourcesById.containsKey(t.sourceId)) {
          error(tLoc, 'unknown source_id "${t.sourceId}"');
        }
        if (t.text == null && t.textStatus != TextStatus.draft) {
          error(tLoc, 'missing text must stay text_status draft');
        }
        _checkReview(tLoc, t.textStatus, t.reviewedBy, t.reviewedOn);
        if (t.textStatus != TextStatus.published) {
          releaseError(tLoc, 'text_status must be published');
        }
      }

      for (final w in s.wordMeanings) {
        if (!sourcesById.containsKey(w.sourceId)) {
          error('$loc word "${w.term}"', 'unknown source_id "${w.sourceId}"');
        }
      }
    }
  }

  void _checkReview(String loc, TextStatus status, String? by, String? on) {
    if (status.isApproved && (by == null || on == null)) {
      error(loc, '${status.wire} requires reviewed_by and reviewed_on');
    }
  }

  // --- Chapters and scenes ------------------------------------------------

  void checkChapters() {
    const at = ContentBundle.manifestFile;
    final chapters = b.manifest.chapters;

    final numbers = chapters.map((c) => c.number).toSet();
    for (var n = 1; n <= GitaStructure.chapterCount; n++) {
      if (!numbers.contains(n)) error(at, 'chapter $n is missing');
    }
    checkDuplicates(chapters.map((c) => c.chapterId), at, 'chapter_id');
    checkDuplicates(chapters.map((c) => '${c.number}'), at, 'chapter number');

    final sceneIds = <String>[];
    final dialogueIds = <String>[];

    for (final c in chapters) {
      final loc = '$at: ${c.chapterId}';
      final m = ContentValidator._chapterIdPattern.firstMatch(c.chapterId);
      if (m == null || int.parse(m.group(1)!) != c.number) {
        error(loc, 'chapter_id must be chapter_${_pad2(c.number)}');
      }
      if (c.sample) releaseError(loc, 'sample chapter cannot ship');
      if (c.title?.hi == null || c.title?.en == null) {
        releaseError(loc, 'title needs hi and en');
      }
      if (c.textStatus != TextStatus.published) {
        releaseError(loc, 'text_status must be published');
      }

      final file = c.scenesFile;
      if (file == null) continue;
      final content = b.chapterContents[file];
      if (content == null) continue; // Load would have failed first.
      if (content.chapterId != c.chapterId) {
        error(file, 'chapter_id "${content.chapterId}" != "${c.chapterId}"');
      }
      if (content.sample) releaseError(file, 'sample content cannot ship');

      checkDuplicates(
        content.scenes.map((s) => '${s.order}'),
        file,
        'scene order',
      );
      for (final scene in content.scenes) {
        sceneIds.add(scene.sceneId);
        _checkScene(file, c.number, scene, dialogueIds);
      }
    }

    checkDuplicates(sceneIds, 'scenes', 'scene_id');
    checkDuplicates(dialogueIds, 'dialogues', 'dialogue_id');
  }

  void _checkScene(
    String file,
    int chapter,
    Scene s,
    List<String> dialogueIds,
  ) {
    final loc = '$file: ${s.sceneId}';
    final m = ContentValidator._sceneIdPattern.firstMatch(s.sceneId);
    if (m == null || int.parse(m.group(1)!) != chapter) {
      error(loc, 'scene_id must look like ch${_pad2(chapter)}_scene_001');
    }
    if (s.title.hi == null || s.title.en == null) {
      releaseError(loc, 'title needs hi and en');
    }

    // Renderer requirements.
    switch (s.renderer) {
      case RendererType.cinematic:
        if (s.media.posterAssetId == null) {
          error(loc, 'cinematic scene needs media.poster');
        }
        if (s.media.videoAssetId == null) {
          error(loc, 'cinematic scene needs media.video');
        }
      case RendererType.layeredMotion:
        if (s.media.backgroundAssetId == null) {
          error(loc, 'layered_motion scene needs media.background');
        }
      case RendererType.mangaPanel:
        if (s.panels.isEmpty) error(loc, 'manga_panel scene needs panels');
    }
    if (s.renderer != RendererType.mangaPanel && s.panels.isNotEmpty) {
      warn(loc, 'panels are ignored by the ${s.renderer.wire} renderer');
    }

    // Media references and roles.
    _checkAssetRef(loc, 'media.poster', s.media.posterAssetId, MediaType.image);
    _checkAssetRef(loc, 'media.video', s.media.videoAssetId, MediaType.video);
    _checkAssetRef(
      loc,
      'media.background',
      s.media.backgroundAssetId,
      MediaType.image,
    );
    for (final id in s.media.layerAssetIds) {
      _checkAssetRef(loc, 'media.layers', id, MediaType.image);
    }

    checkDuplicates(s.effects.map((e) => e.effectId), loc, 'effect_id');

    for (final ref in s.shlokaRefs) {
      if (!shlokasById.containsKey(ref)) {
        error(loc, 'shloka_refs "$ref" is not in the shloka files');
      }
    }

    _checkDialogues(loc, s.dialogues, dialogueIds);

    checkDuplicates(s.panels.map((p) => p.panelId), loc, 'panel_id');
    checkDuplicates(s.panels.map((p) => '${p.order}'), loc, 'panel order');
    for (final p in s.panels) {
      final pLoc = '$loc panel ${p.panelId}';
      _checkAssetRef(pLoc, 'image', p.imageAssetId, MediaType.image);
      if (p.altText.hi == null && p.altText.en == null) {
        error(pLoc, 'alt_text needs at least one language (accessibility)');
      }
      _checkDialogues(pLoc, p.dialogues, dialogueIds);
    }
  }

  void _checkDialogues(
    String loc,
    List<Dialogue> dialogues,
    List<String> dialogueIds,
  ) {
    checkDuplicates(
      dialogues.map((d) => '${d.revealOrder}'),
      loc,
      'reveal_order',
    );
    for (final d in dialogues) {
      dialogueIds.add(d.dialogueId);
      final dLoc = '$loc dialogue ${d.dialogueId}';
      final ref = d.sourceRef;
      if (d.type.requiresSourceRef && ref == null) {
        error(dLoc, '${d.type.wire} requires source_ref');
      }
      if (ref != null && !shlokasById.containsKey(ref)) {
        error(dLoc, 'source_ref "$ref" is not in the shloka files');
      }
      if (d.text.hi == null && d.text.en == null) {
        error(dLoc, 'text needs at least one language');
      }
      if (d.text.hi == null || d.text.en == null) {
        releaseError(dLoc, 'text needs hi and en');
      }
      if (!d.textStatus.isApproved) {
        releaseError(dLoc, 'text_status must be scripture_approved or later');
      }
    }
  }

  void _checkAssetRef(String loc, String field, String? id, MediaType type) {
    if (id == null) return;
    referencedAssets.add(id);
    final asset = assetsById[id];
    if (asset == null) {
      error(loc, '$field "$id" is not in the media manifest');
      return;
    }
    if (asset.mediaType != type) {
      error(
        loc,
        '$field "$id" must be ${type.wire}, is ${asset.mediaType.wire}',
      );
    }
    if (asset.assetStatus != AssetStatus.approved) {
      releaseError(loc, '$field "$id" is not approved');
    }
  }

  void checkUnusedMedia() {
    for (final a in b.mediaAssets) {
      if (!referencedAssets.contains(a.assetId)) {
        warn(
          '${b.manifest.mediaManifestFile}: ${a.assetId}',
          'not referenced by any scene',
        );
      }
    }
  }

  static String _pad2(int n) => n.toString().padLeft(2, '0');
}
