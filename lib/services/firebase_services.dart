import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class FirebaseService {
  final _taskCollection = FirebaseFirestore.instance.collection('tasks');

  Future<void> addTask(TaskModel task) async {
    await _taskCollection.doc(task.id).set(task.toMap());
  }

  Future<void> deleteTask(String id) async {
    await _taskCollection.doc(id).delete();
  }

  Future<void> updateTaskStatus(String id, bool isDone) async {
    await _taskCollection.doc(id).update({'isDone': isDone});
  }

  Stream<List<TaskModel>> getTasks() {
    return _taskCollection.orderBy('dueDate').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => TaskModel.fromMap(doc.data())).toList());
  }
}
