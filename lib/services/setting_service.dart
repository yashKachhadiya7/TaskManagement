import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Hive Box for settings
final _box = Hive.box('settings');

// Riverpod StateNotifier for Theme Mode
class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(_box.get('darkMode', defaultValue: false));

  void toggleTheme() {
    state = !state;
    _box.put('darkMode', state);
  }
}

// Riverpod Provider for Theme Mode
final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

// Riverpod StateNotifier for Sort Order
class SortOrderNotifier extends StateNotifier<String> {
  SortOrderNotifier() : super(_box.get('sortOrder', defaultValue: 'date'));

  void updateSortOrder(String newOrder) {
    state = newOrder;
    _box.put('sortOrder', newOrder);
  }
}

// Riverpod Provider for Sort Order
final sortOrderProvider = StateNotifierProvider<SortOrderNotifier, String>((ref) {
  return SortOrderNotifier();
});
