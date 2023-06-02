import 'package:flutter/material.dart';
import 'package:pocket_ai/src/modules/todos_manager/models/todo.dart';
import 'package:pocket_ai/src/modules/todos_manager/widgets/todo_card_item.dart';
import 'package:pocket_ai/src/utils/common.dart';
import 'package:pocket_ai/src/widgets/custom_text.dart';

class TodosList extends StatefulWidget {
  final List<Todo> todos;
  final void Function(Todo)? onDeletePressed;

  const TodosList(
      {super.key, required this.todos, required this.onDeletePressed});

  @override
  State<StatefulWidget> createState() => _TodosList();
}

class _TodosList extends State<TodosList> {
  @override
  Widget build(BuildContext context) {
    return (widget.todos.isEmpty
        ? TodoCardItem(
            child: Column(children: [
              const CustomText(
                'No Todos found!',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: const CustomText(
                    'Ask Pocket AI to get your todos created.',
                    style: TextStyle(fontSize: 12),
                  ))
            ]),
          )
        : ListView(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.only(top: 12, bottom: 12),
            children: widget.todos.asMap().entries.map((entry) {
              int index = entry.key;
              Todo todo = entry.value;
              return TodoCardItem(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            '${index + 1}. ${todo.title}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: (todo.title != null &&
                                        todo.title!.length > 20)
                                    ? 18
                                    : 20,
                                decoration: todo.completed == 1
                                    ? TextDecoration.lineThrough
                                    : null),
                          ),
                        ),
                        widget.onDeletePressed != null
                            ? IconButton(
                                iconSize: 20,
                                onPressed: () {
                                  widget.onDeletePressed!(todo);
                                },
                                icon: const Icon(Icons.cancel_rounded))
                            : Container()
                      ],
                    ),
                    Container(
                        margin: const EdgeInsets.only(left: 12),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: todo.tasks
                                .map((task) => Container(
                                    margin: const EdgeInsets.only(
                                        top: 4, bottom: 4),
                                    child: CustomText(
                                      '- ${task.title}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          decoration: task.completed == 1
                                              ? TextDecoration.lineThrough
                                              : null),
                                    )))
                                .toList())),
                    Container(
                        margin: const EdgeInsets.only(top: 12),
                        child: CustomText(
                          'Created on: ${getFormattedDate(DateTime.parse(todo.createdAt ?? '').toLocal())}',
                          style: const TextStyle(fontSize: 12),
                        ))
                  ]));
            }).toList()));
  }
}
