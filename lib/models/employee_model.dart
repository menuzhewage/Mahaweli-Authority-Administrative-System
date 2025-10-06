class Employee {
  final String id;
  final String name;
  final String position;
  final String department;
  final String contact;
  final String status;
  final String avatarUrl;
  final String? salaryIncrementalDate;

  Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.department,
    required this.contact,
    required this.status,
    required this.avatarUrl,
    this.salaryIncrementalDate,
  });
  
}