class TodoTask {
  final int? id;
  final String? title;
  final int? todoId;
  final int? completed;

  TodoTask({this.id, this.title, this.todoId, this.completed});

  factory TodoTask.fromJson(Map<String, dynamic> jsonData) {
    return TodoTask(
        id: jsonData['id'] as int?,
        title: jsonData['title'] as String?,
        todoId: jsonData['todo_id'] as int?,
        completed: jsonData['completed'] as int?);
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'title': title, 'todo_id': todoId, 'completed': completed};

  @override
  String toString() {
    return toJson().toString();
  }
}

const List<TodoTask> defaultTasks = [];

class Todo {
  final int? id;
  final String? title;
  final String? createdAt;
  final int? completed;
  final List<TodoTask> tasks;

  Todo(
      {this.id,
      this.title,
      this.createdAt,
      this.completed,
      this.tasks = defaultTasks});

  factory Todo.fromJson(Map<String, dynamic> jsonData) {
    List<TodoTask> tasks = [];
    List<dynamic> tasksArr = jsonData['tasks'] ?? [];
    for (var element in tasksArr) {
      tasks.add(TodoTask.fromJson(element));
    }

    return Todo(
        id: jsonData['id'] as int?,
        title: jsonData['title'] as String?,
        createdAt: jsonData['created_at'] as String?,
        completed: jsonData['completed'] as int?,
        tasks: tasks);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'created_at': createdAt,
        'completed': completed,
        'tasks': tasks.toString()
      };

  @override
  String toString() {
    return toJson().toString();
  }
}
