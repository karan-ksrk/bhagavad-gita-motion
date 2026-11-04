import 'dart:ui';

import 'package:moksharan/domain/entities/content.dart';

/// Aspect ratio (width / height) of all production scene art (9:16).
const double sceneArtAspect = 9 / 16;

/// Rect where scene art of [aspect] lands inside [box] with BoxFit.cover,
/// centred. Effect anchors are normalized to this rect, so effects stay
/// locked to the artwork on any screen shape.
Rect coverRect(Size box, {double aspect = sceneArtAspect}) {
  if (box.isEmpty) return Rect.zero;
  final boxAspect = box.width / box.height;
  final double w;
  final double h;
  if (boxAspect > aspect) {
    // Box is wider than the art: match width, crop top and bottom.
    w = box.width;
    h = w / aspect;
  } else {
    // Box is taller than the art: match height, crop the sides.
    h = box.height;
    w = h * aspect;
  }
  return Rect.fromLTWH((box.width - w) / 2, (box.height - h) / 2, w, h);
}

/// Screen position of a normalized [anchor] inside the art [rect].
Offset anchorOffset(Rect rect, Anchor anchor) => Offset(
  rect.left + anchor.x * rect.width,
  rect.top + anchor.y * rect.height,
);
