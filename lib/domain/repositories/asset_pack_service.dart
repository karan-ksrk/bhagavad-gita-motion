import 'package:moksharan/domain/entities/asset_pack.dart';

/// Downloads, removes, and locates on-demand chapter media packs.
///
/// Implementations: `PlayAssetPackService` (Android, Play Asset
/// Delivery), `UnsupportedAssetPackService` (other platforms), fakes in
/// tests. Failed calls throw [AssetPackException].
abstract interface class AssetPackService {
  /// Current state of each pack. A pack this install cannot get is
  /// returned with [PackStatus.unavailable], not thrown.
  Future<Map<String, PackState>> getStates(List<String> packs);

  /// Starts (or resumes) a download. Progress arrives on [updates].
  Future<void> fetch(String pack);

  Future<void> cancel(String pack);

  /// Deletes an installed pack's files.
  Future<void> remove(String pack);

  /// Shows Play's dialog asking to download over mobile data. Returns
  /// true when the user agreed.
  Future<bool> showConfirmationDialog();

  /// Free space for downloads, or null when unknown.
  Future<int?> availableBytes();

  /// State changes for packs being fetched.
  Stream<PackState> get updates;
}
