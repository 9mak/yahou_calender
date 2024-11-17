import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/event.dart';

class DatabaseHelper {
  static const String databaseName = "calendar.db";
  static const int databaseVersion = 1;
  static const String table = "events";

  static Database? _database;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), databaseName);
    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $table (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            startTime TEXT NOT NULL,
            endTime TEXT NOT NULL,
            description TEXT,
            isAllDay INTEGER NOT NULL,
            location TEXT,
            colorIndex INTEGER NOT NULL DEFAULT 0,
            recurrenceType INTEGER NOT NULL DEFAULT 0,
            recurrenceEndDate TEXT,
            weeklyDays TEXT,
            monthlyDay INTEGER
          )
        ''');
      },
    );
  }

  static Future<int> insert(Event event) async {
    final Database db = await database;
    return await db.insert(
      table,
      event.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Event>> getAllEvents() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(table);
    return List.generate(maps.length, (i) => Event.fromJson(maps[i]));
  }

  static Future<int> update(Event event) async {
    final Database db = await database;
    return await db.update(
      table,
      event.toJson(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  static Future<int> delete(String id) async {
    final Database db = await database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
