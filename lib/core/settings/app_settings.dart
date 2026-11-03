import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  final AppLanguage language;
  final bool showTransliteration;
  final bool reducedMotion;

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

/// In-memory settings. Persistence is added in Milestone 10.
class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => const AppSettings();

  void setLanguage(AppLanguage language) =>
      state = state.copyWith(language: language);

  void setShowTransliteration({required bool value}) =>
      state = state.copyWith(showTransliteration: value);

  void setReducedMotion({required bool value}) =>
      state = state.copyWith(reducedMotion: value);
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
