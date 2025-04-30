import 'package:flutter/material.dart';
import 'package:todolist/db/database_helper.dart';
import 'package:todolist/models/todo.dart';
import 'package:todolist/widget/add_task_bar.dart';
import 'package:todolist/widget/task_list.dart';
import 'package:todolist/widget/search_bar.dart'as custom;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
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
  if (_addController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(       
        content: Text('Input cannot be empety'),
        backgroundColor: Colors.redAccent,
      ),
    );
    return;
  }

    await DatabaseHelper.instance.insertTodo(
      Todo(
        title: _addController.text.trim(),
      ),
    );
    _addController.clear();
    _loadTodos();
  }

  

  Future<void> _deleteTodo(int id) async {

    
    _loadTodos(); 
    showDialog(context: context,
    builder: (context){
      return AlertDialog(
        title: Text('You want to delete this?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                  Navigator.of(context).pop();
                 await DatabaseHelper.instance.deleteTodo(id);
                  _loadTodos();
                 
              },  child: Text('ya'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal'),
            ),
          ],
        );
    });
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
                value: 'Semua',
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
            custom.SearchBar(
            controller: _searchController,
            onSearch: _searchTodos,
          ),
          AddTaskBar(
            controller: _addController,
            onAdd: _addTodo,
          ),
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