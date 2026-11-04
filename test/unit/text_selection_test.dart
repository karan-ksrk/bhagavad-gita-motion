import 'package:flutter_test/flutter_test.dart';
import 'package:moksharan/domain/entities/content.dart';
import 'package:moksharan/domain/text_selection.dart';

Translation _t(ContentLanguage l, String? text) => Translation(
  language: l,
  text: text,
  sourceId: 's',
  textStatus: TextStatus.draft,
);

Shloka _s(String id, int ch, int v, [List<Translation> t = const []]) => Shloka(
  verseId: id,
  chapter: ch,
  verse: v,
  sourceId: 'e',
  textStatus: TextStatus.draft,
  placeholder: true,
  translations: t,
  wordMeanings: const [],
);

void main() {
  const hi = ContentLanguage.hindi;
  const en = ContentLanguage.english;

  group('chooseTranslation', () {
    test('requested language with text wins', () {
      final c = chooseTranslation(
        _s('BG.1.1', 1, 1, [_t(en, 'E'), _t(hi, 'H')]),
        hi,
      );
      expect(c.translation?.text, 'H');
      expect(c.isFallback, isFalse);
      expect(c.hasText, isTrue);
    });

    test('falls back to the other language with text', () {
      final c = chooseTranslation(
        _s('BG.1.1', 1, 1, [_t(en, 'E'), _t(hi, null)]),
        hi,
      );
      expect(c.translation?.text, 'E');
      expect(c.isFallback, isTrue);
    });

    test('no text anywhere: requested record shown as pending', () {
      final c = chooseTranslation(
        _s('BG.1.1', 1, 1, [_t(en, null), _t(hi, null)]),
        en,
      );
      expect(c.translation?.language, en);
      expect(c.hasText, isFalse);
      expect(c.isFallback, isFalse);
    });

    test('no translations at all', () {
      final c = chooseTranslation(_s('BG.1.1', 1, 1), en);
      expect(c.translation, isNull);
      expect(c.hasText, isFalse);
    });
  });

  group('neighbours', () {
    final list = [_s('BG.1.1', 1, 1), _s('BG.1.2', 1, 2), _s('BG.2.1', 2, 1)];

    test('middle, ends, and across chapters', () {
      expect(neighbours(list, 'BG.1.2'), (previous: 'BG.1.1', next: 'BG.2.1'));
      expect(neighbours(list, 'BG.1.1'), (previous: null, next: 'BG.1.2'));
      expect(neighbours(list, 'BG.2.1'), (previous: 'BG.1.2', next: null));
    });

    test('unknown verse has no neighbours', () {
      expect(neighbours(list, 'BG.9.9'), (previous: null, next: null));
    });
  });
}
