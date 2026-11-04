import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moksharan/app.dart';
import 'package:moksharan/data/repositories/prefs_user_data_repository.dart';
import 'package:moksharan/data/repositories/user_data_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // Bundled font license for the in-app licenses page (D-118).
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(const [
      'Tiro Devanagari Sanskrit (font)',
    ], await rootBundle.loadString('assets/fonts/OFL.txt'));
  });

  // Local user data (settings, progress, bookmarks). No network.
  final prefs = await SharedPreferences.getInstance();
  await PrefsUserDataRepository(prefs).migrate();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MoksharanApp(),
    ),
  );
}
