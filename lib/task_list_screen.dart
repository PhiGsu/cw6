import 'package:cw6/add_task_dialog.dart';
import 'package:cw6/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  late Stream<List<Task>> _taskListStream;

  @override
  void initState() {
    super.initState();
    _taskListStream = FirebaseFirestore.instance
        .collection('tasks')
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Task.fromMap(doc)).toList());
  }

  void _addTask(Task task) {
    FirebaseFirestore.instance.collection('tasks').add({
      "name": task.name,
      "completed": task.completed,
      "subtasks": task.subtasks,
      "userId": _userId,
    });
  }

  void _toggleTaskCompletion(Task task) {
    FirebaseFirestore.instance.collection('tasks').doc(task.id).update({
      "completed": !task.completed,
    });
  }

  void _deleteTask(String taskId) {
    FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddTaskDialog(
          onTaskCreated: _addTask,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Task Manager'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            tooltip: 'Log out',
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
              FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<List<Task>>(
              stream: _taskListStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final task = snapshot.data![index];
                        return TaskItem(
                          task: task,
                          onToggle: () => _toggleTaskCompletion(task),
                          onDelete: () => _deleteTask(task.id),
                        );
                      },
                    ),
                  );
                }
                return const Text('No tasks found');
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Task {
  String id;
  String name;
  bool completed;
  List<String> subtasks;

  Task({
    required this.id,
    required this.name,
    this.completed = false,
    this.subtasks = const [],
  });

  factory Task.fromMap(DocumentSnapshot? documentSnapshot) {
    final data = documentSnapshot?.data() as Map<String, dynamic>?;
    return Task(
      id: documentSnapshot?.id ?? '',
      name: data?['name'] ?? '',
      completed: data?['completed'] ?? false,
      subtasks: List<String>.from(data?['subtasks'] ?? []),
    );
  }
}

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskItem(
      {super.key,
      required this.task,
      required this.onToggle,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: task.completed,
        shape: const CircleBorder(),
        onChanged: (bool? value) => onToggle(),
      ),
      title: Text(
        task.name,
        style: TextStyle(
          decoration: task.completed ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: IconButton(
        onPressed: onDelete,
        icon: const Icon(Icons.delete, color: Colors.red),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: task.subtasks.map((subtask) {
          return Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              subtask,
              style: TextStyle(
                decoration: task.completed ? TextDecoration.lineThrough : null,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
