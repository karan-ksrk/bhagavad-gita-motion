import 'package:moksharan/domain/entities/asset_pack.dart';
import 'package:moksharan/domain/repositories/asset_pack_service.dart';

/// [AssetPackService] for platforms without Play Asset Delivery. Every
/// pack is unavailable; bundled content still works.
class UnsupportedAssetPackService implements AssetPackService {
  const new();

  static const _error = AssetPackException(
    PackError.unavailable,
    'Chapter downloads need the Play Store version of the app.',
  );

  @override
  Future<Map<String, PackState>> getStates(List<String> packs) async => {
    for (final p in packs)
      p: PackState(
        name: p,
        status: PackStatus.unavailable,
        error: PackError.unavailable,
      ),
  };

  @override
  Future<void> fetch(String pack) async => throw _error;

  @override
  Future<void> cancel(String pack) async {}

  @override
  Future<void> remove(String pack) async => throw _error;

  @override
  Future<bool> showConfirmationDialog() async => false;

  @override
  Future<int?> availableBytes() async => null;

  @override
  Stream<PackState> get updates => const Stream.empty();
}
