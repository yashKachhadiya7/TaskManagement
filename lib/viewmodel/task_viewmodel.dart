import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/task.dart';
import '../services/preferences_service.dart';
import '../services/task_database.dart';

class TaskViewModel extends StateNotifier<List<Task>> {
  TaskViewModel() : super([]) {
    _loadTasks();
  }

  // Load tasks from SQLite
  Future<void> _loadTasks() async {
    final tasks = await TaskDatabase.instance.getTasks();
    state = tasks;
    sortTasks();
  }

  // Sorting function
  Future<void> sortTasks() async {
    final sortOrder = await PreferencesService.getSortOrder(); // Get sorting preference

    List<Task> sortedTasks = [...state]; // Create a copy of the list

    if (sortOrder == 'date') {
      sortedTasks.sort((a, b) => a.date.compareTo(b.date)); // Sort by date
    } else if (sortOrder == 'priority') {
      sortedTasks.sort((a, b) => a.priority.compareTo(b.priority)); // Sort by priority (higher first)
    }
    state = sortedTasks; // Update the state with the sorted list
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    await TaskDatabase.instance.insertTask(task);
    _loadTasks();
  }

  // Edit an existing task
  Future<void> editTask(int index, Task updatedTask) async {
    // Update the task in the database
    await TaskDatabase.instance.updateTask(updatedTask);
    final updatedState = state.map((task) {
      return task.id == updatedTask.id ? updatedTask : task;
    }).toList();

    state = updatedState;
    sortTasks(); // Ensure the sort order remains the same
  }


  // Toggle task completion
  Future<void> toggleTaskStatus(int index) async {
    final task = state[index];
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      isCompleted: !task.isCompleted,
      date: task.date,
      priority: task.priority
    );
    await TaskDatabase.instance.updateTask(updatedTask);
   final updatedState = [...state];
    updatedState[index] = updatedTask;
    state = updatedState;
    sortTasks();
  }

  // Delete a task
  Future<void> deleteTask(int index) async {
    final task = state[index];
    await TaskDatabase.instance.deleteTask(task.id!);
    final updatedState = [...state];
    updatedState.removeAt(index);
    state = updatedState;
    sortTasks();
  }

}

// Riverpod Provider
final taskProvider = StateNotifierProvider<TaskViewModel, List<Task>>((ref) {
  return TaskViewModel();
});



