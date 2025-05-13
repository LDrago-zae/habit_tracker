import 'package:flutter/material.dart';
import 'package:habit_tracker/database/database_helper.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';

class HabitProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<AppSettings> _appSettings = [];
  List<Habit> _habits = [];

  List<AppSettings> get appSettings => _appSettings;
  List<Habit> get habits => _habits;

  Future<void> loadData() async {
    try {
      final settingsData = await _dbHelper.getAllAppSettings();
      final habitsData = await _dbHelper.getAllHabits();
      _appSettings = settingsData.map((map) => AppSettings.fromMap(map)).toList();
      _habits = habitsData.map((map) => Habit.fromMap(map)).toList();
      print('Loaded habits: ${_habits.map((h) => h.name).toList()}');
      notifyListeners();
    } catch (e) {
      print('Error loading data: $e');
      _appSettings = [];
      _habits = [];
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> debugGetHabitsRaw() async {
    try {
      return await _dbHelper.debugGetAllHabitsRaw();
    } catch (e) {
      print('Error debugging habits: $e');
      return [];
    }
  }

  Future<DateTime?> getFirstLaunchDate() async {
    try {
      return await _dbHelper.getFirstLaunchDate();
    } catch (e) {
      print('Error getting first launch date: $e');
      return null;
    }
  }

  Future<void> saveAppSettings(AppSettings settings) async {
    try {
      await _dbHelper.insertAppSettings(settings.toMap());
      await loadData();
    } catch (e) {
      print('Error saving app settings: $e');
    }
  }

  Future<void> saveHabit(Habit habit) async {
    try {
      final result = await _dbHelper.insertHabit(habit.toMap());
      print('Inserted habit: ${habit.name}, result: $result');
      await loadData();
    } catch (e) {
      print('Error saving habit: $e');
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await _dbHelper.updateHabit(habit.toMap());
      await loadData();
    } catch (e) {
      print('Error updating habit: $e');
    }
  }

  Future<void> deleteHabit(int id) async {
    try {
      await _dbHelper.deleteHabit(id);
      await loadData();
    } catch (e) {
      print('Error deleting habit: $e');
    }
  }

  Future<void> checkHabitDate(int id, DateTime date, bool isChecked) async {
    try {
      await _dbHelper.checkHabitDate(id, date, isChecked);
      await loadData();
    } catch (e) {
      print('Error checking habit date: $e');
    }
  }

  Future<void> updateHabitName(int id, String newName) async {
    try {
      await _dbHelper.updateHabitName(id, newName);
      await loadData();
    } catch (e) {
      print('Error updating habit name: $e');
    }
  }
}