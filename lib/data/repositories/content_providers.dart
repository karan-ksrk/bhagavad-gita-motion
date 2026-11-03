import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moksharan/data/repositories/local_content_repository.dart';
import 'package:moksharan/domain/entities/content.dart';
import 'package:moksharan/domain/repositories/content_repository.dart';

/// Root of bundled content inside the Flutter asset bundle.
const contentAssetRoot = 'assets/content';

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => LocalContentRepository(
    (path) => rootBundle.loadString('$contentAssetRoot/$path'),
  ),
);

final chaptersProvider = FutureProvider<List<Chapter>>(
  (ref) => ref.watch(contentRepositoryProvider).chapters(),
);
