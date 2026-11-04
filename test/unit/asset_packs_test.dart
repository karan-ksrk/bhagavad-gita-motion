import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moksharan/data/asset_packs/asset_pack_providers.dart';
import 'package:moksharan/data/asset_packs/play_asset_pack_service.dart';
import 'package:moksharan/data/repositories/content_providers.dart';
import 'package:moksharan/data/repositories/local_content_repository.dart';
import 'package:moksharan/domain/entities/asset_pack.dart';
import 'package:moksharan/features/downloads/pack_status_text.dart';

import '../helpers/fake_asset_pack_service.dart';

const _pack = 'chapter_02';

/// Container on the real bundled content with [service] as Play.
Future<ProviderContainer> _container(FakeAssetPackService service) async {
  final c = ProviderContainer(
    overrides: [
      contentRepositoryProvider.overrideWithValue(
        LocalContentRepository(
          (path) => File('assets/content/$path').readAsString(),
        ),
      ),
      assetPackServiceProvider.overrideWithValue(service),
    ],
  );
  addTearDown(c.dispose);
  c.listen(assetPacksProvider, (_, _) {});
  await c.read(chapterPacksProvider.future);
  await _settle();
  return c;
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PackStateCodec', () {
    test('maps Play status and error codes', () {
      final s = PackStateCodec.decode(const {
        'name': _pack,
        'status': 2,
        'error': 0,
        'bytesDownloaded': 50,
        'totalBytes': 200,
      });
      expect(s.status, PackStatus.downloading);
      expect(s.progress, 0.25);

      expect(
        PackStateCodec.decode(const {'name': _pack, 'status': 5, 'error': -10})
            .error,
        PackError.insufficientStorage,
      );
      // Pack not served to this install: unavailable, not failed.
      expect(
        PackStateCodec.decode(const {'name': _pack, 'status': 5, 'error': -2})
            .status,
        PackStatus.unavailable,
      );
      expect(PackStateCodec.errorFromCode('-6'), PackError.network);
      expect(PackStateCodec.errorFromCode('-100'), PackError.other);
    });
  });

  group('PlayAssetPackService', () {
    const channel = MethodChannel(PlayAssetPackService.methodChannelName);
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    tearDown(() => messenger.setMockMethodCallHandler(channel, null));

    test('reads pack states', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'getPackStates');
        return {
          _pack: {
            'name': _pack,
            'status': 4,
            'error': 0,
            'assetsPath': '/data/packs/chapter_02/assets',
          },
        };
      });
      final states = await PlayAssetPackService().getStates([_pack]);
      expect(states[_pack]!.isInstalled, isTrue);
      expect(states[_pack]!.assetsPath, '/data/packs/chapter_02/assets');
    });

    test('a debug APK reports packs unavailable instead of throwing', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(code: '-1', message: 'APP_UNAVAILABLE');
      });
      final states = await PlayAssetPackService().getStates([_pack]);
      expect(states[_pack]!.status, PackStatus.unavailable);
    });

    test('fetch errors carry the Play error', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(code: '-6');
      });
      await expectLater(
        PlayAssetPackService().fetch(_pack),
        throwsA(
          isA<AssetPackException>().having(
            (e) => e.error,
            'error',
            PackError.network,
          ),
        ),
      );
    });
  });

  group('AssetPacksController', () {
    test(
      'chapter 2 is a pack; its media resolves only once installed',
      () async {
        final service = FakeAssetPackService();
        final c = await _container(service);

        expect(
          c.read(assetPacksProvider)[_pack]!.status,
          PackStatus.notInstalled,
        );
        var paths = await c.read(mediaAssetPathsProvider.future);
        expect(paths['ch02_scene002_poster'], isNull);
        expect(
          paths['ch01_scene001_poster'],
          'assets/posters/ch01_scene001_poster.webp',
        );

        await c.read(assetPacksProvider.notifier).download(_pack);
        await _settle();
        expect(c.read(assetPacksProvider)[_pack]!.isInstalled, isTrue);
        paths = await c.read(mediaAssetPathsProvider.future);
        expect(
          paths['ch02_scene002_poster'],
          '${packSourceDir(_pack)}/posters/ch02_scene002_poster.webp',
        );
        expect(File(paths['ch02_scene002_poster']!).existsSync(), isTrue);
      },
    );

    test('low storage blocks the download before calling Play', () async {
      final service = FakeAssetPackService(freeBytes: 1000);
      final c = await _container(service);
      await c.read(assetPacksProvider.notifier).download(_pack);

      final s = c.read(assetPacksProvider)[_pack]!;
      expect(s.status, PackStatus.failed);
      expect(s.error, PackError.insufficientStorage);
      expect(service.calls, isNot(contains('fetch:$_pack')));
    });

    test('network failure is reported and can be retried', () async {
      final service = FakeAssetPackService(fetchError: PackError.network);
      final c = await _container(service);
      final controller = c.read(assetPacksProvider.notifier);

      await controller.download(_pack);
      expect(c.read(assetPacksProvider)[_pack]!.error, PackError.network);

      service.fetchError = null;
      await controller.download(_pack);
      await _settle();
      expect(c.read(assetPacksProvider)[_pack]!.isInstalled, isTrue);
    });

    test(
      'cellular confirmation is asked only for a requested download',
      () async {
        final service = FakeAssetPackService(autoComplete: false);
        final c = await _container(service);

        service.emit(
          const PackState(name: _pack, status: PackStatus.waitingForWifi),
        );
        await _settle();
        expect(service.calls, isNot(contains('confirm')));

        await c.read(assetPacksProvider.notifier).download(_pack);
        service.emit(
          const PackState(name: _pack, status: PackStatus.waitingForWifi),
        );
        await _settle();
        expect(service.calls, contains('confirm'));
      },
    );

    test('remove deletes the pack and its media paths', () async {
      final service = FakeAssetPackService.installed(const [_pack]);
      final c = await _container(service);
      expect(c.read(installedPacksProvider).paths, contains(_pack));

      await c.read(assetPacksProvider.notifier).remove(_pack);
      expect(service.calls, contains('remove:$_pack'));
      expect(c.read(installedPacksProvider).paths, isEmpty);
      final paths = await c.read(mediaAssetPathsProvider.future);
      expect(paths['ch02_scene002_poster'], isNull);
    });
  });

  group('status text', () {
    test('formats sizes', () {
      expect(formatBytes(512), '512 B');
      expect(formatBytes(1200000), '1.1 MB');
      expect(formatBytes(250 * 1024 * 1024), '250 MB');
    });

    test('describes each state', () {
      expect(
        packStatusText(
          const PackState(name: _pack, status: PackStatus.notInstalled),
          size: 1200000,
        ),
        'Not downloaded · 1.1 MB',
      );
      expect(
        packStatusText(
          const PackState(
            name: _pack,
            status: PackStatus.downloading,
            bytesDownloaded: 1,
            totalBytes: 4,
          ),
          size: 4,
        ),
        'Downloading 25%',
      );
      expect(
        packStatusText(FakeAssetPackService.installedState(_pack), size: 0),
        'Downloaded · 1.0 MB',
      );
      expect(
        packStatusText(
          const PackState(name: _pack, status: PackStatus.unavailable),
          size: 0,
        ),
        'Download unavailable in this build',
      );
    });
  });
}
