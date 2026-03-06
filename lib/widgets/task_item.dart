import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onDelete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: task.completed
            ? Colors.green.shade50
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: task.completed
              ? Colors.green.shade200
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Checkbox(
          value: task.completed,
          onChanged: onToggle,
          activeColor: Colors.green.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            decoration: task.completed ? TextDecoration.lineThrough : null,
            color: task.completed ? Colors.grey.shade500 : Colors.grey.shade800,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 20),
          onPressed: onDelete,
          tooltip: 'Delete task',
        ),
      ),
    );
  }
}
