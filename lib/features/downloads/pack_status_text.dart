import 'package:moksharan/domain/entities/asset_pack.dart';

/// Human-readable size, e.g. `1.2 MB`.
String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  const units = ['KB', 'MB', 'GB'];
  var value = bytes / 1024;
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  return '${value.toStringAsFixed(value < 10 ? 1 : 0)} ${units[unit]}';
}

/// One-line status of a chapter's media pack. [size] is the download
/// size to show before downloading.
String packStatusText(PackState s, {required int size}) {
  final sizeText = size > 0 ? ' · ${formatBytes(size)}' : '';
  if (s.isInstalled) {
    final used = s.installedBytes;
    return 'Downloaded${used == null ? '' : ' · ${formatBytes(used)}'}';
  }
  return switch (s.status) {
    PackStatus.pending => 'Starting download…',
    PackStatus.downloading => switch (s.progress) {
      final p? => 'Downloading ${(p * 100).round()}%',
      null => 'Downloading…',
    },
    PackStatus.transferring => 'Installing…',
    PackStatus.waitingForWifi ||
    PackStatus.requiresUserConfirmation => 'Waiting for Wi-Fi or approval',
    PackStatus.failed => switch (s.error) {
      PackError.network => 'Download failed: no connection',
      PackError.insufficientStorage => 'Not enough storage$sizeText needed',
      _ => 'Download failed',
    },
    PackStatus.unavailable => 'Download unavailable in this build',
    PackStatus.completed ||
    PackStatus.unknown ||
    PackStatus.notInstalled ||
    PackStatus.canceled => 'Not downloaded$sizeText',
  };
}
