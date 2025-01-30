import 'package:hive/hive.dart';

class PreferencesService {
  static final _box = Hive.box('preferences');

  // Get dark mode preference
  static bool getDarkMode() {
    return _box.get('darkMode', defaultValue: false);
  }

  // Set dark mode preference
  static Future<void> setDarkMode(bool value) async {
    await _box.put('darkMode', value);
  }

  // Get task sort order preference (default is 'date')
  static String getSortOrder() {
    return _box.get('sortOrder', defaultValue: 'date');
  }

  // Set task sort order preference
  static Future<void> setSortOrder(String order) async {
    await _box.put('sortOrder', order);
  }
}
