import 'package:flutter_test/flutter_test.dart';
import 'package:moksharan/data/validation/content_validator.dart';

import '../fixtures/content_fixture.dart';

Future<List<ValidationIssue>> _validate(
  ContentFixture f, {
  bool release = false,
  bool filesExist = false,
}) async {
  final bundle = await f.load();
  return ContentValidator(
    release: release,
    assetExists: (_) => filesExist,
  ).validate(bundle);
}

List<String> _errors(List<ValidationIssue> issues) => [
  for (final i in issues)
    if (i.severity == Severity.error) '${i.location}: ${i.message}',
];

Matcher _hasError(String fragment) =>
    contains(predicate<String>((e) => e.contains(fragment), fragment));

void main() {
  test('valid fixture has no errors in development mode', () async {
    final issues = await _validate(ContentFixture());
    expect(_errors(issues), isEmpty);
    // Draft media without files is a warning, not an error.
    expect(
      issues.where((i) => i.message.contains('not produced yet')),
      hasLength(3),
    );
  });

  test('release mode rejects sample and draft content', () async {
    final errors = _errors(await _validate(ContentFixture(), release: true));
    expect(errors, _hasError('sample chapter cannot ship'));
    expect(errors, _hasError('placeholder verse cannot ship'));
    expect(errors, _hasError('text_status must be scripture_approved'));
    expect(errors, _hasError('"poster_1" is not approved'));
  });

  group('scripture integrity', () {
    test('verse-derived dialogue needs source_ref', () async {
      final f = ContentFixture();
      f.firstDialogue.remove('source_ref');
      expect(
        _errors(await _validate(f)),
        _hasError('verse_paraphrase requires source_ref'),
      );
    });

    test('source_ref must exist', () async {
      final f = ContentFixture();
      f.firstDialogue['source_ref'] = 'BG.2.47';
      expect(
        _errors(await _validate(f)),
        _hasError('source_ref "BG.2.47" is not in the shloka files'),
      );
    });

    test('placeholder verse must stay draft', () async {
      final f = ContentFixture();
      f.firstShloka['text_status'] = 'source_verified';
      expect(
        _errors(await _validate(f)),
        _hasError('placeholder verses must stay text_status draft'),
      );
    });

    test('non-placeholder verse needs Sanskrit', () async {
      final f = ContentFixture();
      f.firstShloka['placeholder'] = false;
      expect(_errors(await _validate(f)), _hasError('sanskrit is required'));
    });

    test('approved text needs reviewer metadata', () async {
      final f = ContentFixture();
      f.firstShloka
        ..['placeholder'] = false
        ..['sanskrit'] = 'text'
        ..['text_status'] = 'scripture_approved';
      expect(
        _errors(await _validate(f)),
        _hasError('requires reviewed_by and reviewed_on'),
      );
    });

    test('verse_id must match chapter and verse', () async {
      final f = ContentFixture();
      f.firstShloka['verse'] = 2;
      expect(_errors(await _validate(f)), _hasError('verse_id does not match'));
    });

    test('verse source must be a Sanskrit edition', () async {
      final f = ContentFixture();
      f.firstShloka['source_id'] = 'translation';
      expect(
        _errors(await _validate(f)),
        _hasError('is not a sanskrit_edition'),
      );
    });
  });

  group('scenes', () {
    test('cinematic scene needs video', () async {
      final f = ContentFixture();
      (f.firstScene['media']! as Map).remove('video');
      expect(
        _errors(await _validate(f)),
        _hasError('cinematic scene needs media.video'),
      );
    });

    test('media reference must exist and match type', () async {
      final f = ContentFixture();
      (f.firstScene['media']! as Map)['video'] = 'poster_1';
      expect(
        _errors(await _validate(f)),
        _hasError('media.video "poster_1" must be video, is image'),
      );
    });

    test('unknown asset id', () async {
      final f = ContentFixture();
      (f.firstScene['media']! as Map)['poster'] = 'nope';
      expect(
        _errors(await _validate(f)),
        _hasError('media.poster "nope" is not in the media manifest'),
      );
    });

    test('scene id must match chapter', () async {
      final f = ContentFixture();
      f.firstScene['scene_id'] = 'ch02_scene_001';
      expect(
        _errors(await _validate(f)),
        _hasError('scene_id must look like ch01_scene_001'),
      );
    });

    test('duplicate reveal order', () async {
      final f = ContentFixture();
      f.firstScene['dialogues'] = <Object?>[
        f.firstDialogue,
        {...f.firstDialogue, 'dialogue_id': 'd2'},
      ];
      expect(
        _errors(await _validate(f)),
        _hasError('duplicate reveal_order "1"'),
      );
    });

    test('duplicate dialogue id across scenes', () async {
      final f = ContentFixture();
      ((f.scenes[1]['panels']! as List).first as Map)['dialogues'] = [
        {...f.firstDialogue},
      ];
      expect(
        _errors(await _validate(f)),
        _hasError('duplicate dialogue_id "d1"'),
      );
    });

    test('manga panel needs alt text', () async {
      final f = ContentFixture();
      ((f.scenes[1]['panels']! as List).first as Map)['alt_text'] =
          <String, Object?>{};
      expect(
        _errors(await _validate(f)),
        _hasError('alt_text needs at least one language'),
      );
    });

    test('missing chapter is reported', () async {
      final f = ContentFixture();
      (f.manifest['chapters']! as List).removeLast();
      expect(_errors(await _validate(f)), _hasError('chapter 18 is missing'));
    });
  });

  group('media', () {
    test('processed asset with missing file is an error', () async {
      final f = ContentFixture();
      f.assets.first['asset_status'] = 'processed';
      expect(
        _errors(await _validate(f)),
        _hasError('file assets/posters/p1.webp is missing'),
      );
    });

    test('approved asset needs checksum, rights, and dimensions', () async {
      final f = ContentFixture();
      f.assets.first['asset_status'] = 'approved';
      final errors = _errors(await _validate(f, filesExist: true));
      expect(errors, _hasError('needs checksum_sha256'));
      expect(errors, _hasError('needs rights_status cleared'));
      expect(errors, _hasError('needs width and height'));
    });

    test('path naming and extension rules', () async {
      final f = ContentFixture();
      f.assets.first['path'] = 'Posters/Final New 2.webp';
      f.assets[1]['path'] = 'videos/v1.webp';
      final errors = _errors(await _validate(f));
      expect(errors, _hasError('must be lowercase snake_case'));
      expect(errors, _hasError('.webp does not match media_type video'));
    });
  });
}
