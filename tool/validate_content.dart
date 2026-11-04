// Validates bundled content before it can ship.
//
// Usage:
//   dart run tool/validate_content.dart            # development rules
//   dart run tool/validate_content.dart --release  # reject sample/draft
//   dart run tool/validate_content.dart --root path/to/assets/content
//
// Exit code 0: no errors (warnings allowed). 1: errors. 2: bad usage.

import 'dart:io';

import 'package:moksharan/data/content/content_bundle.dart';
import 'package:moksharan/data/models/json_reader.dart';
import 'package:moksharan/data/validation/content_validator.dart';

Future<void> main(List<String> args) async {
  var release = false;
  var root = 'assets/content';

  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--release':
        release = true;
      case '--root' when i + 1 < args.length:
        root = args[++i];
      case '-h' || '--help':
        stdout.writeln(
          'Usage: dart run tool/validate_content.dart [--release] [--root DIR]',
        );
        return;
      default:
        stderr.writeln('Unknown argument: ${args[i]}');
        exitCode = 2;
        return;
    }
  }

  final rootDir = Directory(root);
  if (!rootDir.existsSync()) {
    stderr.writeln('Content root not found: $root');
    exitCode = 2;
    return;
  }
  // Media paths are relative to assets/, the parent of the content root.
  // Asset pack files live in android/<pack>/src/main/assets/ (D-139).
  final assetsDir = rootDir.parent.path;
  final projectDir = rootDir.parent.parent.path;

  final ContentBundle bundle;
  try {
    bundle = await ContentBundle.load(
      (path) => File('$root/$path').readAsString(),
    );
  } on ContentFormatException catch (e) {
    stdout
      ..writeln('ERROR $e')
      ..writeln('\nContent validation failed: 1 structural error.');
    exitCode = 1;
    return;
  }

  final issues = ContentValidator(
    release: release,
    assetExists: (a) => File(
      a.pack == null
          ? '$assetsDir/${a.path}'
          : '$projectDir/android/${a.pack}/src/main/assets/${a.path}',
    ).existsSync(),
  ).validate(bundle);

  final errors = issues.where((i) => i.severity == Severity.error).length;
  final warnings = issues.length - errors;
  final sceneCount = bundle.chapterContents.values.fold(
    0,
    (n, c) => n + c.scenes.length,
  );

  issues.forEach(stdout.writeln);
  stdout.writeln(
    '\n${release ? 'Release' : 'Development'} validation: '
    '$errors error(s), $warnings warning(s). '
    '${bundle.manifest.chapters.length} chapters, '
    '$sceneCount scenes, ${bundle.shlokas.length} shlokas, '
    '${bundle.mediaAssets.length} media assets.',
  );
  exitCode = errors > 0 ? 1 : 0;
}
