import 'package:cw6/task_list_screen.dart';
import 'package:flutter/material.dart';

class AddTaskDialog extends StatefulWidget {
  final Function(Task) onTaskCreated;

  const AddTaskDialog({super.key, required this.onTaskCreated});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  late final TextEditingController _taskNameController;
  late final TextEditingController _subtaskTimeController;
  late final TextEditingController _subtaskDescriptionController;
  bool _isFormValid = false;

  final List<Map<String, String>> _subtasks = [];

  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController();
    _subtaskTimeController = TextEditingController();
    _subtaskDescriptionController = TextEditingController();

    _taskNameController.addListener(() {
      setState(() {
        _isFormValid = _taskNameController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _subtaskTimeController.dispose();
    _subtaskDescriptionController.dispose();
    super.dispose();
  }

  void _addSubtask() {
    if (_subtaskTimeController.text.isNotEmpty &&
        _subtaskDescriptionController.text.isNotEmpty) {
      setState(() {
        _subtasks.add({
          'time': _subtaskTimeController.text,
          'description': _subtaskDescriptionController.text,
        });
        _subtaskTimeController.clear();
        _subtaskDescriptionController.clear();
      });
    }
  }

  void _createTask() {
    final task = Task(
      id: '',
      name: _taskNameController.text,
      completed: false,
      subtasks: _subtasks
          .map((subtask) => '${subtask['time']}: ${subtask['description']}')
          .toList(),
    );
    widget.onTaskCreated(task);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Task'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _taskNameController,
              decoration: const InputDecoration(
                labelText: 'Task Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Subtasks:'),
            ..._subtasks.map((subtask) {
              return ListTile(
                title: Text('${subtask['time']} - ${subtask['description']}'),
                trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      _subtasks.remove(subtask);
                    });
                  },
                  icon: const Icon(Icons.delete),
                ),
              );
            }),
            const Divider(),
            TextField(
              controller: _subtaskTimeController,
              decoration: const InputDecoration(
                labelText: 'Subtask Time',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _subtaskDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Subtask Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _addSubtask,
              child: const Text('Add Subtask'),
            ),
            const Divider(),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isFormValid ? _createTask : null,
          child: const Text('Create Task'),
        ),
      ],
    );
  }
}
