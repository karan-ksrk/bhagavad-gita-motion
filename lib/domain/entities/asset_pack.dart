/// State of an on-demand chapter media pack (Play Asset Delivery, D-139).
///
/// Pure Dart. The platform layer maps Play's `AssetPackStatus` and
/// `AssetPackErrorCode` onto these values.
library;

/// Mirrors Play's `AssetPackStatus`, plus [unavailable] for builds that
/// cannot deliver packs (debug APKs, sideloads, non-Android).
enum PackStatus {
  unknown,
  pending,
  downloading,
  transferring,
  completed,
  failed,
  canceled,
  waitingForWifi,
  notInstalled,
  requiresUserConfirmation,
  unavailable,
}

/// Reasons a pack cannot be downloaded, grouped for the UI.
enum PackError {
  none,
  network,
  insufficientStorage,

  /// Play cannot serve this pack to this install (not from Play, pack
  /// missing from the bundle, Play Store unavailable).
  unavailable,
  other,
}

class PackState {
  const new({
    required this.name,
    this.status = PackStatus.unknown,
    this.error = PackError.none,
    this.bytesDownloaded = 0,
    this.totalBytes = 0,
    this.assetsPath,
    this.installedBytes,
  });

  final String name;
  final PackStatus status;
  final PackError error;
  final int bytesDownloaded;

  /// Download size reported by Play; 0 when unknown.
  final int totalBytes;

  /// Absolute path of the installed pack's assets folder; null until
  /// [PackStatus.completed].
  final String? assetsPath;

  /// Disk space used by the installed pack, when known.
  final int? installedBytes;

  bool get isInstalled => status == PackStatus.completed && assetsPath != null;

  /// True while Play is fetching or unpacking.
  bool get isActive =>
      status == PackStatus.pending ||
      status == PackStatus.downloading ||
      status == PackStatus.transferring;

  /// True when Play is waiting for the user to allow a cellular
  /// download.
  bool get needsConfirmation =>
      status == PackStatus.waitingForWifi ||
      status == PackStatus.requiresUserConfirmation;

  /// Download fraction 0..1, or null when the total is unknown.
  double? get progress =>
      totalBytes > 0 ? (bytesDownloaded / totalBytes).clamp(0.0, 1.0) : null;

  PackState copyWith({PackStatus? status, PackError? error}) => PackState(
    name: name,
    status: status ?? this.status,
    error: error ?? this.error,
    bytesDownloaded: bytesDownloaded,
    totalBytes: totalBytes,
    assetsPath: assetsPath,
    installedBytes: installedBytes,
  );

  @override
  String toString() =>
      'PackState($name, ${status.name}, ${error.name}, '
      '$bytesDownloaded/$totalBytes)';
}

/// Thrown by an `AssetPackService` call that Play rejected.
class AssetPackException implements Exception {
  const new(this.error, [this.message]);

  final PackError error;
  final String? message;

  @override
  String toString() => 'AssetPackException(${error.name}: $message)';
}
