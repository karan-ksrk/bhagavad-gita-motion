import 'package:flutter_test/flutter_test.dart';
import 'package:moksharan/data/repositories/local_content_repository.dart';
import 'package:moksharan/domain/entities/content.dart';

import '../fixtures/content_fixture.dart';

void main() {
  test('returns chapters ordered by number', () async {
    final f = ContentFixture();
    (f.manifest['chapters']! as List<Object?>).shuffle();
    final repo = LocalContentRepository(f.reader);

    final chapters = await repo.chapters();
    expect(chapters.map((c) => c.number), List.generate(18, (i) => i + 1));
  });

  test('looks up chapter content, shloka, and media', () async {
    final repo = LocalContentRepository(ContentFixture().reader);

    final content = await repo.chapterContent('chapter_01');
    expect(content?.scenes.first.renderer, RendererType.cinematic);
    expect(await repo.chapterContent('chapter_02'), isNull);
    expect(await repo.chapterContent('chapter_99'), isNull);

    expect((await repo.shloka('BG.1.1'))?.placeholder, isTrue);
    expect(await repo.shloka('BG.1.2'), isNull);

    expect((await repo.mediaAsset('video_1'))?.mediaType, MediaType.video);
    expect(await repo.mediaAsset('nope'), isNull);
  });

  test('loads files once and caches', () async {
    final f = ContentFixture();
    final base = f.reader;
    var reads = 0;
    final repo = LocalContentRepository((path) {
      reads++;
      return base(path);
    });

    await repo.chapters();
    final afterFirst = reads;
    await repo.chapters();
    await repo.shloka('BG.1.1');
    expect(reads, afterFirst);
  });

  test('retries after a failed load', () async {
    final f = ContentFixture();
    final base = f.reader;
    var fail = true;
    final repo = LocalContentRepository((path) {
      if (fail) throw StateError('disk error');
      return base(path);
    });

    await expectLater(repo.chapters(), throwsA(anything));
    fail = false;
    expect(await repo.chapters(), hasLength(18));
  });
}
