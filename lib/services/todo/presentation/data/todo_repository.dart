import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'todo_model.dart';

class ToDoRepository {
  final Box _todoBox = Hive.box('to-do-box');

  ValueListenable<Box> get listenable => _todoBox.listenable();

  List<ToDoModel> getTasks() {
    return _todoBox.values.cast<ToDoModel>().toList();
  }

  void addTask(ToDoModel task) {
    _todoBox.add(task);
  }

  void toggleTaskStatus(int index) {
    final task = _todoBox.getAt(index) as ToDoModel;
    _todoBox.putAt(index, ToDoModel(title: task.title, isDone: !task.isDone));
  }

  void removeTask(int index) {
    _todoBox.deleteAt(index);
  }
}
