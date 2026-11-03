import 'package:flutter_test/flutter_test.dart';
import 'package:moksharan/domain/gita_structure.dart';

void main() {
  group('GitaStructure.isValidChapter', () {
    test('accepts 1 to 18', () {
      for (var i = 1; i <= 18; i++) {
        expect(GitaStructure.isValidChapter(i), isTrue);
      }
    });

    test('rejects out-of-range numbers', () {
      expect(GitaStructure.isValidChapter(0), isFalse);
      expect(GitaStructure.isValidChapter(19), isFalse);
      expect(GitaStructure.isValidChapter(-1), isFalse);
    });
  });

  group('GitaStructure.parseVerseId', () {
    test('parses valid ids', () {
      expect(GitaStructure.parseVerseId('BG.2.47'), (chapter: 2, verse: 47));
      expect(GitaStructure.parseVerseId('BG.18.1'), (chapter: 18, verse: 1));
    });

    test('rejects malformed or out-of-range ids', () {
      for (final id in [
        '2.47',
        'BG.2',
        'BG.19.1',
        'BG.0.1',
        'BG.2.0',
        'bg.2.1',
      ]) {
        expect(GitaStructure.parseVerseId(id), isNull, reason: id);
      }
    });
  });
}
