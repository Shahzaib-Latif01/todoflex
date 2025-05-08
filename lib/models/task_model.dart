import 'package:uuid/uuid.dart';

enum TaskPriority { low, medium, high }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime dueDate;
  final bool isCompleted;
  final String userId;
  final TaskPriority priority;

  TaskModel({
    String? id,
    required this.title,
    required this.description,
    required this.category,
    required this.dueDate,
    required this.userId,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'userId': userId,
      'priority': priority.index,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      dueDate: DateTime.parse(map['dueDate']),
      isCompleted: map['isCompleted'] == 1,
      userId: map['userId'],
      priority: TaskPriority.values[map['priority'] ?? 1],
    );
  }

  TaskModel copyWith({
    String? title,
    String? description,
    String? category,
    DateTime? dueDate,
    bool? isCompleted,
    String? userId,
    TaskPriority? priority,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId,
      priority: priority ?? this.priority,
    );
  }
}
