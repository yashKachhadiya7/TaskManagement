import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/task.dart';

class TaskDatabase {
  static final TaskDatabase instance = TaskDatabase._init();
  static Database? _database;

  TaskDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String path) async {
    final dbPath = await getDatabasesPath();
    final pathWithDb = join(dbPath, path);
    return openDatabase(
      pathWithDb,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE tasks(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      description TEXT,
      isCompleted INTEGER,
      date TEXT,
      priority INTEGER
    )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if(oldVersion < 3){
      await db.execute('''
      ALTER TABLE tasks ADD COLUMN priority INTEGER DEFAULT 1;
      ''');
    }
  }

  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Delete task by id
  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id], // Delete task with the specified id
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) {
      return Task(
        id: maps[i]['id'],
        title: maps[i]['title'] ?? '', // Ensure title is not null
        description: maps[i]['description'] ?? '', // Ensure description is not null
        isCompleted: maps[i]['isCompleted'] == 1,
        date: maps[i]['date'] != null ? DateTime.parse(maps[i]['date']) : DateTime.now(), // Handle null date
        priority: maps[i]['priority'] ?? 1, // Default priority if null
      );

    });
  }
}
