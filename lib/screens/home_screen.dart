import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_service.dart';
import '../services/auth_service.dart';
import '../models/task.dart';
import 'add_task_screen.dart';
import 'statistics_screen.dart';
import 'user_menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _authService = AuthService();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ToDoFlex',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserMenuScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/welcome');
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Tasks',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Manage your tasks efficiently',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: Consumer<TaskService>(
                    builder: (context, taskService, child) {
                      final tasks = taskService.tasks.where((task) {
                        return task.title
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase());
                      }).toList();

                      if (tasks.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.task_alt,
                                size: 64,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'No tasks yet. Add one!'
                                    : 'No tasks found matching "$_searchQuery"',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            color: Colors.white.withOpacity(0.9),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 1),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: task.isCompleted,
                                        onChanged: (bool? value) {
                                          if (value != null) {
                                            taskService
                                                .toggleTaskCompletion(task.id);
                                          }
                                        },
                                        activeColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          task.title,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color(0xFF1A237E), // Deep blue
                                            fontFamily: 'Roboto',
                                          ),
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert,
                                            color: Colors.black54),
                                        onSelected: (value) async {
                                          switch (value) {
                                            case 'edit':
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddTaskScreen(
                                                          existingTask: task),
                                                ),
                                              );
                                              break;
                                            case 'delete':
                                              await taskService
                                                  .deleteTask(task.id);
                                              break;
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Text('Edit'),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Description: ${task.description}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF37474F), // Blue-grey
                                      fontFamily: 'OpenSans',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Category: ${task.category}",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF00897B), // Teal
                                      fontFamily: 'OpenSans',
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Due Date: ${task.dueDate.toString().split(' ')[0]}",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF6D4C41), // Brown
                                      fontFamily: 'OpenSans',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Priority: ${task.priority.toString().split('.').last}",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: task.priority == TaskPriority.high
                                          ? Colors.red
                                          : (task.priority ==
                                                  TaskPriority.medium
                                              ? Colors.orange
                                              : Colors.green),
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'OpenSans',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Completed: ${task.isCompleted ? 'Yes' : 'No'}",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: task.isCompleted
                                          ? Colors.green
                                          : Colors.red,
                                      fontFamily: 'OpenSans',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTaskScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
