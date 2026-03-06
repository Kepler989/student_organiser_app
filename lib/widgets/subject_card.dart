import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../models/task.dart';
import '../database/database_helper.dart';
import 'task_item.dart';

class SubjectCard extends StatefulWidget {
  final Subject subject;
  final VoidCallback onSubjectDeleted;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.onSubjectDeleted,
  });

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Task> _tasks = [];
  bool _isLoading = true;

  // Distinct color palette for subjects (cycles if more than 8)
  static const List<Color> _subjectColors = [
    Color(0xFF5C6BC0), // indigo
    Color(0xFF26A69A), // teal
    Color(0xFFEF5350), // red
    Color(0xFFFFA726), // orange
    Color(0xFF66BB6A), // green
    Color(0xFFAB47BC), // purple
    Color(0xFF29B6F6), // light blue
    Color(0xFFEC407A), // pink
  ];

  Color get _cardColor =>
      _subjectColors[(widget.subject.id ?? 0) % _subjectColors.length];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    if (widget.subject.id == null) return;
    final tasks =
        await _dbHelper.getTasksForSubject(widget.subject.id!);
    if (mounted) setState(() { _tasks = tasks; _isLoading = false; });
  }

  Future<void> _addTask() async {
    final titleController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Task',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: _cardColor)),
        content: TextField(
          controller: titleController,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'Task title...',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _cardColor, width: 2),
            ),
          ),
          onSubmitted: (_) => Navigator.of(ctx).pop(true),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _cardColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (confirmed == true && titleController.text.trim().isNotEmpty) {
      final task = Task(
        title: titleController.text.trim(),
        subjectId: widget.subject.id!,
      );
      await _dbHelper.insertTask(task);
      _loadTasks();
    }
  }

  Future<void> _toggleTask(Task task, bool? value) async {
    if (value == null || task.id == null) return;
    await _dbHelper.updateTaskCompletion(task.id!, value);
    _loadTasks();
  }

  Future<void> _deleteTask(Task task) async {
    if (task.id == null) return;
    await _dbHelper.deleteTask(task.id!);
    _loadTasks();
  }

  Future<void> _deleteSubject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Subject?'),
        content: Text(
            'This will also delete all tasks under "${widget.subject.name}". This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && widget.subject.id != null) {
      await _dbHelper.deleteSubject(widget.subject.id!);
      widget.onSubjectDeleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _tasks.where((t) => t.completed).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _cardColor.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            childrenPadding: const EdgeInsets.only(bottom: 12),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _cardColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.menu_book_rounded, color: _cardColor, size: 24),
            ),
            title: Text(
              widget.subject.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey.shade800,
              ),
            ),
            subtitle: _isLoading
                ? null
                : Text(
                    _tasks.isEmpty
                        ? 'No tasks yet'
                        : '$completedCount / ${_tasks.length} completed',
                    style: TextStyle(
                        fontSize: 12,
                        color: _tasks.isEmpty
                            ? Colors.grey.shade400
                            : _cardColor),
                  ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isLoading && _tasks.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _cardColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_tasks.length}',
                      style: TextStyle(
                          color: _cardColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: Colors.red.shade300, size: 20),
                  onPressed: _deleteSubject,
                  tooltip: 'Delete subject',
                ),
              ],
            ),
            children: [
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                if (_tasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.grey.shade400, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'No tasks yet. Add one below!',
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                else
                  ..._tasks.map((task) => TaskItem(
                        task: task,
                        onToggle: (val) => _toggleTask(task, val),
                        onDelete: () => _deleteTask(task),
                      )),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton.icon(
                    onPressed: _addTask,
                    icon: Icon(Icons.add, color: _cardColor, size: 18),
                    label: Text('Add Task',
                        style: TextStyle(color: _cardColor)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _cardColor.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
