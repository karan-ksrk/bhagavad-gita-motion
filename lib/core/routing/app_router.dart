import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moksharan/core/routing/app_shell.dart';
import 'package:moksharan/core/routing/not_found_screen.dart';
import 'package:moksharan/features/bookmarks/bookmarks_screen.dart';
import 'package:moksharan/features/chapters/chapter_detail_screen.dart';
import 'package:moksharan/features/chapters/chapters_screen.dart';
import 'package:moksharan/features/home/home_screen.dart';
import 'package:moksharan/features/reader/reader_screen.dart';
import 'package:moksharan/features/settings/about_screen.dart';
import 'package:moksharan/features/settings/settings_screen.dart';
import 'package:moksharan/features/shloka/shloka_screen.dart';

/// Route paths and builders. Screens navigate through these helpers and
/// never hardcode paths.
abstract final class AppRoutes {
  static const home = '/';
  static const chapters = '/chapters';
  static const bookmarks = '/bookmarks';
  static const settings = '/settings';

  static String chapter(int number) => '/chapters/$number';
  static const about = '/about';

  /// Reader for [chapter]; [sceneId] opens a specific scene, otherwise
  /// the reader resumes at the saved position.
  static String reader(int chapter, {String? sceneId}) => sceneId == null
      ? '/read/$chapter'
      : '/read/$chapter?scene=${Uri.encodeQueryComponent(sceneId)}';
  static String shloka(String verseId) => '/shloka/$verseId';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Parses a chapter path parameter. Invalid values become -1 so the
/// screen shows its own error state instead of crashing.
int _chapterParam(GoRouterState state) =>
    int.tryParse(state.pathParameters['chapter'] ?? '') ?? -1;

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.chapters,
                builder: (context, state) => const ChaptersScreen(),
                routes: [
                  GoRoute(
                    path: ':chapter',
                    builder: (context, state) =>
                        ChapterDetailScreen(chapter: _chapterParam(state)),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.bookmarks,
                builder: (context, state) => const BookmarksScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      // Full-screen routes above the shell (no bottom navigation).
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/read/:chapter',
        builder: (context, state) => ReaderScreen(
          chapter: _chapterParam(state),
          initialSceneId: state.uri.queryParameters['scene'],
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.about,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/shloka/:verseId',
        builder: (context, state) =>
            ShlokaScreen(verseId: state.pathParameters['verseId'] ?? ''),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
