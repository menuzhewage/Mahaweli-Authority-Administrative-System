// models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String department;
  final String location;
  final bool isActive;
  final DateTime createdAt;
  final String? salaryIncrementalDate; // Add this field

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.department,
    required this.location,
    required this.isActive,
    required this.createdAt,
    this.salaryIncrementalDate, // Add this
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String id) {
    return AppUser(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? '',
      department: data['department'] ?? '',
      location: data['location'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      salaryIncrementalDate: data['salary_incremental_date'], // Add this
    );
  }
}