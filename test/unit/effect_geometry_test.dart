import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:moksharan/core/animation/effect_geometry.dart';
import 'package:moksharan/domain/entities/content.dart';

void main() {
  test('taller screen crops the sides (cover)', () {
    // 9:19.5 phone, 9:16 art: art is matched to height, wider than screen.
    final r = coverRect(const Size(360, 780));
    expect(r.height, 780);
    expect(r.width, closeTo(780 * 9 / 16, 0.001));
    expect(r.left, closeTo((360 - r.width) / 2, 0.001));
    expect(r.top, 0);
  });

  test('wider box crops top and bottom', () {
    final r = coverRect(const Size(800, 600));
    expect(r.width, 800);
    expect(r.height, closeTo(800 * 16 / 9, 0.001));
    expect(r.top, lessThan(0));
  });

  test('exact 9:16 box maps 1:1', () {
    final r = coverRect(const Size(900, 1600));
    expect(r, const Rect.fromLTWH(0, 0, 900, 1600));
    expect(
      anchorOffset(r, const Anchor(x: 0.25, y: 0.5)),
      const Offset(225, 800),
    );
  });

  test('empty box gives empty rect', () {
    expect(coverRect(Size.zero), Rect.zero);
  });
}
