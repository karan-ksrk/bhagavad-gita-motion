import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moksharan/data/repositories/user_data_providers.dart';

/// UI and translation language. Sanskrit verse text is always shown and
/// is not a selectable UI language (decision D-104).
enum AppLanguage {
  hindi(code: 'hi', nativeName: 'हिन्दी'),
  english(code: 'en', nativeName: 'English');

  new({required this.code, required this.nativeName});

  final String code;
  final String nativeName;
}

@immutable
class AppSettings {
  const new({
    this.language = AppLanguage.english,
    this.showTransliteration = true,
    this.reducedMotion = false,
  });

  /// Unknown or missing values fall back to defaults.
  factory fromJson(Map<String, Object?> json) {
    const d = AppSettings();
    final code = json['language'];
    return AppSettings(
      language: AppLanguage.values.firstWhere(
        (l) => l.code == code,
        orElse: () => d.language,
      ),
      showTransliteration:
          json['show_transliteration'] as bool? ?? d.showTransliteration,
      reducedMotion: json['reduced_motion'] as bool? ?? d.reducedMotion,
    );
  }

  final AppLanguage language;
  final bool showTransliteration;
  final bool reducedMotion;

  Map<String, Object?> toJson() => {
    'language': language.code,
    'show_transliteration': showTransliteration,
    'reduced_motion': reducedMotion,
  };

  AppSettings copyWith({
    AppLanguage? language,
    bool? showTransliteration,
    bool? reducedMotion,
  }) {
    return AppSettings(
      language: language ?? this.language,
      showTransliteration: showTransliteration ?? this.showTransliteration,
      reducedMotion: reducedMotion ?? this.reducedMotion,
    );
  }
}

/// Settings, saved locally on every change (D-136).
class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final json = ref.watch(userDataRepositoryProvider).loadSettings();
    return json == null ? const AppSettings() : AppSettings.fromJson(json);
  }

  void _update(AppSettings next) {
    state = next;
    unawaited(ref.read(userDataRepositoryProvider).saveSettings(next.toJson()));
  }

  void setLanguage(AppLanguage language) =>
      _update(state.copyWith(language: language));

  void setShowTransliteration({required bool value}) =>
      _update(state.copyWith(showTransliteration: value));

  void setReducedMotion({required bool value}) =>
      _update(state.copyWith(reducedMotion: value));
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

/// True when motion should be reduced: either the in-app setting or the
/// system "remove animations" accessibility setting.
bool shouldReduceMotion(BuildContext context, WidgetRef ref) {
  final appSetting = ref.watch(settingsProvider.select((s) => s.reducedMotion));
  return appSetting || MediaQuery.disableAnimationsOf(context);
}
