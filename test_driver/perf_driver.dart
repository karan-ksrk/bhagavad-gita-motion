import 'package:integration_test/integration_test_driver.dart';

/// Saves the `watchPerformance` frame stats from
/// `integration_test/perf_test.dart` to
/// `build/integration_response_data.json`.
Future<void> main() => integrationDriver();
