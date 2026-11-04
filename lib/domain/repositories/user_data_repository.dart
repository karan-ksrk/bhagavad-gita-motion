import 'package:moksharan/domain/entities/user_data.dart';

/// Local storage for the reader's own data: settings, progress,
/// bookmarks. Reads are synchronous (loaded at startup); writes complete
/// asynchronously. Unreadable stored data is ignored, never fatal.
abstract interface class UserDataRepository {
  /// Stored settings as a JSON-compatible map, or null when none.
  Map<String, Object?>? loadSettings();
  Future<void> saveSettings(Map<String, Object?> settings);

  ReadingState loadProgress();
  Future<void> saveProgress(ReadingState state);
  Future<void> clearProgress();

  List<Bookmark> loadBookmarks();
  Future<void> saveBookmarks(List<Bookmark> bookmarks);
}
