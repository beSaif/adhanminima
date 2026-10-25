import 'package:shared_preferences/shared_preferences.dart';

/// Key-value persistence for user settings.
abstract interface class SettingsStore {
  Future<Map<String, Object?>> load();

  /// Saves [value] under [key]; null removes it.
  Future<void> save(String key, Object? value);
}

class PrefsSettingsStore implements SettingsStore {
  final _prefs = SharedPreferencesAsync();

  @override
  Future<Map<String, Object?>> load() => _prefs.getAll();

  @override
  Future<void> save(String key, Object? value) => switch (value) {
    null => _prefs.remove(key),
    bool v => _prefs.setBool(key, v),
    int v => _prefs.setInt(key, v),
    double v => _prefs.setDouble(key, v),
    String v => _prefs.setString(key, v),
    _ => throw ArgumentError.value(value, 'value', 'Unsupported type'),
  };
}

/// Keeps settings in memory; used by tests.
class MemorySettingsStore implements SettingsStore {
  MemorySettingsStore([Map<String, Object?>? initial]) : values = {...?initial};

  final Map<String, Object?> values;

  @override
  Future<Map<String, Object?>> load() async => {...values};

  @override
  Future<void> save(String key, Object? value) async {
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }
}
