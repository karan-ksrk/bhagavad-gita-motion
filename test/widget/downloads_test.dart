import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moksharan/data/repositories/user_data_providers.dart';
import 'package:moksharan/domain/entities/asset_pack.dart';

import '../helpers/fake_asset_pack_service.dart';
import '../helpers/pump_app.dart';

const _pack = 'chapter_02';

void main() {
  testWidgets('reader asks to download chapter 2, then shows its scenes', (
    tester,
  ) async {
    final service = FakeAssetPackService();
    await pumpApp(tester, location: '/read/2', packs: service);

    expect(find.text('Not downloaded · 1.1 MB'), findsOneWidget);
    expect(find.text('1 / 2'), findsNothing);

    await tester.tap(find.text('Download (1.1 MB)'));
    await tester.pumpAndSettle();
    expect(service.calls, contains('fetch:$_pack'));
    expect(find.text('1 / 2'), findsOneWidget);
  });

  testWidgets('bundled chapter 1 never asks for a download', (tester) async {
    await pumpApp(tester, location: '/read/1', packs: FakeAssetPackService());
    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.textContaining('Download'), findsNothing);
  });

  testWidgets('builds without Play show chapter 2 as unavailable', (
    tester,
  ) async {
    final service = FakeAssetPackService(
      initial: {
        _pack: const PackState(
          name: _pack,
          status: PackStatus.unavailable,
          error: PackError.unavailable,
        ),
      },
    );
    await pumpApp(tester, location: '/read/2', packs: service);
    expect(find.text('Download unavailable in this build'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('low storage shows a message and does not download', (
    tester,
  ) async {
    final service = FakeAssetPackService(freeBytes: 1000);
    await pumpApp(tester, location: '/read/2', packs: service);

    await tester.tap(find.text('Download (1.1 MB)'));
    await tester.pumpAndSettle();
    expect(find.text('Not enough storage · 1.1 MB needed'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(service.calls, isNot(contains('fetch:$_pack')));
  });

  testWidgets('chapter list marks downloaded and not-downloaded media', (
    tester,
  ) async {
    await pumpApp(tester, location: '/chapters');
    expect(find.text('Downloaded · 1.0 MB'), findsOneWidget);
  });

  testWidgets('chapter detail offers the download', (tester) async {
    await pumpApp(
      tester,
      location: '/chapters/2',
      packs: FakeAssetPackService(),
    );
    expect(find.text('Chapter 2 media'), findsOneWidget);
    expect(find.text('Download (1.1 MB)'), findsOneWidget);
  });

  testWidgets('storage screen removes media but keeps bookmarks and progress', (
    tester,
  ) async {
    final service = FakeAssetPackService.installed(const [_pack]);
    final container = await pumpApp(
      tester,
      location: '/read/2',
      packs: service,
    );
    container.read(bookmarksProvider.notifier).toggleScene('ch02_scene_001');

    container.router.go('/storage');
    await tester.pumpAndSettle();
    expect(find.text('Built-in sample media'), findsOneWidget);
    expect(find.text('Downloaded · 1.0 MB'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove chapter 2 media'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
    await tester.pumpAndSettle();

    expect(service.calls, contains('remove:$_pack'));
    expect(find.text('Not downloaded · 1.1 MB'), findsOneWidget);
    expect(find.text('Chapter 2 media removed'), findsOneWidget);
    expect(container.read(bookmarksProvider), hasLength(1));
    expect(container.read(progressProvider).byChapter, contains('chapter_02'));
  });
}
