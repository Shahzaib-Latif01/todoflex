// task_model.dart
class TaskModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime dueDate;
  final bool isDone;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dueDate,
    required this.isDone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'dueDate': dueDate.toIso8601String(),
      'isDone': isDone,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      dueDate: DateTime.parse(map['dueDate']),
      isDone: map['isDone'] ?? false,
    );
  }
}

// Integration Notes:
// 1. Place this file under `lib/models/task_model.dart`.
// 2. Import it wherever task objects are used.
// 3. Ensure Firestore rules allow read/write.
// 4. Link this with the HomeScreen using the FirebaseService stream.
