import 'package:uuid/uuid.dart';

enum TaskPriority { low, medium, high }

class Task {
  final String id;
  String title;
  String description;
  DateTime dueDate;
  bool isCompleted;
  TaskPriority priority;
  String category;

  Task({
    String? id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    required this.category,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'priority': priority.toString().split('.').last,
      'category': category,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      isCompleted: json['isCompleted'],
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString().split('.').last == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      category: json['category'],
    );
  }
}
