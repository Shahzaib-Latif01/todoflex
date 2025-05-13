import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class TaskService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Task> _tasks = [];
  static const String _collection = 'tasks';

  TaskService() {
    // Listen to auth state changes and reload tasks when user changes
    _auth.authStateChanges().listen((user) {
      _loadTasks();
    });
    _loadTasks();
  }

  List<Task> get tasks => _tasks;

  void _loadTasks() {
    final userId = _auth.currentUser?.uid;
    print('TaskService: Current userId: $userId');
    if (userId == null) {
      _tasks = [];
      notifyListeners();
      return;
    }
    _firestore
        .collection(_collection)
        .where('userid', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      print(
          'TaskService: Fetched ${snapshot.docs.length} tasks from Firestore for userId: $userId');
      _tasks = snapshot.docs.map((doc) {
        print('TaskService: Task doc: ${doc.data()}');
        return Task.fromJson(doc.data());
      }).toList();
      notifyListeners();
    });
  }

  Future<void> addTask(Task task) async {
    final userId = _auth.currentUser?.uid;
    print('TaskService: Adding task for userId: $userId');
    if (userId == null) throw Exception('User not authenticated');
    final taskData = task.toJson();
    taskData['userid'] = userId;
    print('TaskService: Task data to add: $taskData');
    await _firestore.collection(_collection).doc(task.id).set(taskData);
  }

  Future<void> updateTask(Task task) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    final taskDoc = await _firestore.collection(_collection).doc(task.id).get();
    if (!taskDoc.exists || taskDoc.data()?['userid'] != userId) {
      throw Exception('Task not found or unauthorized');
    }
    final taskData = task.toJson();
    taskData['userid'] = userId;
    await _firestore.collection(_collection).doc(task.id).update(taskData);
  }

  Future<void> deleteTask(String id) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    final taskDoc = await _firestore.collection(_collection).doc(id).get();
    if (!taskDoc.exists || taskDoc.data()?['userid'] != userId) {
      throw Exception('Task not found or unauthorized');
    }
    await _firestore.collection(_collection).doc(id).delete();
  }

  Future<void> toggleTaskCompletion(String id) async {
    final task = _tasks.firstWhere((task) => task.id == id);
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      isCompleted: !task.isCompleted,
      priority: task.priority,
      category: task.category,
      userId: task.userId,
    );
    await updateTask(updatedTask);
  }

  Future<void> updateTaskPriority(String id, TaskPriority priority) async {
    final task = _tasks.firstWhere((task) => task.id == id);
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      isCompleted: task.isCompleted,
      priority: priority,
      category: task.category,
      userId: task.userId,
    );
    await updateTask(updatedTask);
  }

  Future<void> updateTaskCategory(String id, String category) async {
    final task = _tasks.firstWhere((task) => task.id == id);
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      isCompleted: task.isCompleted,
      priority: task.priority,
      category: category,
      userId: task.userId,
    );
    await updateTask(updatedTask);
  }
}
