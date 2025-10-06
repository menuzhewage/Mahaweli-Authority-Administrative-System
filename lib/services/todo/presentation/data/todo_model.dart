import 'package:hive/hive.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 0)
class ToDoModel {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final bool isDone;

  ToDoModel({required this.title, this.isDone = false});
}
