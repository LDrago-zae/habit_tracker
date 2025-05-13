import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = 'habit_tracker.db';
  static const _databaseVersion = 1;

  static const tableAppSettings = 'app_settings';
  static const tableHabits = 'habits';
  static const columnId = 'id';
  static const columnFirstLaunchDate = 'firstLaunchDate';
  static const columnName = 'name';
  static const columnDates = 'dates';

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = join(directory.path, _databaseName);
      print('Database path: $path'); // Debug log
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
      );
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE $tableAppSettings (
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnFirstLaunchDate TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE $tableHabits (
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnName TEXT NOT NULL,
          $columnDates TEXT
        )
      ''');
      print('Database tables created');
    } catch (e) {
      print('Error creating tables: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> debugGetAllHabitsRaw() async {
    try {
      final db = await database;
      return await db.rawQuery('SELECT * FROM $tableHabits');
    } catch (e) {
      print('Error querying habits: $e');
      return [];
    }
  }

  Future<DateTime?> getFirstLaunchDate() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.query(
        tableAppSettings,
        columns: [columnFirstLaunchDate],
        where: '$columnFirstLaunchDate IS NOT NULL',
        orderBy: '$columnFirstLaunchDate ASC',
        limit: 1,
      );
      if (result.isNotEmpty && result.first[columnFirstLaunchDate] != null) {
        return DateTime.parse(result.first[columnFirstLaunchDate] as String);
      }
      return null;
    } catch (e) {
      print('Error getting first launch date: $e');
      return null;
    }
  }

  Future<int> insertAppSettings(Map<String, dynamic> settings) async {
    try {
      final db = await database;
      return await db.insert(tableAppSettings, settings);
    } catch (e) {
      print('Error inserting app settings: $e');
      return 0;
    }
  }

  Future<Map<String, dynamic>?> getAppSettings(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableAppSettings,
        where: '$columnId = ?',
        whereArgs: [id],
      );
      return maps.isNotEmpty ? maps.first : null;
    } catch (e) {
      print('Error getting app settings: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllAppSettings() async {
    try {
      final db = await database;
      return await db.query(tableAppSettings);
    } catch (e) {
      print('Error getting all app settings: $e');
      return [];
    }
  }

  Future<int> updateAppSettings(Map<String, dynamic> settings) async {
    try {
      final db = await database;
      return await db.update(
        tableAppSettings,
        settings,
        where: '$columnId = ?',
        whereArgs: [settings[columnId]],
      );
    } catch (e) {
      print('Error updating app settings: $e');
      return 0;
    }
  }

  Future<int> deleteAppSettings(int id) async {
    try {
      final db = await database;
      return await db.delete(
        tableAppSettings,
        where: '$columnId = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting app settings: $e');
      return 0;
    }
  }

  Future<int> insertHabit(Map<String, dynamic> habit) async {
    try {
      final db = await database;
      return await db.insert(tableHabits, habit);
    } catch (e) {
      print('Insert habit error: $e');
      return 0;
    }
  }

  Future<Map<String, dynamic>?> getHabit(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableHabits,
        where: '$columnId = ?',
        whereArgs: [id],
      );
      return maps.isNotEmpty ? maps.first : null;
    } catch (e) {
      print('Error getting habit: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllHabits() async {
    try {
      final db = await database;
      return await db.query(tableHabits);
    } catch (e) {
      print('Error getting all habits: $e');
      return [];
    }
  }

  Future<int> updateHabit(Map<String, dynamic> habit) async {
    try {
      final db = await database;
      return await db.update(
        tableHabits,
        habit,
        where: '$columnId = ?',
        whereArgs: [habit[columnId]],
      );
    } catch (e) {
      print('Error updating habit: $e');
      return 0;
    }
  }

  Future<int> deleteHabit(int id) async {
    try {
      final db = await database;
      return await db.delete(
        tableHabits,
        where: '$columnId = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting habit: $e');
      return 0;
    }
  }

  Future<int> checkHabitDate(int id, DateTime date, bool isChecked) async {
    try {
      final db = await database;
      final habit = await getHabit(id);
      if (habit == null) return 0;

      List<DateTime> dates = habit[columnDates] != null
          ? (jsonDecode(habit[columnDates] as String) as List<dynamic>)
          .map((dateStr) => DateTime.parse(dateStr as String))
          .toList()
          : [];

      if (isChecked && !dates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day)) {
        dates.add(date);
      } else if (!isChecked) {
        dates.removeWhere((d) => d.year == date.year && d.month == date.month && d.day == date.day);
      }

      return await db.update(
        tableHabits,
        {
          columnId: id,
          columnName: habit[columnName],
          columnDates: jsonEncode(dates.map((d) => d.toIso8601String()).toList()),
        },
        where: '$columnId = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error checking habit date: $e');
      return 0;
    }
  }

  Future<int> updateHabitName(int id, String newName) async {
    try {
      final db = await database;
      final habit = await getHabit(id);
      if (habit == null) return 0;

      return await db.update(
        tableHabits,
        {
          columnId: id,
          columnName: newName,
          columnDates: habit[columnDates],
        },
        where: '$columnId = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error updating habit name: $e');
      return 0;
    }
  }
}