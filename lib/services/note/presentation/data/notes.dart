import 'package:hive/hive.dart';

part 'notes.g.dart';

@HiveType(typeId: 3)
class Note extends HiveObject{
  @HiveField(0)
  String title;

  @HiveField(1)
  String content;

  @HiveField(2)
  DateTime createdAt;

  Note({
    required this.title,
    required this.content,
    required this.createdAt,
  });
}
