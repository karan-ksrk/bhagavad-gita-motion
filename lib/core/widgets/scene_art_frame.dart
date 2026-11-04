import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:moksharan/core/animation/effect_geometry.dart';
import 'package:moksharan/core/media/media_source.dart';

/// Frames 9:16 scene art for any screen shape.
///
/// - Narrow screens (phones, portrait tablets): [child] fills the screen
///   (the art itself uses BoxFit.cover; small crop).
/// - Wide screens (width / height above [wideThreshold], e.g. landscape
///   tablets): [child] is shown whole in a centred 9:16 column, with a
///   blurred, darkened copy of [backdropAsset] filling the sides. Inside
///   that column cover equals contain, so effect anchors stay exact.
class SceneArtFrame extends StatelessWidget {
  const new({required this.child, super.key, this.backdropAsset});

  /// Above this aspect ratio, the art is letterboxed instead of cropped.
  static const wideThreshold = 0.8;

  final Widget child;
  final String? backdropAsset;

  static bool isWide(Size size) =>
      size.height > 0 && size.width / size.height > wideThreshold;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!isWide(constraints.biggest)) return child;
        return Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Colors.black),
            if (backdropAsset != null)
              RepaintBoundary(
                key: const Key('scene-art-backdrop'),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                  child: Image(
                    image: mediaImageProvider(backdropAsset!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            const ColoredBox(color: Color(0x80000000)),
            Center(
              child: AspectRatio(
                key: const Key('scene-art-column'),
                aspectRatio: sceneArtAspect,
                child: ClipRect(child: child),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Limits overlay cards (dialogue, captions) to a readable width and
/// centres them on wide screens.
class ReadableWidth extends StatelessWidget {
  const new({required this.child, super.key});

  static const maxWidth = 600.0;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
