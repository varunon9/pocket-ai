import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pocket_ai/src/modules/todos_manager/db/todo_provider.dart';
import 'package:pocket_ai/src/modules/todos_manager/models/todo.dart';
import 'package:pocket_ai/src/modules/todos_manager/widgets/todos_list.dart';
import 'package:pocket_ai/src/utils/common.dart';
import 'package:pocket_ai/src/widgets/custom_text.dart';

class TodosContainer extends StatefulWidget {
  final String openAiResponse;
  final TodoProvider todoProvider;

  const TodosContainer(
      {super.key, required this.openAiResponse, required this.todoProvider});

  @override
  State<StatefulWidget> createState() => _TodosContainer();
}

class _TodosContainer extends State<TodosContainer> {
  String? acknowledgementToUser;
  List<Todo>? todos;

  @override
  void initState() {
    super.initState();

    try {
      acknowledgementToUser =
          json.decode(widget.openAiResponse)['acknowledgement_to_user'];
      widget.todoProvider.getTodos().then(
        (value) {
          setState(() {
            todos = value;
          });
        },
      );
    } catch (error) {
      logGenericError(error);
    }
  }

  void onTodoListItemDeletePressed(Todo todo) async {
    try {
      await widget.todoProvider.deleteTodo(todo);
      todos = await widget.todoProvider.getTodos();
      setState(() {
        todos = todos;
      });
    } catch (error) {
      showSnackBar(context, message: error.toString());
      logGenericError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return (Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      todos == null
          ? Container(
              padding: const EdgeInsets.all(16),
              child: const CircularProgressIndicator())
          : TodosList(
              todos: todos!,
              onDeletePressed: onTodoListItemDeletePressed,
            ),
      CustomText(acknowledgementToUser ?? '')
    ]));
  }
}
