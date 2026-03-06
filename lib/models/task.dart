class Task {
  final int? id;
  final String title;
  final int subjectId;
  final bool completed;

  Task({
    this.id,
    required this.title,
    required this.subjectId,
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject_id': subjectId,
      'completed': completed ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      subjectId: map['subject_id'] as int,
      completed: (map['completed'] as int) == 1,
    );
  }

  Task copyWith({int? id, String? title, int? subjectId, bool? completed}) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      subjectId: subjectId ?? this.subjectId,
      completed: completed ?? this.completed,
    );
  }

  @override
  String toString() =>
      'Task(id: $id, title: $title, subjectId: $subjectId, completed: $completed)';
}
