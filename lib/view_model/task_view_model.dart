import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class TaskViewModel extends ChangeNotifier {
  final Box<Task> _taskBox = Hive.box<Task>('tasksBox');
  List<Task> get tasks => _taskBox.values.toList();

  void addTask(String title, String description) {
    _taskBox.add(Task(
      title: title,
      description: description,
      dateTime: DateTime.now(),
    ));
    notifyListeners();
  }

  void editTask(int index, String title, String description) {
    Task task = _taskBox.getAt(index)!;
    _taskBox.putAt(
      index,
      Task(
        title: title,
        description: description,
        isCompleted: task.isCompleted,
        dateTime: task.dateTime,
      ),
    );
    notifyListeners();
  }

  void deleteTask(int index) {
    _taskBox.getAt(index)?.delete();
    notifyListeners();
  }

  int countDoneTasks() {
    return _taskBox.values.where((task) => task.isCompleted).length;
  }

  void toggleTaskCompletion(int index) {
    Task task = _taskBox.getAt(index)!;
    task.isCompleted = !task.isCompleted;
    task.save();
    notifyListeners();
  }
}
