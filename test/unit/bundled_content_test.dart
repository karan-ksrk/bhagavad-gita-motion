import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:moksharan/data/content/content_bundle.dart';
import 'package:moksharan/data/validation/content_validator.dart';
import 'package:moksharan/domain/entities/content.dart';

/// Guards the real files in assets/content (same check as CI's
/// `dart run tool/validate_content.dart`).
void main() {
  late ContentBundle bundle;

  setUpAll(() async {
    bundle = await ContentBundle.load(
      (path) => File('assets/content/$path').readAsString(),
    );
  });

  test('bundled content has no development-mode errors', () {
    final issues = ContentValidator(
      assetExists: (path) => File('assets/$path').existsSync(),
    ).validate(bundle);

    expect([
      for (final i in issues)
        if (i.severity == Severity.error) i.toString(),
    ], isEmpty);
  });

  test('sample content includes one scene per renderer type', () {
    final renderers = bundle.chapterContents.values
        .expand((c) => c.scenes)
        .map((s) => s.renderer)
        .toSet();
    expect(renderers, RendererType.values.toSet());
  });

  test('no verified scripture text is present yet', () {
    // Until the reviewer workflow (D-006) exists, every verse must be a
    // placeholder with no Sanskrit or translation text.
    for (final s in bundle.shlokas) {
      expect(s.placeholder, isTrue, reason: s.verseId);
      expect(s.sanskrit, isNull, reason: s.verseId);
      expect(s.translations.every((t) => t.text == null), isTrue);
    }
  });

  test('every chapter is marked sample', () {
    expect(bundle.manifest.chapters.every((c) => c.sample), isTrue);
  });
}
