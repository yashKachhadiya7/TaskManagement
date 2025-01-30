import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/task.dart';
import '../services/preferences_service.dart';
import '../viewmodel/preference_viewmodel.dart';
import '../viewmodel/task_viewmodel.dart';

class TaskScreen extends ConsumerWidget {
  TaskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskList = ref.watch(taskProvider);
    final preferences = ref.watch(preferencesProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth > 600;
       return Scaffold(
          appBar: AppBar(
            title: isTablet ? const Text('Task Manager',style: TextStyle(fontSize: 35),) :
            const Text("Task Manager",),
            actions: [
              IconButton(
                icon: isTablet ?
                Icon(preferences.isDarkMode ? Icons.dark_mode : Icons.light_mode,size: 40,) :
                Icon(preferences.isDarkMode ? Icons.dark_mode : Icons.light_mode),
                onPressed: () => ref.read(preferencesProvider.notifier).toggleDarkMode(),
              ),
              PopupMenuButton<String>(
                iconSize: isTablet ? 40 : 25,
                // onSelected: (value) => ref.read(preferencesProvider.notifier).changeSortOrder(value),
                onSelected: (value) async {
                  await PreferencesService.setSortOrder(value);
                  ref.read(taskProvider.notifier).sortTasks();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'date', child: isTablet ?
                  const Text("Sort by Date",style: TextStyle(fontSize: 20)) :
                  const Text("Sort by Date")),
                  PopupMenuItem(value: 'priority', child: isTablet ?
                  const Text("Sort by Priority",style: TextStyle(fontSize: 20)):
                  const Text("Sort by Priority")),
                ],
                icon: const Icon(Icons.sort),
              ),
            ],
          ),
          body: taskList.isEmpty
              ? const Center(child: Text("No tasks available"))
              : isTablet ?
          Row(
            children: [
              // Task List on the Left
              Expanded(
                flex: 2,
                child: _buildTaskList(taskList,ref),
              ),
              // Vertical Divider
              const VerticalDivider(width: 1),
              // Task Details on the Right
              Expanded(
                flex: 3,
                child: _buildTaskDetails(ref), // Show details inline
              ),
            ],
          ) :
          ListView.builder(
            itemCount: taskList.length,
            itemBuilder: (context, index) {
              final task = taskList[index];
              return  ListTile(
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Expanded(child: Text(task.description)),
                    const SizedBox(width: 10,),
                    Column(
                      children: [
                        Text(task.date.toString().substring(0,10)),
                        task.priority == 1 ?
                        const Text('High',style: TextStyle(color: Colors.red),) :
                        task.priority == 2 ?
                        const Text('Medium',style: TextStyle(color: Colors.orange)) :
                        const Text('Low',style: TextStyle(color: Colors.green))
                      ],
                    ),
                  ],
                ),
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) {
                    ref.read(taskProvider.notifier).toggleTaskStatus(index);
                  },
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue), // Icon for editing
                      onPressed: () {
                        _showTaskDialog(context, ref, task, index); // Call the edit dialog
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        ref.read(taskProvider.notifier).deleteTask(index);
                      },
                    ),
                  ],
                ),
              );

            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showTaskDialog(context, ref, null, null),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showTaskDialog(BuildContext context, WidgetRef ref, Task? task, int? index) {
    final TextEditingController titleController = TextEditingController(text: task?.title ?? "");
    final TextEditingController descController = TextEditingController(text: task?.description ?? "");
    ref.read(priorityProvider.notifier).state = task?.priority ?? 1;
    ref.read(selectedDateProvider.notifier).state = task?.date ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task == null ? "Add Task" : "Edit Task"),
        content: Consumer(
          builder: (context, ref, child) {

            int selectedPriority = ref.watch(priorityProvider);
            DateTime selectedDate = ref.watch(selectedDateProvider);
           return SingleChildScrollView(
             child: Column(
               mainAxisSize: MainAxisSize.min,
               children: [
                 TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
                 TextField(controller: descController, decoration: const InputDecoration(labelText: "Description")),
                 // Date Picker
                 ListTile(
                   title: Text("Date: ${selectedDate.toLocal().toString().substring(0,10)}"),

                   trailing: const Icon(Icons.calendar_today),
                   onTap: () async {
                     final DateTime?  pickedDate = await showDatePicker(
                       context: context,
                       initialDate: selectedDate,
                       firstDate: DateTime(2020),
                       lastDate: DateTime(2101),
                     );
                     if (pickedDate != null && pickedDate != selectedDate){
                       ref.read(selectedDateProvider.notifier).state = pickedDate;
                     }

                   },
                 ),
                 // Priority Dropdown
                 DropdownButton<int>(
                   value: selectedPriority,
                   onChanged: (int? newPriority) {
                     if (newPriority != null) {
                       // selectedPriority = newPriority;
                       ref.read(priorityProvider.notifier).state = newPriority;
                     }
                   },
                   items: const [
                     DropdownMenuItem(value: 1, child: Text("High")),
                     DropdownMenuItem(value: 2, child: Text("Medium")),
                     DropdownMenuItem(value: 3, child: Text("Low")),
                   ],
                 ),
               ],
             ),
           );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final selectedPriority = ref.read(priorityProvider);
              final selectedDate = ref.read(selectedDateProvider);
              final newTask = Task(
                id: task?.id ?? DateTime.now().millisecondsSinceEpoch, // Ensure unique ID
                title: titleController.text,
                description: descController.text,
                isCompleted: task?.isCompleted ?? false,
                date: selectedDate,
                priority: selectedPriority,
              );

              if (task == null) {
                ref.read(taskProvider.notifier).addTask(newTask);
              } else {
                ref.read(taskProvider.notifier).editTask(index!, newTask);
              }

              Navigator.pop(context);
            },
            child: Text(task == null ? "Add" : "Save"),
          ),
        ],
      ),
    );
  }

  //Show task details
   Widget _buildTaskDetails(WidgetRef ref) {
    final selectedTask = ref.watch(selectedTaskProvider);
    if (selectedTask == null) {
      return const Center(child: Text("Select a task to view details"));
    }
    final task = selectedTask;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(task.title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Date: ${task.date.toString().substring(0, 10)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Priority:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          task.priority == 1 ?
          const Text('High',style: TextStyle(fontSize: 20,color: Colors.red,fontWeight: FontWeight.bold),) :
          task.priority == 2 ?
          const Text('Medium',style: TextStyle(fontSize: 20,color: Colors.orange,fontWeight: FontWeight.bold)) :
          const Text('Low',style: TextStyle(fontSize: 20,color: Colors.green,fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("📖 Description:", style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(task.description,style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

   // Task List
   Widget _buildTaskList(List<Task> tasks,WidgetRef ref) {
     return ListView.builder(
       itemCount: tasks.length,
       itemBuilder: (context, index) {
         final task = tasks[index];
         return ListTile(
           leading: Checkbox(
             value: task.isCompleted,
             onChanged: (_) => ref.read(taskProvider.notifier).toggleTaskStatus(index),
           ),
             onTap: () {
               if (MediaQuery.of(context).size.width > 600) {
                 ref.read(selectedTaskProvider.notifier).state = task;
               }
             },
           title: Text(task.title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
           subtitle: Text("Date: ${task.date.toString().substring(0, 10)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
           trailing: Row(
             mainAxisSize: MainAxisSize.min,
             children: [
               IconButton(
                 icon: const Icon(Icons.edit, color: Colors.blue), // Icon for editing
                 onPressed: () {
                   _showTaskDialog(context, ref, task, index); // Call the edit dialog
                 },
               ),
               IconButton(
                 icon: const Icon(Icons.delete, color: Colors.red),
                 onPressed: () {
                   ref.read(taskProvider.notifier).deleteTask(index);
                 },
               ),
             ],
           ),
         );
       },
     );
   }

   // Define a StateProvider for managing priority
   final priorityProvider = StateProvider<int>((ref) {
     return 1;  // Default priority is 1
   });

   final selectedDateProvider = StateProvider<DateTime>((ref) {
     return DateTime.now(); // Default date
   });

   final selectedTaskProvider = StateProvider<Task?>((ref) => null);

}
