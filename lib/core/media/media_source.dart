import 'dart:io';

import 'package:flutter/widgets.dart';

/// Media paths are either Flutter asset paths (`assets/...`, bundled) or
/// absolute file paths (installed Play asset packs, D-139).
bool isBundledMedia(String path) => path.startsWith('assets/');

/// Image provider for a media path from `mediaAssetPathsProvider`.
ImageProvider mediaImageProvider(String path) =>
    isBundledMedia(path) ? AssetImage(path) : FileImage(File(path));
