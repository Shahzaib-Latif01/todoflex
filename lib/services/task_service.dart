import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task.dart';

class TaskService extends ChangeNotifier {
  final SharedPreferences _prefs;
  List<Task> _tasks = [];
  static const String _tasksKey = 'tasks';

  TaskService(this._prefs) {
    _loadTasks();
  }

  List<Task> get tasks => _tasks;

  void _loadTasks() {
    final tasksJson = _prefs.getStringList(_tasksKey) ?? [];
    _tasks = tasksJson
        .map((taskJson) => Task.fromJson(json.decode(taskJson)))
        .toList();
    notifyListeners();
  }

  Future<void> _saveTasks() async {
    final tasksJson = _tasks.map((task) => json.encode(task.toJson())).toList();
    await _prefs.setStringList(_tasksKey, tasksJson);
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _saveTasks();
  }

  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      await _saveTasks();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    await _saveTasks();
  }

  Future<void> toggleTaskCompletion(String id) async {
    final task = _tasks.firstWhere((task) => task.id == id);
    task.isCompleted = !task.isCompleted;
    await _saveTasks();
  }

  Future<void> updateTaskPriority(String id, TaskPriority priority) async {
    final task = _tasks.firstWhere((task) => task.id == id);
    task.priority = priority;
    await _saveTasks();
  }

  Future<void> updateTaskCategory(String id, String category) async {
    final task = _tasks.firstWhere((task) => task.id == id);
    task.category = category;
    await _saveTasks();
  }
}
