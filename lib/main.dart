import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:taskmanagement/viewmodel/preference_viewmodel.dart';
import 'package:taskmanagement/views/task_screen.dart';

void main() async {

  // Initialize Hive and open a box for storing settings
  await Hive.initFlutter();
  await Hive.openBox('preferences');

  runApp(
       const ProviderScope(
          child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(preferencesProvider).isDarkMode;

    return AnimatedSwitcher(
      
      duration: const Duration(milliseconds: 700),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: MaterialApp(
        key: ValueKey(isDarkMode),
        debugShowCheckedModeBanner: false,
        theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
        home: TaskScreen(),
      ),
    );
  }
}

