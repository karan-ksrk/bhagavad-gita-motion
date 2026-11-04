import 'package:flutter_riverpod/misc.dart';
import 'package:moksharan/data/repositories/user_data_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-memory SharedPreferences override, optionally pre-filled.
Future<Override> prefsOverride([Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  return sharedPreferencesProvider.overrideWithValue(prefs);
}
