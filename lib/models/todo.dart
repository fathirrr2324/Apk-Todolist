class Todo {
  final int? id;
  final String title;
  final int isDone;
  final int priority;
  final String? dueDate; 

  Todo({
    this.id,
    required this.title,
    this.isDone = 0,
    this.priority = 0,
    this.dueDate,
  });

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      isDone: map['isDone'],
      priority: map['priority'] ?? 0,
      dueDate: map['dueDate'], 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
      'priority': priority,
      'dueDate': dueDate, 
    };
  }
}