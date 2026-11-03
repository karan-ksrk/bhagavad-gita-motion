import 'package:flutter/material.dart';
import 'package:moksharan/core/theme/app_colors.dart';

/// Typography tokens.
///
/// - Display and verse text: Tiro Devanagari Sanskrit (bundled, OFL).
///   It covers Devanagari, Sanskrit conjuncts, and Latin.
/// - UI and body text: platform default (Roboto on Android, with the
///   system Noto Devanagari fallback for Hindi).
abstract final class AppTypography {
  static const verseFamily = 'TiroDevanagariSanskrit';

  static TextTheme textTheme() {
    const ivory = AppColors.ivory;
    const muted = AppColors.ivoryMuted;

    return const TextTheme(
      displaySmall: TextStyle(
        fontFamily: verseFamily,
        fontSize: 36,
        height: 1.2,
        color: AppColors.gold,
      ),
      headlineMedium: TextStyle(
        fontFamily: verseFamily,
        fontSize: 28,
        height: 1.25,
        color: AppColors.gold,
      ),
      headlineSmall: TextStyle(
        fontFamily: verseFamily,
        fontSize: 24,
        height: 1.3,
        color: ivory,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: ivory,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: ivory,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: ivory),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: ivory),
      bodySmall: TextStyle(fontSize: 12, height: 1.4, color: muted),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Style for Sanskrit shloka text. Larger line height for conjuncts
  /// and vowel marks above and below the line.
  static const verse = TextStyle(
    fontFamily: verseFamily,
    fontSize: 22,
    height: 1.8,
    color: AppColors.ivory,
  );
}
