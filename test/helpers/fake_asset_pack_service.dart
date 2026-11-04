import 'dart:async';

import 'package:moksharan/domain/entities/asset_pack.dart';
import 'package:moksharan/domain/repositories/asset_pack_service.dart';

/// Source folder of a pack in the repo; used as the "installed" path.
String packSourceDir(String pack) => 'android/$pack/src/main/assets';

/// Scriptable [AssetPackService]. Packs start in the `initial` states;
/// [fetch] moves through pending, downloading, and completed unless
/// [fetchError] is set or [autoComplete] is false.
class FakeAssetPackService implements AssetPackService {
  new({
    Map<String, PackState>? initial,
    this.freeBytes = 1 << 34,
    this.autoComplete = true,
    this.fetchError,
  }) : states = {...?initial};

  /// Every pack installed from its repo source folder.
  factory installed(List<String> packs) => FakeAssetPackService(
    initial: {for (final p in packs) p: installedState(p)},
  );

  static PackState installedState(String pack) => PackState(
    name: pack,
    status: PackStatus.completed,
    assetsPath: packSourceDir(pack),
    installedBytes: 1100000,
  );

  final Map<String, PackState> states;
  int? freeBytes;
  bool autoComplete;
  PackError? fetchError;
  bool confirmResult = true;

  final List<String> calls = [];
  final StreamController<PackState> _updates = StreamController.broadcast();

  /// Pushes a state as if Play reported it.
  void emit(PackState s) {
    states[s.name] = s;
    _updates.add(s);
  }

  @override
  Stream<PackState> get updates => _updates.stream;

  @override
  Future<Map<String, PackState>> getStates(List<String> packs) async {
    calls.add('getStates');
    return {
      for (final p in packs)
        p:
            states[p] ??
            PackState(
              name: p,
              status: PackStatus.notInstalled,
              totalBytes: 1200000,
            ),
    };
  }

  @override
  Future<void> fetch(String pack) async {
    calls.add('fetch:$pack');
    final error = fetchError;
    if (error != null) throw AssetPackException(error);
    emit(
      PackState(
        name: pack,
        status: PackStatus.downloading,
        bytesDownloaded: 600000,
        totalBytes: 1200000,
      ),
    );
    if (autoComplete) emit(installedState(pack));
  }

  @override
  Future<void> cancel(String pack) async {
    calls.add('cancel:$pack');
    states[pack] = PackState(name: pack, status: PackStatus.canceled);
  }

  @override
  Future<void> remove(String pack) async {
    calls.add('remove:$pack');
    states[pack] = PackState(
      name: pack,
      status: PackStatus.notInstalled,
      totalBytes: 1200000,
    );
  }

  @override
  Future<bool> showConfirmationDialog() async {
    calls.add('confirm');
    return confirmResult;
  }

  @override
  Future<int?> availableBytes() async => freeBytes;
}
