import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moksharan/app.dart';
import 'package:moksharan/core/media/media_providers.dart';
import 'package:moksharan/core/routing/app_router.dart';
import 'package:moksharan/data/repositories/content_providers.dart';
import 'package:moksharan/data/repositories/local_content_repository.dart';

import 'fake_scene_player.dart';
import 'prefs.dart';

/// Pumps the full app and returns its provider container.
///
/// [location] navigates before settling. [textScale] tests accessibility
/// text sizes. [disableAnimations] simulates the system reduced-motion
/// setting.
Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  String? location,
  double textScale = 1,
  bool disableAnimations = false,
  Map<String, Object> prefs = const {},
}) async {
  final prefsOverrideValue = await prefsOverride(prefs);
  // Real content files, read synchronously: rootBundle's async I/O does
  // not complete inside the widget-test fake clock.
  final container = ProviderContainer(
    overrides: [
      contentRepositoryProvider.overrideWithValue(
        LocalContentRepository(
          (path) async => File('$contentAssetRoot/$path').readAsStringSync(),
        ),
      ),
      prefsOverrideValue,
      // No platform video decoder in widget tests.
      scenePlayerFactoryProvider.overrideWithValue(FakePlayerFactory().call),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MediaQuery(
        data: MediaQueryData(
          size: const Size(411, 891),
          textScaler: TextScaler.linear(textScale),
          disableAnimations: disableAnimations,
        ),
        child: const MoksharanApp(),
      ),
    ),
  );
  await tester.pumpAndSettle();

  if (location != null) {
    container.read(appRouterProvider).go(location);
    await tester.pumpAndSettle();
  }
  return container;
}

/// Location of the top-most visible route, including pushed routes
/// (`currentConfiguration.uri` ignores pushes).
String currentLocation(ProviderContainer container) => container
    .read(appRouterProvider)
    .routerDelegate
    .currentConfiguration
    .last
    .matchedLocation;

extension GoRouterTestX on ProviderContainer {
  GoRouter get router => read(appRouterProvider);
}
