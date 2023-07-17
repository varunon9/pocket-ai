import 'package:path/path.dart';
import 'package:pocket_ai/src/db/db_names.dart';
import 'package:pocket_ai/src/modules/todos_manager/models/todo.dart';
import 'package:sqflite/sqflite.dart';

class TodoProvider {
  Database? db;

  Future open() async {
    String path = join(await getDatabasesPath(), DbNames.databaseTodos);
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table ${DbNames.tableTodos} ( 
  ${DbNames.tableTodosColId} integer primary key autoincrement, 
  ${DbNames.tableTodosColTitle} text not null,
  ${DbNames.tableTodosColCompleted} integer not null default 0,
  ${DbNames.tableTodosColCreatedAt} text not null)
''');
      await db.execute('''
create table ${DbNames.tableTasks} ( 
  ${DbNames.tableTasksColId} integer primary key autoincrement, 
  ${DbNames.tableTasksColTitle} text not null,
  ${DbNames.tableTasksColCompleted} integer not null default 0,
  ${DbNames.tableTasksColTodoId} integer,
  FOREIGN KEY (${DbNames.tableTasksColTodoId}) REFERENCES ${DbNames.tableTodos} (${DbNames.tableTodosColId}) ON DELETE NO ACTION ON UPDATE NO ACTION)
''');
    });
  }

  Future insertTodoTask(TodoTask task, int? todoId) async {
    await db!.insert(DbNames.tableTasks, {
      DbNames.tableTasksColTitle: task.title,
      DbNames.tableTasksColTodoId: todoId ?? task.todoId,
    });
  }

  Future createMultipleTasks(List<TodoTask> tasks) async {
    for (TodoTask task in tasks) {
      await insertTodoTask(task, null);
    }
  }

  Future updateTodoTask(TodoTask task) async {
    Map<String, Object> data = {};
    if (task.title != null) {
      data[DbNames.tableTasksColTitle] = task.title!;
    }
    if (task.completed != null) {
      data[DbNames.tableTasksColCompleted] = task.completed!;
    }
    if (task.todoId != null) {
      data[DbNames.tableTasksColTodoId] = task.todoId!;
    }
    await db!.update(DbNames.tableTasks, data,
        where: '${DbNames.tableTasksColId} = ?', whereArgs: [task.id]);
  }

  Future updateMultipleTasks(List<TodoTask> tasks) async {
    for (TodoTask task in tasks) {
      await updateTodoTask(task);
    }
  }

  Future deleteTodoTask(TodoTask task) async {
    await db!.delete(DbNames.tableTasks,
        where: '${DbNames.tableTasksColId} = ?', whereArgs: [task.id]);
  }

  Future deleteMultipleTasks(List<TodoTask> tasks) async {
    for (TodoTask task in tasks) {
      await deleteTodoTask(task);
    }
  }

  // for debugging
  Future<List<TodoTask>> getAllTasks() async {
    List<TodoTask> todoTasks = [];
    if (db != null) {
      final List<Map<String, dynamic>> maps =
          await db!.query(DbNames.tableTasks);
      for (var task in maps) {
        todoTasks.add(TodoTask.fromJson(task));
      }
    }
    return todoTasks;
  }

  Future insertTodo(Todo todo) async {
    if (db != null) {
      int todoId = await db!.insert(DbNames.tableTodos, {
        DbNames.tableTodosColTitle: todo.title,
        DbNames.tableTodosColCreatedAt: DateTime.now().toIso8601String()
      });
      for (TodoTask task in todo.tasks) {
        await insertTodoTask(task, todoId);
      }
    }
  }

  Future createTodos(List<Todo> todos) async {
    for (Todo todo in todos) {
      await insertTodo(todo);
    }
  }

  Future<List<Todo>> getTodos() async {
    List<Todo> todos = [];
    if (db != null) {
      final List<Map<String, dynamic>> maps =
          await db!.query(DbNames.tableTodos);
      for (var todo in maps) {
        var todoCopy = {
          ...todo,
        };
        List<dynamic> tasks = await db!.query(DbNames.tableTasks,
            where: '${DbNames.tableTasksColTodoId} = ?',
            whereArgs: [todoCopy['id']]);
        todoCopy['tasks'] = tasks;
        todos.add(Todo.fromJson(todoCopy));
      }
    }
    return todos;
  }

  Future deleteTodo(Todo todo) async {
    if (db != null) {
      // if tasks are empty, delete todo
      // else delete all tasks
      if (todo.tasks.isNotEmpty) {
        List<int> taskIds = [];
        for (TodoTask task in todo.tasks) {
          if (task.id != null) {
            taskIds.add(task.id!);
          }
        }
        await db!.delete(DbNames.tableTasks,
            where:
                '${DbNames.tableTasksColId} in (${List.filled(taskIds.length, '?').join(',')})',
            whereArgs: taskIds);
      }
      await db!.delete(DbNames.tableTodos,
          where: '${DbNames.tableTodosColId} = ?', whereArgs: [todo.id]);
    }
  }

  Future deleteTodos(List<Todo> todos) async {
    for (Todo todo in todos) {
      await deleteTodo(todo);
    }
  }

  Future updateTodo(Todo todo) async {
    if (todo.tasks.isNotEmpty) {
      // if task exists, update it
      // else create new task attached to todo
      for (TodoTask task in todo.tasks) {
        int taskId = await db!.update(
            DbNames.tableTasks,
            {
              DbNames.tableTasksColTitle: task.title,
              DbNames.tableTasksColCompleted: task.completed
            },
            where: '${DbNames.tableTasksColId} = ?',
            whereArgs: [task.id]);
        if (taskId == 0 && todo.id != null) {
          // not updated means these tasks are new, create these
          await insertTodoTask(task, todo.id!);
        }
      }
    }
    await db!.update(
        DbNames.tableTodos,
        {
          DbNames.tableTodosColTitle: todo.title,
          DbNames.tableTodosColCompleted: todo.completed
        },
        where: '${DbNames.tableTodosColId} = ?',
        whereArgs: [todo.id]);
  }

  Future updateTodos(List<Todo> todos) async {
    for (Todo todo in todos) {
      await updateTodo(todo);
    }
  }

  Future close() async => db?.close();
}
