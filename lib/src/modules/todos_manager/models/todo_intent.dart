import 'package:pocket_ai/src/modules/todos_manager/models/todo.dart';

const List<Todo> defaultTodosPayload = [];
const List<TodoTask> defaultTasksPayload = [];

class TodoIntent {
  final String? type;
  final List<Todo> todosPayload;
  final List<TodoTask> tasksPayload;

  TodoIntent(
      {this.type,
      this.todosPayload = defaultTodosPayload,
      this.tasksPayload = defaultTasksPayload});

  factory TodoIntent.fromJson(Map<String, dynamic> jsonData) {
    List<Todo> todosPayload = [];
    List<dynamic> todosPayloadArr = jsonData['todos_payload'] ?? [];
    for (var element in todosPayloadArr) {
      todosPayload.add(Todo.fromJson(element));
    }

    List<TodoTask> tasksPayload = [];
    List<dynamic> tasksPayloadArr = jsonData['tasks_payload'] ?? [];
    for (var element in tasksPayloadArr) {
      tasksPayload.add(TodoTask.fromJson(element));
    }

    return TodoIntent(
        type: jsonData['type'] as String?,
        todosPayload: todosPayload,
        tasksPayload: tasksPayload);
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'todos_payload': todosPayload.toString(),
        'tasks_payload': tasksPayload.toString()
      };

  @override
  String toString() {
    return toJson().toString();
  }
}
