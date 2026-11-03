import 'package:flutter/widgets.dart';

/// Spacing scale (logical pixels).
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;

  /// Side gutter for screen content.
  static const double gutter = md;
  static const screenPadding = EdgeInsets.symmetric(horizontal: gutter);
}

/// Corner radius scale.
abstract final class AppRadius {
  static const sm = Radius.circular(6);
  static const md = Radius.circular(12);
  static const lg = Radius.circular(20);

  static const card = BorderRadius.all(md);
  static const button = BorderRadius.all(md);
  static const badge = BorderRadius.all(sm);
}

/// Elevation and border tokens.
abstract final class AppElevation {
  static const none = 0.0;
  static const card = 0.0;
  static const raised = 2.0;
  static const borderWidth = 1.0;
}

/// Minimum touch target (Material accessibility guideline).
abstract final class AppSizes {
  static const minTouchTarget = 48.0;
  static const maxContentWidth = 600.0;
}
