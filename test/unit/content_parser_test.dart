import 'package:flutter_test/flutter_test.dart';
import 'package:moksharan/data/models/content_parser.dart';
import 'package:moksharan/data/models/json_reader.dart';
import 'package:moksharan/domain/entities/content.dart';

import '../fixtures/content_fixture.dart';

Matcher _formatError(String location, String message) =>
    isA<ContentFormatException>().having(
      (e) => e.toString(),
      'text',
      allOf(contains(location), contains(message)),
    );

void main() {
  group('valid fixture', () {
    test('parses every entity', () async {
      final bundle = await ContentFixture().load();

      expect(bundle.manifest.chapters, hasLength(18));
      final scenes = bundle.chapterContents['chapters/chapter_01.json']!.scenes;
      expect(scenes, hasLength(2));

      final cinematic = scenes.first;
      expect(cinematic.renderer, RendererType.cinematic);
      expect(cinematic.media.videoAssetId, 'video_1');
      expect(cinematic.effects.single.type, EffectType.goldenAura);
      expect(cinematic.effects.single.anchor.x, 0.5);
      // Defaults applied when fields are omitted.
      expect(cinematic.effects.single.enabled, isTrue);
      expect(
        cinematic.effects.single.reducedMotion,
        ReducedMotionBehavior.static_,
      );

      final d = cinematic.dialogues.single;
      expect(d.speaker, Speaker.krishna);
      expect(d.type, DialogueType.verseParaphrase);
      expect(d.sourceRef, 'BG.1.1');

      final manga = scenes[1];
      expect(manga.panels.single.transition, PanelTransition.fade);

      expect(bundle.shlokas.single.placeholder, isTrue);
      expect(bundle.mediaAssets, hasLength(3));
      expect(bundle.sources, hasLength(2));
    });
  });

  group('structural errors name file and JSON path', () {
    test('invalid JSON', () {
      expect(
        () => ContentParser.manifest('{not json', file: 'manifest.json'),
        throwsA(_formatError('manifest.json', 'invalid JSON')),
      );
    });

    test('non-object document', () {
      expect(
        () => ContentParser.manifest('[]', file: 'manifest.json'),
        throwsA(_formatError('manifest.json', 'must be a JSON object')),
      );
    });

    test('unknown renderer', () async {
      final f = ContentFixture();
      f.firstScene['renderer'] = 'slideshow';
      await expectLater(
        f.load(),
        throwsA(
          _formatError(
            'chapters/chapter_01.json: scenes[0].renderer',
            '"slideshow" is not one of: cinematic, layered_motion, manga_panel',
          ),
        ),
      );
    });

    test('missing required field', () async {
      final f = ContentFixture();
      f.firstDialogue.remove('dialogue_type');
      await expectLater(
        f.load(),
        throwsA(
          _formatError('scenes[0].dialogues[0].dialogue_type', 'is required'),
        ),
      );
    });

    test('anchor out of range', () async {
      final f = ContentFixture();
      ((f.firstScene['effects']! as List).first as Map)['anchor'] = {
        'x': 1.5,
        'y': 0.2,
      };
      await expectLater(
        f.load(),
        throwsA(_formatError('effects[0].anchor.x', 'must be <= 1')),
      );
    });

    test('wrong type', () async {
      final f = ContentFixture();
      f.firstScene['order'] = '1';
      await expectLater(
        f.load(),
        throwsA(_formatError('scenes[0].order', 'must be an integer')),
      );
    });

    test('empty string must be null instead', () async {
      final f = ContentFixture();
      f.firstShloka['sanskrit'] = '  ';
      await expectLater(
        f.load(),
        throwsA(_formatError('shlokas[0].sanskrit', 'use null')),
      );
    });

    test('newer schema version is rejected', () async {
      final f = ContentFixture();
      f.manifest['schema_version'] = 2;
      await expectLater(
        f.load(),
        throwsA(_formatError('schema_version', 'newer than supported')),
      );
    });

    test('chapter number out of range', () async {
      final f = ContentFixture();
      ((f.manifest['chapters']! as List).last as Map)['number'] = 19;
      await expectLater(
        f.load(),
        throwsA(_formatError('chapters[17].number', 'must be <= 18')),
      );
    });

    test('missing referenced file', () async {
      final f = ContentFixture();
      f.manifest['sources'] = 'missing.json';
      await expectLater(
        f.load(),
        throwsA(_formatError('missing.json', 'cannot read file')),
      );
    });
  });
}
