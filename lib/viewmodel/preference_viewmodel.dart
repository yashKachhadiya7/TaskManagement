import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import '../services/preferences_service.dart';

class PreferencesViewModel extends StateNotifier<PreferencesState> {
  PreferencesViewModel()
      : super(PreferencesState(
    isDarkMode: PreferencesService.getDarkMode(),
    sortOrder: PreferencesService.getSortOrder(),
  ));

  // Toggle Dark Mode
  Future<void> toggleDarkMode() async {
    final newMode = !state.isDarkMode;
    await PreferencesService.setDarkMode(newMode);
    state = state.copyWith(isDarkMode: newMode);
  }

  static const String _sortOrderKey = 'sortOrder';

  static Future<void> setSortOrder(String order) async {
    final box = await Hive.openBox('preferences');
    box.put(_sortOrderKey, order);
  }

  static Future<String> getSortOrder() async {
    final box = await Hive.openBox('preferences');
    return box.get(_sortOrderKey, defaultValue: 'date'); // Default sorting by date
  }
}

// State model for preferences
class PreferencesState {
  final bool isDarkMode;
  final String sortOrder;

  PreferencesState({required this.isDarkMode, required this.sortOrder});

  PreferencesState copyWith({bool? isDarkMode, String? sortOrder}) {
    return PreferencesState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

// Riverpod Provider
final preferencesProvider =
StateNotifierProvider<PreferencesViewModel, PreferencesState>((ref) {
  return PreferencesViewModel();
});
