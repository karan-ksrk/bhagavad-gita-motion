import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moksharan/data/repositories/local_content_repository.dart';
import 'package:moksharan/domain/entities/content.dart';
import 'package:moksharan/domain/repositories/content_repository.dart';

/// Root of bundled content inside the Flutter asset bundle.
const contentAssetRoot = 'assets/content';

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => LocalContentRepository(
    (path) => rootBundle.loadString('$contentAssetRoot/$path'),
  ),
);

final chaptersProvider = FutureProvider<List<Chapter>>(
  (ref) => ref.watch(contentRepositoryProvider).chapters(),
);

/// Asset ID to Flutter asset path (`assets/<manifest path>`).
final mediaAssetPathsProvider = FutureProvider<Map<String, String>>((
  ref,
) async {
  final assets = await ref.watch(contentRepositoryProvider).mediaAssets();
  return {for (final a in assets) a.assetId: 'assets/${a.path}'};
});

/// Scenes for every chapter that has a scene file, keyed by chapter ID.
final chapterContentsProvider = FutureProvider<Map<String, ChapterContent>>((
  ref,
) async {
  final repo = ref.watch(contentRepositoryProvider);
  final result = <String, ChapterContent>{};
  for (final chapter in await repo.chapters()) {
    final content = await repo.chapterContent(chapter.chapterId);
    if (content != null) result[chapter.chapterId] = content;
  }
  return result;
});

/// Verse records in reading order.
final shlokaListProvider = FutureProvider<List<Shloka>>(
  (ref) => ref.watch(contentRepositoryProvider).shlokas(),
);

/// Content sources by ID, for attribution.
final sourcesByIdProvider = FutureProvider<Map<String, ContentSource>>((
  ref,
) async {
  final sources = await ref.watch(contentRepositoryProvider).sources();
  return {for (final s in sources) s.sourceId: s};
});
