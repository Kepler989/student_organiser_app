class Subject {
  final int? id;
  final String name;

  Subject({this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'] as int?,
      name: map['name'] as String,
    );
  }

  Subject copyWith({int? id, String? name}) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  String toString() => 'Subject(id: $id, name: $name)';
}
