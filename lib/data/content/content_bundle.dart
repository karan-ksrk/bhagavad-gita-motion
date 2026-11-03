import 'package:moksharan/data/models/content_parser.dart';
import 'package:moksharan/data/models/json_reader.dart';
import 'package:moksharan/domain/entities/content.dart';

/// Reads a content file by path relative to the content root
/// (`assets/content/`). The app uses the asset bundle; the validator tool
/// uses the file system.
typedef ContentFileReader = Future<String> Function(String relativePath);

/// All content files, parsed. Small enough to load at once for the MVP;
/// switch to per-chapter loading when chapter packs arrive (Milestone 11).
class ContentBundle {
  const new({
    required this.manifest,
    required this.chapterContents,
    required this.shlokas,
    required this.mediaAssets,
    required this.sources,
  });

  static const manifestFile = 'manifest.json';

  final ContentManifest manifest;

  /// Keyed by the scene file path that declared it, so the validator can
  /// report mismatched chapter IDs.
  final Map<String, ChapterContent> chapterContents;
  final List<Shloka> shlokas;
  final List<MediaAsset> mediaAssets;
  final List<ContentSource> sources;

  /// Loads and parses every file the manifest references. Throws
  /// [ContentFormatException] on the first structural error.
  static Future<ContentBundle> load(ContentFileReader read) async {
    final manifest = ContentParser.manifest(
      await _read(read, manifestFile),
      file: manifestFile,
    );

    final chapterContents = <String, ChapterContent>{};
    for (final chapter in manifest.chapters) {
      final file = chapter.scenesFile;
      if (file == null) continue;
      chapterContents[file] = ContentParser.chapterContent(
        await _read(read, file),
        file: file,
      );
    }

    final shlokas = <Shloka>[
      for (final file in manifest.shlokaFiles)
        ...ContentParser.shlokas(await _read(read, file), file: file),
    ];

    return ContentBundle(
      manifest: manifest,
      chapterContents: chapterContents,
      shlokas: shlokas,
      mediaAssets: ContentParser.mediaAssets(
        await _read(read, manifest.mediaManifestFile),
        file: manifest.mediaManifestFile,
      ),
      sources: ContentParser.sources(
        await _read(read, manifest.sourcesFile),
        file: manifest.sourcesFile,
      ),
    );
  }

  static Future<String> _read(ContentFileReader read, String file) async {
    try {
      return await read(file);
    } on Object catch (e) {
      throw ContentFormatException(file, 'cannot read file ($e)');
    }
  }
}
