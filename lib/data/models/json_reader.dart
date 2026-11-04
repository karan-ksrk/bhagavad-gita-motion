/// Typed, path-aware access to decoded JSON. Every failure names the file
/// and JSON path, e.g. `chapters/chapter_01.json: scenes[2].renderer`.
library;

class ContentFormatException implements Exception {
  const new(this.location, this.message);

  /// `file: json.path`.
  final String location;
  final String message;

  @override
  String toString() => '$location: $message';
}

class JsonReader {
  new(this._map, {required this.file, this.path = r'$'});

  /// Wraps a decoded JSON document, which must be an object.
  factory root(Object? decoded, {required String file}) {
    if (decoded is! Map<String, Object?>) {
      throw ContentFormatException(file, 'document must be a JSON object');
    }
    return JsonReader(decoded, file: file);
  }

  final Map<String, Object?> _map;
  final String file;
  final String path;

  String _at(String key) => path == r'$' ? key : '$path.$key';

  Never fail(String key, String message) =>
      throw ContentFormatException('$file: ${_at(key)}', message);

  bool has(String key) => _map.containsKey(key) && _map[key] != null;

  Object? _required(String key) {
    if (!_map.containsKey(key)) fail(key, 'is required');
    return _map[key];
  }

  String string(String key) {
    final value = _required(key);
    if (value is! String) fail(key, 'must be a string');
    if (value.trim().isEmpty) fail(key, 'must not be empty');
    return value;
  }

  String? optString(String key) {
    final value = _map[key];
    if (value == null) return null;
    if (value is! String) fail(key, 'must be a string or null');
    if (value.trim().isEmpty) fail(key, 'must not be empty; use null');
    return value;
  }

  int integer(String key, {int? min, int? max}) {
    final value = _required(key);
    if (value is! int) fail(key, 'must be an integer');
    _checkRange(key, value, min, max);
    return value;
  }

  int? optInteger(String key, {int? min, int? max}) {
    final value = _map[key];
    if (value == null) return null;
    if (value is! int) fail(key, 'must be an integer or null');
    _checkRange(key, value, min, max);
    return value;
  }

  double number(String key, {double? min, double? max}) {
    final value = _required(key);
    if (value is! num) fail(key, 'must be a number');
    final d = value.toDouble();
    _checkRange(key, d, min, max);
    return d;
  }

  bool boolean(String key, {bool? fallback}) {
    if (!_map.containsKey(key) && fallback != null) return fallback;
    final value = _required(key);
    if (value is! bool) fail(key, 'must be true or false');
    return value;
  }

  /// Parses a wire value into one of [values] using [wireOf].
  T enumValue<T extends Enum>(
    String key,
    List<T> values,
    String Function(T) wireOf, {
    T? fallback,
  }) {
    if (!has(key) && fallback != null) return fallback;
    final raw = string(key);
    for (final v in values) {
      if (wireOf(v) == raw) return v;
    }
    fail(key, '"$raw" is not one of: ${values.map(wireOf).join(', ')}');
  }

  JsonReader object(String key) {
    final value = _required(key);
    if (value is! Map<String, Object?>) fail(key, 'must be an object');
    return JsonReader(value, file: file, path: _at(key));
  }

  JsonReader? optObject(String key) {
    final value = _map[key];
    if (value == null) return null;
    if (value is! Map<String, Object?>) fail(key, 'must be an object or null');
    return JsonReader(value, file: file, path: _at(key));
  }

  /// A list of objects, each passed to [parse].
  List<T> objects<T>(
    String key,
    T Function(JsonReader) parse, {
    bool optional = false,
  }) {
    final value = optional ? _map[key] : _required(key);
    // Typed empty list: a bare `const []` here is List<Never>, which breaks
    // later list operations such as followedBy.
    if (value == null && optional) return List<T>.empty();
    if (value is! List<Object?>) fail(key, 'must be a list');
    return [
      for (var i = 0; i < value.length; i++)
        parse(_elementObject(key, i, value[i])),
    ];
  }

  /// A list of non-empty strings.
  List<String> strings(String key, {bool optional = false}) {
    final value = optional ? _map[key] : _required(key);
    if (value == null && optional) return const [];
    if (value is! List<Object?>) fail(key, 'must be a list');
    return [
      for (var i = 0; i < value.length; i++)
        if (value[i] case final String s when s.trim().isNotEmpty)
          s
        else
          fail('$key[$i]', 'must be a non-empty string'),
    ];
  }

  JsonReader _elementObject(String key, int i, Object? element) {
    if (element is! Map<String, Object?>) fail('$key[$i]', 'must be an object');
    return JsonReader(element, file: file, path: _at('$key[$i]'));
  }

  void _checkRange(String key, num value, num? min, num? max) {
    if (min != null && value < min) fail(key, 'must be >= $min');
    if (max != null && value > max) fail(key, 'must be <= $max');
  }
}
