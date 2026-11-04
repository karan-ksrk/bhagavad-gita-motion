import 'package:moksharan/domain/entities/content.dart';

/// Read access to bundled content. Widgets use this through providers;
/// they never parse JSON.
abstract interface class ContentRepository {
  /// All 18 chapter entries, ordered by number.
  Future<List<Chapter>> chapters();

  /// Scenes for a chapter, or null when the chapter has no scene file.
  Future<ChapterContent?> chapterContent(String chapterId);

  /// A verse by ID (e.g. `BG.1.1`), or null when it is not in the content.
  Future<Shloka?> shloka(String verseId);

  /// A media asset by ID, or null when it is not in the media manifest.
  Future<MediaAsset?> mediaAsset(String assetId);

  /// All media assets in the manifest.
  Future<List<MediaAsset>> mediaAssets();
}
