import 'package:hive/hive.dart';

part 'report_model.g.dart';

@HiveType(typeId: 0)
class Report {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final String title;
  
  @HiveField(3)
  final String description;
  
  @HiveField(4)
  final String status;
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  final DateTime? updatedAt;
  
  @HiveField(7)
  final String? filePath;

  Report({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.filePath,
  });
}