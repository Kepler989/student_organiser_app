import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/subject.dart';
import '../models/task.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'student_organizer.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        subject_id INTEGER NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (subject_id) REFERENCES subjects (id) ON DELETE CASCADE
      )
    ''');
  }

  // ── Subject CRUD ──────────────────────────────────────────────────────────

  Future<int> insertSubject(Subject subject) async {
    final db = await database;
    return await db.insert('subjects', subject.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Subject>> getAllSubjects() async {
    final db = await database;
    final maps = await db.query('subjects', orderBy: 'id ASC');
    return maps.map((m) => Subject.fromMap(m)).toList();
  }

  Future<int> deleteSubject(int id) async {
    final db = await database;
    // Also delete associated tasks
    await db.delete('tasks', where: 'subject_id = ?', whereArgs: [id]);
    return await db.delete('subjects', where: 'id = ?', whereArgs: [id]);
  }

  // ── Task CRUD ─────────────────────────────────────────────────────────────

  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Task>> getTasksForSubject(int subjectId) async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'subject_id = ?',
      whereArgs: [subjectId],
      orderBy: 'id ASC',
    );
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  Future<int> updateTaskCompletion(int id, bool completed) async {
    final db = await database;
    return await db.update(
      'tasks',
      {'completed': completed ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
