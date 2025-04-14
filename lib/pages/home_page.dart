import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/todo.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo List',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _addController = TextEditingController();
  final _editController = TextEditingController();
  List<Todo> _todoList = [];

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final todos = await DatabaseHelper.instance.getTodos();
    setState(() {
      _todoList = todos;
    });
  }

  Future<void> _addTodo() async {
    if (_addController.text.isNotEmpty) {
      await DatabaseHelper.instance.insertTodo(
        Todo(
          title: _addController.text,
        ),
      );
      _addController.clear();
      _loadTodos();
    }
  }

  Future<void> _deleteTodo(int id) async {
    await DatabaseHelper.instance.deleteTodo(id);
    _loadTodos();
  }

  Future<void> _editTodo(int id, String currentTitle) async {
    _editController.text = currentTitle;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ToDo'),
          content: TextField(
            controller: _editController,
            decoration: InputDecoration(hintText: 'Masukkan judul todo'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                if (_editController.text.isNotEmpty) {
                  await DatabaseHelper.instance.updateTodo(
                    Todo(
                      id: id,
                      title: _editController.text,
                    ),
                  );
                  _loadTodos();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Simpan'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sortTodos() async {
    final sortedTodos = await DatabaseHelper.instance.getTodos();
    sortedTodos.sort((a, b) => a.isDone.compareTo(b.isDone));
    setState(() {
      _todoList = sortedTodos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ToDo List"),
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _sortTodos,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              controller: _addController,
              decoration: InputDecoration(
                labelText: 'Add Task',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addTodo,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todoList.length,
              itemBuilder: (context, index) {
                final todo = _todoList[index];
                return ListTile(
                  title: Text(todo.title),
                  leading: Checkbox(
                    value: todo.isDone == 1,
                    onChanged: (value) async {
                      await DatabaseHelper.instance.updateTodoStatus(
                        todo.id!,
                        value! ? 1 : 0,
                      );
                      _loadTodos();
                    },
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editTodo(todo.id!, todo.title),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteTodo(todo.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
