import 'package:flutter/material.dart' show ColorScheme;
import 'package:flutter/painting.dart';

/// Colour tokens. Widgets use these (or the derived [ColorScheme]),
/// never raw hex values.
abstract final class AppColors {
  // Surfaces: midnight blue and charcoal.
  static const midnight = Color(0xFF0B1426);
  static const surface = Color(0xFF121C31);
  static const surfaceRaised = Color(0xFF1A2640);
  static const charcoal = Color(0xFF1B1B21);
  static const outline = Color(0xFF2E3B57);

  // Accents.
  static const gold = Color(0xFFC9A227);
  static const goldMuted = Color(0xFF8C7232);
  static const celestial = Color(0xFF7EB0E6);
  static const celestialMuted = Color(0xFF3F5F8A);

  // Text: warm ivory.
  static const ivory = Color(0xFFF3E9D2);
  static const ivoryMuted = Color(0xFFBDB29A);
  static const onGold = Color(0xFF1A1405);

  // Status.
  static const error = Color(0xFFEF8A80);
  static const sampleBadge = Color(0xFF6B4F9E);
}
