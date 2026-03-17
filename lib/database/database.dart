import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/task.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  static Future<Database> _initDatabase() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'task_recorder_pro.db');
    return await databaseFactoryFfi.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE tasks (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              description TEXT DEFAULT '',
              category TEXT DEFAULT 'General',
              priority TEXT DEFAULT 'Medium',
              status TEXT DEFAULT 'Pending',
              scheduled_date TEXT,
              created_at TEXT NOT NULL,
              completed_at TEXT,
              time_spent_seconds INTEGER DEFAULT 0,
              timer_started_at TEXT,
              subtasks TEXT DEFAULT '[]'
            )
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            final tableInfo = await db.rawQuery('PRAGMA table_info(tasks)');
            final hasSubtasks = tableInfo.any((c) => c['name'] == 'subtasks');
            if (!hasSubtasks) {
              await db.execute("ALTER TABLE tasks ADD COLUMN subtasks TEXT DEFAULT '[]'");
            }
          }
        },
      ),
    );
  }

  // ───── Task CRUD ─────

  static Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  static Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update('tasks', task.toMap(),
        where: 'id = ?', whereArgs: [task.id]);
  }

  static Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  static Future<Task?> getTask(int id) async {
    final db = await database;
    final results =
        await db.query('tasks', where: 'id = ?', whereArgs: [id], limit: 1);
    if (results.isEmpty) return null;
    return Task.fromMap(results.first);
  }

  static Future<List<Task>> getAllTasks({
    String? searchQuery,
    String? categoryFilter,
    String? statusFilter,
    String? priorityFilter,
    String? sortBy,
    bool ascending = true,
  }) async {
    final db = await database;
    final where = <String>[];
    final whereArgs = <dynamic>[];

    if (searchQuery != null && searchQuery.isNotEmpty) {
      where.add('(title LIKE ? OR description LIKE ?)');
      whereArgs.add('%$searchQuery%');
      whereArgs.add('%$searchQuery%');
    }
    if (categoryFilter != null && categoryFilter.isNotEmpty) {
      where.add('category = ?');
      whereArgs.add(categoryFilter);
    }
    if (statusFilter != null && statusFilter.isNotEmpty) {
      where.add('status = ?');
      whereArgs.add(statusFilter);
    }
    if (priorityFilter != null && priorityFilter.isNotEmpty) {
      where.add('priority = ?');
      whereArgs.add(priorityFilter);
    }

    final orderBy = sortBy != null
        ? '$sortBy ${ascending ? 'ASC' : 'DESC'}'
        : 'created_at DESC';

    final results = await db.query(
      'tasks',
      where: where.isNotEmpty ? where.join(' AND ') : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: orderBy,
    );
    return results.map((m) => Task.fromMap(m)).toList();
  }

  static Future<List<Task>> getTasksForDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    final results = await db.query(
      'tasks',
      where: 'COALESCE(scheduled_date, created_at) LIKE ?',
      whereArgs: ['$dateStr%'],
    );
    return results.map((m) => Task.fromMap(m)).toList();
  }

  static Future<List<Task>> getTasksInRange(
      DateTime start, DateTime end) async {
    final db = await database;
    final results = await db.query(
      'tasks',
      where: 'COALESCE(scheduled_date, created_at) >= ? AND COALESCE(scheduled_date, created_at) <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );
    return results.map((m) => Task.fromMap(m)).toList();
  }

  // ───── Analytics Queries ─────

  static Future<int> getTotalTaskCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as cnt FROM tasks');
    return (result.first['cnt'] as int?) ?? 0;
  }

  static Future<int> getCompletedTaskCount() async {
    final db = await database;
    final result = await db.rawQuery(
        "SELECT COUNT(*) as cnt FROM tasks WHERE status = 'Completed'");
    return (result.first['cnt'] as int?) ?? 0;
  }

  static Future<int> getPendingTaskCount() async {
    final db = await database;
    final result = await db.rawQuery(
        "SELECT COUNT(*) as cnt FROM tasks WHERE status = 'Pending'");
    return (result.first['cnt'] as int?) ?? 0;
  }

  static Future<double> getTotalHoursLogged() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COALESCE(SUM(time_spent_seconds), 0) as total FROM tasks');
    final totalSeconds = (result.first['total'] as int?) ?? 0;
    return totalSeconds / 3600.0;
  }

  static Future<int> getCompletedTasksToday() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final result = await db.rawQuery(
        "SELECT COUNT(*) as cnt FROM tasks WHERE status = 'Completed' AND completed_at LIKE '$today%'");
    return (result.first['cnt'] as int?) ?? 0;
  }

  static Future<Map<String, int>> getCategoryDistribution() async {
    final db = await database;
    final results = await db.rawQuery(
        'SELECT category, COUNT(*) as cnt FROM tasks GROUP BY category ORDER BY cnt DESC');
    final map = <String, int>{};
    for (final row in results) {
      map[row['category'] as String] = (row['cnt'] as int?) ?? 0;
    }
    return map;
  }

  static Future<Map<int, int>> getWeeklyCompletionCounts() async {
    final db = await database;
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final counts = <int, int>{};

    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      final dayStr = day.toIso8601String().split('T')[0];
      final result = await db.rawQuery(
          "SELECT COUNT(*) as cnt FROM tasks WHERE status = 'Completed' AND completed_at LIKE '$dayStr%'");
      counts[i] = (result.first['cnt'] as int?) ?? 0;
    }
    return counts;
  }

  static Future<List<Task>> getRecentTasks({int limit = 5}) async {
    final db = await database;
    final results = await db.query('tasks',
        orderBy: 'created_at DESC', limit: limit);
    return results.map((m) => Task.fromMap(m)).toList();
  }
}
