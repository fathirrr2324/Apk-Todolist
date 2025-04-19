import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../db/database_helper.dart';

class TaskList extends StatelessWidget {
  final List<Todo> todoList;
  final Function(int id, int isDone) onToggleStatus;
  final Function(int id) onDelete;
  final Function(int id, String title) onEdit;

  TaskList({
    required this.todoList,
    required this.onToggleStatus,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: todoList.length,
      itemBuilder: (context, index) {
        final todo = todoList[index];
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                todo.title,
                style: TextStyle(
                  decoration: todo.isDone == 1
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              leading: Checkbox(
                value: todo.isDone == 1,
                onChanged: (value) {
                  onToggleStatus(todo.id!, todo.isDone);
                },
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: () => onEdit(todo.id!, todo.title),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => onDelete(todo.id!),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

