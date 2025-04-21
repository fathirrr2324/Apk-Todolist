import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl untuk format tanggal

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

        // Tentukan warna berdasarkan prioritas
        Color priorityColor;
        if (todo.priority == 1) {
          priorityColor = Colors.red; // High Priority
        } else if (todo.priority == 2) {
          priorityColor = Colors.yellow; // Medium Priority
        } else {
          priorityColor = Colors.green; // Low Priority
        }

        // Format tanggal
        String formattedDate = '';
        if (todo.dueDate != null) {
          try {
            final date = DateTime.parse(todo.dueDate!);
            formattedDate = DateFormat('dd-MM-yyyy').format(date); // Format tanggal
          } catch (e) {
            formattedDate = 'Invalid date'; // Jika parsing gagal
          }
        }

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
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Priority: ${todo.priority == 1 ? "High" : todo.priority == 2 ? "Medium" : "Low"}',
                    style: TextStyle(
                      color: priorityColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (todo.dueDate != null)
                    Text(
                      'Due Date: $formattedDate', // Tampilkan tanggal yang diformat
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
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
                    icon: Icon(Icons.edit, color: Colors.blue), 
                    onPressed: () => onEdit(todo.id!, todo.title),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
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

