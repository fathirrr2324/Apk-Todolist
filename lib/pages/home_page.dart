import 'package:flutter/material.dart';
import 'package:todolist/widget/task_list.dart';
import 'package:todolist/widget/search_bar.dart' as custom;
import '../db/database_helper.dart';
import '../models/todo.dart';
import '../widget/add_task_bar.dart';

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
  final _searchController = TextEditingController();
  List<Todo> _todoList = [];
  List<Todo> _filteredTodoList = [];

  @override
  void initState() {
    super.initState();
    _loadTodos();
    _filteredTodoList = _todoList;
  }

  Future<void> _loadTodos() async {
    final todos = await DatabaseHelper.instance.getTodos();
    setState(() {
      _todoList = todos;
      _filteredTodoList = todos;
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

  void _searchTodos(String query) {
    setState(() {
      _filteredTodoList = _todoList
          .where((todo) => todo.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ToDo List",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 4,
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'All') {
                setState(() {
                  _filteredTodoList = _todoList;
                });
              } else if (value == 'Completed') {
                setState(() {
                  _filteredTodoList =
                      _todoList.where((todo) => todo.isDone == 1).toList();
                });
              } else if (value == 'Pending') {
                setState(() {
                  _filteredTodoList =
                      _todoList.where((todo) => todo.isDone == 0).toList();
                });
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'All',
                child: Text('All Tasks'),
              ),
              PopupMenuItem(
                value: 'Completed',
                child: Text('Completed Tasks'),
              ),
              PopupMenuItem(
                value: 'Pending',
                child: Text('Pending Tasks'),
              ),
            ],
            icon: Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          // SearchBar widget
            custom.SearchBar(
            controller: _searchController,
            onSearch: _searchTodos,
          ),
          // AddTaskBar widget
          AddTaskBar(
            controller: _addController,
            onAdd: _addTodo,
          ),
          // TaskList widget
          Expanded(
            child: TaskList(
              todoList: _filteredTodoList,
              onToggleStatus: (id, isDone) async {
                await DatabaseHelper.instance.updateTodoStatus(id, isDone == 1 ? 0 : 1);
                _loadTodos();
              },
              onDelete: (id) async {
                await _deleteTodo(id);
              },
              onEdit: (id, title) {
                _editTodo(id, title);
              },
            ),
          ),
        ],
      ),
    );
  }
}