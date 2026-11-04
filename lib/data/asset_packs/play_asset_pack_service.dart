import 'dart:async';

import 'package:flutter/services.dart';
import 'package:moksharan/domain/entities/asset_pack.dart';
import 'package:moksharan/domain/repositories/asset_pack_service.dart';

/// [AssetPackService] over Play Asset Delivery, through the platform
/// channel in `android/app/src/main/kotlin/.../AssetPackChannel.kt`.
class PlayAssetPackService implements AssetPackService {
  new({
    this._method = const MethodChannel(methodChannelName),
    this._events = const EventChannel(eventChannelName),
  });

  static const methodChannelName = 'moksharan/asset_packs';
  static const eventChannelName = 'moksharan/asset_packs/events';

  final MethodChannel _method;
  final EventChannel _events;

  @override
  late final Stream<PackState> updates = _events.receiveBroadcastStream().map(
    (e) => PackStateCodec.decode(Map<Object?, Object?>.from(e as Map)),
  );

  Future<T?> _call<T>(String name, [Object? args]) async {
    try {
      return await _method.invokeMethod<T>(name, args);
    } on PlatformException catch (e) {
      throw AssetPackException(PackStateCodec.errorFromCode(e.code), e.message);
    } on MissingPluginException catch (e) {
      throw AssetPackException(PackError.unavailable, e.message);
    }
  }

  @override
  Future<Map<String, PackState>> getStates(List<String> packs) async {
    try {
      final raw = await _call<Map<Object?, Object?>>('getPackStates', {
        'packs': packs,
      });
      return {
        for (final entry in (raw ?? const {}).entries)
          entry.key! as String: PackStateCodec.decode(
            Map<Object?, Object?>.from(entry.value! as Map),
          ),
      };
    } on AssetPackException catch (e) {
      // Debug APKs and sideloads cannot use Play: report, don't throw.
      return {
        for (final p in packs)
          p: PackState(name: p, status: PackStatus.unavailable, error: e.error),
      };
    }
  }

  @override
  Future<void> fetch(String pack) => _call<void>('fetch', {'pack': pack});

  @override
  Future<void> cancel(String pack) => _call<void>('cancel', {'pack': pack});

  @override
  Future<void> remove(String pack) => _call<void>('remove', {'pack': pack});

  @override
  Future<bool> showConfirmationDialog() async =>
      await _call<bool>('showConfirmationDialog') ?? false;

  @override
  Future<int?> availableBytes() async {
    try {
      return await _call<int>('availableBytes');
    } on AssetPackException {
      return null;
    }
  }
}

/// Maps the channel's state maps and Play error codes to domain types.
abstract final class PackStateCodec {
  /// Play `AssetPackStatus` values, by index.
  static const List<PackStatus> _statuses = [
    PackStatus.unknown, // 0 UNKNOWN
    PackStatus.pending, // 1 PENDING
    PackStatus.downloading, // 2 DOWNLOADING
    PackStatus.transferring, // 3 TRANSFERRING
    PackStatus.completed, // 4 COMPLETED
    PackStatus.failed, // 5 FAILED
    PackStatus.canceled, // 6 CANCELED
    PackStatus.waitingForWifi, // 7 WAITING_FOR_WIFI
    PackStatus.notInstalled, // 8 NOT_INSTALLED
    PackStatus.requiresUserConfirmation, // 9 REQUIRES_USER_CONFIRMATION
  ];

  static PackState decode(Map<Object?, Object?> m) {
    final status = m['status'];
    final error = errorFromCode('${m['error'] ?? 0}');
    var mapped = status is int && status >= 0 && status < _statuses.length
        ? _statuses[status]
        : PackStatus.unknown;
    if (error == PackError.unavailable) mapped = PackStatus.unavailable;
    return PackState(
      name: m['name']! as String,
      status: mapped,
      error: error,
      bytesDownloaded: (m['bytesDownloaded'] as int?) ?? 0,
      totalBytes: (m['totalBytes'] as int?) ?? 0,
      assetsPath: m['assetsPath'] as String?,
      installedBytes: m['installedBytes'] as int?,
    );
  }

  /// Play `AssetPackErrorCode` (as a string, from `PlatformException.code`
  /// or the state map) to a UI-level error.
  static PackError errorFromCode(String code) => switch (int.tryParse(code)) {
    0 => PackError.none,
    -6 => PackError.network, // NETWORK_ERROR
    -10 => PackError.insufficientStorage, // INSUFFICIENT_STORAGE
    // APP_UNAVAILABLE, PACK_UNAVAILABLE, API_NOT_AVAILABLE,
    // APP_NOT_OWNED, UNRECOGNIZED_INSTALLATION.
    -1 || -2 || -5 || -13 || -15 => PackError.unavailable,
    _ => PackError.other,
  };
}
