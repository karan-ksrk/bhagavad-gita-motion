import 'package:moksharan/data/content/content_bundle.dart';
import 'package:moksharan/domain/entities/content.dart';
import 'package:moksharan/domain/repositories/content_repository.dart';

/// Content repository over bundled JSON. Loads the bundle once and caches
/// it; a failed load is retried on the next call.
class LocalContentRepository implements ContentRepository {
  new(this._read);

  final ContentFileReader _read;
  Future<ContentBundle>? _bundle;

  Future<ContentBundle> _load() async {
    try {
      return await (_bundle ??= ContentBundle.load(_read));
    } on Object {
      _bundle = null;
      rethrow;
    }
  }

  @override
  Future<List<Chapter>> chapters() async {
    final bundle = await _load();
    return [...bundle.manifest.chapters]
      ..sort((a, b) => a.number.compareTo(b.number));
  }

  @override
  Future<ChapterContent?> chapterContent(String chapterId) async {
    final bundle = await _load();
    for (final c in bundle.manifest.chapters) {
      if (c.chapterId == chapterId) {
        final file = c.scenesFile;
        return file == null ? null : bundle.chapterContents[file];
      }
    }
    return null;
  }

  @override
  Future<Shloka?> shloka(String verseId) async {
    final bundle = await _load();
    for (final s in bundle.shlokas) {
      if (s.verseId == verseId) return s;
    }
    return null;
  }

  @override
  Future<MediaAsset?> mediaAsset(String assetId) async {
    final bundle = await _load();
    for (final a in bundle.mediaAssets) {
      if (a.assetId == assetId) return a;
    }
    return null;
  }

  @override
  Future<List<MediaAsset>> mediaAssets() async =>
      List.unmodifiable((await _load()).mediaAssets);

  @override
  Future<List<Shloka>> shlokas() async {
    final list = [...(await _load()).shlokas]
      ..sort(
        (a, b) => a.chapter != b.chapter
            ? a.chapter.compareTo(b.chapter)
            : a.verse.compareTo(b.verse),
      );
    return List.unmodifiable(list);
  }

  @override
  Future<List<ContentSource>> sources() async =>
      List.unmodifiable((await _load()).sources);
}
