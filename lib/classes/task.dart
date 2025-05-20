class Task {
  final String name;
  final String description;
  final DateTime dueDate;
  final String priority;
  final String status;
  final String imageUrl;

  Task( {
    required this.name,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.imageUrl,
  });
}
