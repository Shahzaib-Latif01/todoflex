// add_task_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? existingTask;

  const AddTaskScreen({super.key, this.existingTask});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _dueDate = DateTime.now();
  TaskPriority _priority = TaskPriority.medium;
  String _category = 'Personal';

  final List<String> _categories = [
    'Personal',
    'Work',
    'Shopping',
    'Health',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      _titleController.text = widget.existingTask!.title;
      _descriptionController.text = widget.existingTask!.description;
      _dueDate = widget.existingTask!.dueDate;
      _priority = widget.existingTask!.priority;
      _category = widget.existingTask!.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final taskService = Provider.of<TaskService>(context, listen: false);
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
        return;
      }
      final task = Task(
        id: widget.existingTask?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate,
        priority: _priority,
        category: _category,
        userId: userId,
      );

      if (widget.existingTask != null) {
        taskService.updateTask(task);
      } else {
        taskService.addTask(task);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTask != null ? 'Edit Task' : 'Add Task'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    '${_dueDate.year}-${_dueDate.month.toString().padLeft(2, '0')}-${_dueDate.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskPriority>(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _priority = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _category = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.existingTask != null ? 'Update Task' : 'Add Task',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
