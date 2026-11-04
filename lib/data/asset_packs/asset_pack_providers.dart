import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:moksharan/data/asset_packs/play_asset_pack_service.dart';
import 'package:moksharan/data/asset_packs/unsupported_asset_pack_service.dart';
import 'package:moksharan/data/repositories/content_providers.dart';
import 'package:moksharan/domain/entities/asset_pack.dart';
import 'package:moksharan/domain/entities/content.dart';
import 'package:moksharan/domain/repositories/asset_pack_service.dart';

final assetPackServiceProvider = Provider<AssetPackService>(
  (ref) => !kIsWeb && defaultTargetPlatform == TargetPlatform.android
      ? PlayAssetPackService()
      : const UnsupportedAssetPackService(),
);

/// A chapter whose media ships in an on-demand asset pack.
class ChapterPack {
  const new({
    required this.chapter,
    required this.pack,
    required this.manifestBytes,
  });

  final Chapter chapter;
  final String pack;

  /// Sum of the pack's file sizes from the media manifest. Shown when
  /// Play has not reported a download size.
  final int manifestBytes;
}

/// Chapters with a media pack, in chapter order.
final chapterPacksProvider = FutureProvider<List<ChapterPack>>((ref) async {
  final repo = ref.watch(contentRepositoryProvider);
  final chapters = await repo.chapters();
  final assets = await repo.mediaAssets();
  return [
    for (final c in chapters)
      if (c.mediaPack case final pack?)
        ChapterPack(
          chapter: c,
          pack: pack,
          manifestBytes: assets
              .where((a) => a.pack == pack)
              .fold(0, (sum, a) => sum + (a.sizeBytes ?? 0)),
        ),
  ];
});

/// Space kept free beyond the pack size before a download starts.
const int downloadStorageMargin = 20 * 1024 * 1024;

/// State of every chapter media pack, kept current from Play's updates.
class AssetPacksController extends Notifier<Map<String, PackState>> {
  final Set<String> _requested = {};

  AssetPackService get _service => ref.read(assetPackServiceProvider);

  @override
  Map<String, PackState> build() {
    final service = ref.watch(assetPackServiceProvider);
    final sub = service.updates.listen(_onUpdate);
    ref.onDispose(sub.cancel);

    final packs = ref.watch(chapterPacksProvider).value ?? const [];
    if (packs.isNotEmpty) scheduleMicrotask(refresh);
    return {for (final p in packs) p.pack: PackState(name: p.pack)};
  }

  List<String> get _names => state.keys.toList();

  void _put(PackState s) => state = {...state, s.name: s};

  /// Reloads every pack's state from Play.
  Future<void> refresh() async {
    final names = _names;
    if (names.isEmpty) return;
    final states = await _service.getStates(names);
    if (!ref.mounted) return;
    state = {...state, ...states};
  }

  void _onUpdate(PackState s) {
    if (!state.containsKey(s.name)) return;
    _put(s);
    if (s.needsConfirmation && _requested.remove(s.name)) {
      unawaited(_confirm(s.name));
    }
    if (s.status == PackStatus.completed && s.assetsPath == null) {
      unawaited(refresh());
    }
  }

  Future<void> _confirm(String pack) async {
    final ok = await _service.showConfirmationDialog();
    if (!ok && ref.mounted) {
      _put(state[pack]!.copyWith(status: PackStatus.canceled));
    }
  }

  /// Size to show before download: Play's figure, else the manifest's.
  int sizeOf(String pack) {
    final reported = state[pack]?.totalBytes ?? 0;
    if (reported > 0) return reported;
    final info = ref
        .read(chapterPacksProvider)
        .value
        ?.where((p) => p.pack == pack)
        .firstOrNull;
    return info?.manifestBytes ?? 0;
  }

  /// Starts a download after checking free space.
  Future<void> download(String pack) async {
    final current = state[pack] ?? PackState(name: pack);
    final free = await _service.availableBytes();
    if (!ref.mounted) return;
    if (free != null && free < sizeOf(pack) + downloadStorageMargin) {
      _put(
        current.copyWith(
          status: PackStatus.failed,
          error: PackError.insufficientStorage,
        ),
      );
      return;
    }

    _put(current.copyWith(status: PackStatus.pending, error: PackError.none));
    _requested.add(pack);
    try {
      await _service.fetch(pack);
    } on AssetPackException catch (e) {
      _requested.remove(pack);
      if (!ref.mounted) return;
      _put(
        current.copyWith(
          status: e.error == PackError.unavailable
              ? PackStatus.unavailable
              : PackStatus.failed,
          error: e.error,
        ),
      );
    }
  }

  Future<void> cancel(String pack) async {
    _requested.remove(pack);
    await _service.cancel(pack);
    await refresh();
  }

  /// Deletes a downloaded pack. Bookmarks and progress are separate
  /// data and are not touched.
  Future<void> remove(String pack) async {
    await _service.remove(pack);
    await refresh();
  }
}

final assetPacksProvider =
    NotifierProvider<AssetPacksController, Map<String, PackState>>(
      AssetPacksController.new,
    );

/// Pack state for a chapter, or null when its media is bundled.
final ProviderFamily<PackState?, String> chapterPackStateProvider =
    Provider.family<PackState?, String>((ref, chapterId) {
      final packs = ref.watch(chapterPacksProvider).value ?? const [];
      final pack = packs
          .where((p) => p.chapter.chapterId == chapterId)
          .firstOrNull
          ?.pack;
      if (pack == null) return null;
      return ref.watch(assetPacksProvider)[pack] ?? PackState(name: pack);
    });

/// Installed pack name to its assets folder. Equal values compare equal,
/// so download progress does not rebuild media paths.
@immutable
class InstalledPacks {
  const new(this.paths);

  final Map<String, String> paths;

  @override
  bool operator ==(Object other) =>
      other is InstalledPacks && mapEquals(other.paths, paths);

  @override
  int get hashCode => Object.hashAllUnordered(
    paths.entries.map((e) => Object.hash(e.key, e.value)),
  );
}

final installedPacksProvider = Provider<InstalledPacks>((ref) {
  final states = ref.watch(assetPacksProvider);
  return InstalledPacks({
    for (final s in states.values)
      if (s.isInstalled) s.name: s.assetsPath!,
  });
});

/// Size of media bundled with the app (always available), from the
/// media manifest.
final bundledMediaBytesProvider = FutureProvider<int>((ref) async {
  final assets = await ref.watch(contentRepositoryProvider).mediaAssets();
  return assets
      .where((a) => a.pack == null)
      .fold<int>(0, (sum, a) => sum + (a.sizeBytes ?? 0));
});

/// Free device storage for downloads, or null when unknown. Refreshes
/// when a pack is installed or removed.
final availableBytesProvider = FutureProvider<int?>((ref) {
  ref.watch(installedPacksProvider);
  return ref.watch(assetPackServiceProvider).availableBytes();
});
