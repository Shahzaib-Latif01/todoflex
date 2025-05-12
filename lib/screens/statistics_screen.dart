import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_service.dart';
import '../models/task.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Statistics'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TaskService>(
        builder: (context, taskService, child) {
          final tasks = taskService.tasks;
          final completedTasks = tasks.where((task) => task.isCompleted).length;
          final totalTasks = tasks.length;
          final completionRate =
              totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0.0;

          // Count tasks by priority
          final highPriorityTasks =
              tasks.where((task) => task.priority == TaskPriority.high).length;
          final mediumPriorityTasks = tasks
              .where((task) => task.priority == TaskPriority.medium)
              .length;
          final lowPriorityTasks =
              tasks.where((task) => task.priority == TaskPriority.low).length;

          // Count tasks by category
          final Map<String, int> categoryCounts = {};
          for (var task in tasks) {
            categoryCounts[task.category] =
                (categoryCounts[task.category] ?? 0) + 1;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall Progress Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overall Progress',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'Total Tasks',
                              totalTasks.toString(),
                              Icons.list_alt,
                            ),
                            _buildStatItem(
                              'Completed',
                              completedTasks.toString(),
                              Icons.check_circle,
                            ),
                            _buildStatItem(
                              'Completion Rate',
                              '${completionRate.toStringAsFixed(1)}%',
                              Icons.percent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tasks by Priority Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tasks by Priority',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'High',
                              highPriorityTasks.toString(),
                              Icons.priority_high,
                              color: Colors.red,
                            ),
                            _buildStatItem(
                              'Medium',
                              mediumPriorityTasks.toString(),
                              Icons.remove,
                              color: Colors.orange,
                            ),
                            _buildStatItem(
                              'Low',
                              lowPriorityTasks.toString(),
                              Icons.arrow_downward,
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tasks by Category Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tasks by Category',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (categoryCounts.isEmpty)
                          const Center(
                            child: Text('No tasks in any category'),
                          )
                        else
                          Column(
                            children: categoryCounts.entries.map((entry) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      entry.value.toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon,
      {Color? color}) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: color ?? Colors.blue,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
