import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pocket_ai/src/modules/todos_manager/models/todo.dart';
import 'package:pocket_ai/src/modules/todos_manager/widgets/todos_list.dart';
import 'package:pocket_ai/src/widgets/custom_text.dart';

class TodosContainer extends StatefulWidget {
  final String openAiResponse;
  final List<Todo> todos;
  final void Function(Todo) onDeletePressed;
  final bool lastItemInList;

  const TodosContainer(
      {super.key,
      required this.openAiResponse,
      required this.todos,
      required this.onDeletePressed,
      required this.lastItemInList});

  @override
  State<StatefulWidget> createState() => _TodosContainer();
}

class _TodosContainer extends State<TodosContainer> {
  String? acknowledgementToUser;
  //List<Todo>? todos;

  @override
  void initState() {
    super.initState();
    acknowledgementToUser =
        json.decode(widget.openAiResponse)['acknowledgement_to_user'];
    setState(() {
      acknowledgementToUser = acknowledgementToUser;
      //todos = widget.todos;
    });
  }

  /*@override
  void didUpdateWidget(TodosContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // we don't want to keep todos in previous list items updated
    if (widget.todos != oldWidget.todos && widget.lastItemInList) {
      todos = widget.todos;
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return (Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TodosList(
        todos: widget.todos, //todos ?? [],
        onDeletePressed: widget.lastItemInList ? widget.onDeletePressed : null,
      ),
      CustomText(acknowledgementToUser ?? '')
    ]));
  }
}
