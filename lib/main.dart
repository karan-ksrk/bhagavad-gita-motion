import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moksharan/app.dart';

void main() {
  // Log framework errors in one place. A crash-reporting service is not
  // used until a privacy decision is recorded (see docs/DECISIONS.md).
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
    return true;
  };

  runApp(const ProviderScope(child: MoksharanApp()));
}
