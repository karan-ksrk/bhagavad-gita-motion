import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moksharan/data/asset_packs/asset_pack_providers.dart';
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

/// Asset ID to media path: a Flutter asset path (`assets/<path>`) for
/// bundled files, or an absolute file path inside an installed asset
/// pack. Assets in packs that are not installed are left out. See
/// `core/media/media_source.dart`.
final mediaAssetPathsProvider = FutureProvider<Map<String, String>>((
  ref,
) async {
  final installed = ref.watch(installedPacksProvider).paths;
  final assets = await ref.watch(contentRepositoryProvider).mediaAssets();
  return {
    for (final a in assets)
      if (a.pack == null)
        a.assetId: 'assets/${a.path}'
      else if (installed[a.pack] case final dir?)
        a.assetId: '$dir/${a.path}',
  };
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
