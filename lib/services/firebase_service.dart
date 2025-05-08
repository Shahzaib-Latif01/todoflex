import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'tasks';

  Stream<List<TaskModel>> getTasks() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromMap(doc.data())).toList());
  }

  Future<void> addTask(TaskModel task) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final taskWithUserId = task.copyWith(userId: userId);
    await _firestore
        .collection(_collection)
        .doc(task.id)
        .set(taskWithUserId.toMap());
  }

  Future<void> updateTask(TaskModel task) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    // Verify that the task belongs to the current user
    final taskDoc = await _firestore.collection(_collection).doc(task.id).get();
    if (!taskDoc.exists || taskDoc.data()?['userId'] != userId) {
      throw Exception('Task not found or unauthorized');
    }

    await _firestore.collection(_collection).doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    // Verify that the task belongs to the current user
    final taskDoc = await _firestore.collection(_collection).doc(taskId).get();
    if (!taskDoc.exists || taskDoc.data()?['userId'] != userId) {
      throw Exception('Task not found or unauthorized');
    }

    await _firestore.collection(_collection).doc(taskId).delete();
  }
}
