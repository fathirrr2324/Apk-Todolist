import 'package:flutter/material.dart';

class AddTaskBar extends StatelessWidget {
  final TextEditingController controller;
  final Function() onAdd;

  AddTaskBar({required this.controller, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Add Task',
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: onAdd,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
        ),
      ),
    );
  }
}