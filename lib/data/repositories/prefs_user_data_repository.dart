import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:moksharan/data/models/user_data_codec.dart';
import 'package:moksharan/domain/entities/user_data.dart';
import 'package:moksharan/domain/repositories/user_data_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [UserDataRepository] on SharedPreferences (D-136).
///
/// Keys carry a format version (`v1.`). [migrate] runs once at startup:
/// it records the current version and is where future formats convert
/// old keys. Corrupt values are logged and treated as absent.
class PrefsUserDataRepository implements UserDataRepository {
  new(this._prefs);

  static const currentVersion = 1;
  static const versionKey = 'user_data_version';
  static const settingsKey = 'v1.settings';
  static const progressKey = 'v1.progress';
  static const bookmarksKey = 'v1.bookmarks';

  final SharedPreferences _prefs;

  /// Brings stored data to [currentVersion]. Safe to call every launch.
  Future<void> migrate() async {
    final stored = _prefs.getInt(versionKey);
    if (stored == currentVersion) return;
    // No version key means a fresh install: nothing to convert.
    await _prefs.setInt(versionKey, currentVersion);
  }

  Object? _readJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } on FormatException catch (e) {
      debugPrint('UserData: ignoring unreadable $key ($e)');
      return null;
    }
  }

  @override
  Map<String, Object?>? loadSettings() {
    final json = _readJson(settingsKey);
    return json is Map<String, Object?> ? json : null;
  }

  @override
  Future<void> saveSettings(Map<String, Object?> settings) =>
      _prefs.setString(settingsKey, jsonEncode(settings));

  @override
  ReadingState loadProgress() {
    final json = _readJson(progressKey);
    if (json == null) return ReadingState.empty;
    try {
      return UserDataCodec.decodeProgress(json);
    } on Object catch (e) {
      debugPrint('UserData: ignoring unreadable progress ($e)');
      return ReadingState.empty;
    }
  }

  @override
  Future<void> saveProgress(ReadingState state) => _prefs.setString(
    progressKey,
    jsonEncode(UserDataCodec.encodeProgress(state)),
  );

  @override
  Future<void> clearProgress() => _prefs.remove(progressKey);

  @override
  List<Bookmark> loadBookmarks() {
    final json = _readJson(bookmarksKey);
    if (json == null) return const [];
    try {
      return UserDataCodec.decodeBookmarks(json);
    } on Object catch (e) {
      debugPrint('UserData: ignoring unreadable bookmarks ($e)');
      return const [];
    }
  }

  @override
  Future<void> saveBookmarks(List<Bookmark> bookmarks) => _prefs.setString(
    bookmarksKey,
    jsonEncode(UserDataCodec.encodeBookmarks(bookmarks)),
  );
}
