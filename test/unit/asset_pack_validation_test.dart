import 'package:flutter_test/flutter_test.dart';
import 'package:moksharan/data/validation/content_validator.dart';

import '../fixtures/content_fixture.dart';

Future<List<String>> _errors(ContentFixture f) async {
  final issues = ContentValidator(assetExists: (_) => true)
      .validate(await f.load());
  return [
    for (final i in issues)
      if (i.severity == Severity.error) '${i.location}: ${i.message}',
  ];
}

Matcher _hasError(String fragment) =>
    contains(predicate<String>((e) => e.contains(fragment), fragment));

Map<String, Object?> _chapter1(ContentFixture f) =>
    (f.manifest['chapters']! as List).cast<Map<String, Object?>>().first;

void main() {
  test('chapter pack with its own assets is valid', () async {
    final f = ContentFixture();
    _chapter1(f)['media_pack'] = 'chapter_01';
    for (final a in f.assets) {
      a['pack'] = 'chapter_01';
    }
    expect(await _errors(f), isEmpty);
  });

  test('scene cannot use an asset from a pack its chapter lacks', () async {
    final f = ContentFixture();
    f.assets.first['pack'] = 'chapter_01';
    expect(await _errors(f), _hasError('which this chapter does not download'));
  });

  test('media_pack must equal the chapter ID', () async {
    final f = ContentFixture();
    _chapter1(f)['media_pack'] = 'chapter_05';
    expect(await _errors(f), _hasError('media_pack must be "chapter_01"'));
  });

  test('pack names must be chapter IDs', () async {
    final f = ContentFixture();
    f.assets.first['pack'] = 'extras';
    expect(await _errors(f), _hasError('must be a chapter ID'));
  });
}
