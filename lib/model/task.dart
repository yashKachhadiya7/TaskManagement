import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Task {
  @HiveField(0)
  final int? id; // Add an id field, which can be null initially, and assigned when the task is added to the database.

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  final DateTime date;  // Field for task creation date

  @HiveField(5)
  final int priority;   // Field for task priority

  Task({
    this.id, // id can be null when creating a new task
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.date,
    required this.priority,
  });

  // Method to convert Task to a map for SQLite/Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'date': date.toIso8601String(),
      'priority': priority,
    };
  }

  // Method to convert map to Task (for SQLite)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
      date: DateTime.parse(map['date']),
      priority: map['priority'],
    );
  }
}
