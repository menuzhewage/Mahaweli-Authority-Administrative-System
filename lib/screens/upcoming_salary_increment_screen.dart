// lib/screens/upcoming_salary_increment_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';

class UpcomingSalaryIncrementScreen extends StatefulWidget {
  const UpcomingSalaryIncrementScreen({super.key});

  @override
  State<UpcomingSalaryIncrementScreen> createState() => _UpcomingSalaryIncrementScreenState();
}

class _UpcomingSalaryIncrementScreenState extends State<UpcomingSalaryIncrementScreen> {
  List<AppUser> _upcomingEmployees = [];
  bool _isLoading = true;
  final Map<String, bool> _updatingUsers = {};

  @override
  void initState() {
    super.initState();
    _loadUpcomingSalaryIncrements();
  }

  Future<void> _loadUpcomingSalaryIncrements() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('salary_incremental_date', isNotEqualTo: '')
          .get();

      final now = DateTime.now();
      final oneWeekFromNow = now.add(const Duration(days: 7));

      _upcomingEmployees.clear();
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final salaryDateStr = data['salary_incremental_date'] as String?;
        
        if (salaryDateStr != null && salaryDateStr.isNotEmpty) {
          try {
            // Parse the date (assuming format: dd/MM/yyyy)
            final parts = salaryDateStr.split('/');
            if (parts.length == 3) {
              final day = int.parse(parts[0]);
              final month = int.parse(parts[1]);
              final year = int.parse(parts[2]);
              final salaryDate = DateTime(year, month, day);

              // Check if salary date is within next 7 days
              if (_isDateWithinNextWeek(salaryDate, now, oneWeekFromNow)) {
                _upcomingEmployees.add(AppUser.fromMap(data, doc.id));
              }
            }
          } catch (e) {
            print('Error parsing date for user ${doc.id}: $e');
          }
        }
      }

      // Sort by upcoming date
      _upcomingEmployees.sort((a, b) {
        final dateA = _parseDate(a.salaryIncrementalDate ?? '');
        final dateB = _parseDate(b.salaryIncrementalDate ?? '');
        return dateA.compareTo(dateB);
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading upcoming increments: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _isDateWithinNextWeek(DateTime date, DateTime now, DateTime oneWeekFromNow) {
    return date.isAfter(now.subtract(const Duration(days: 1))) && 
           date.isBefore(oneWeekFromNow.add(const Duration(days: 1)));
  }

  DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    return DateTime.now();
  }

  String _getDaysRemaining(String salaryDateStr) {
    try {
      final salaryDate = _parseDate(salaryDateStr);
      final now = DateTime.now();
      final difference = salaryDate.difference(now).inDays;
      
      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Tomorrow';
      } else if (difference > 1) {
        return 'In $difference days';
      } else if (difference == -1) {
        return 'Yesterday';
      } else {
        return '${difference.abs()} days ago';
      }
    } catch (e) {
      return 'Date error';
    }
  }

  Color _getDaysRemainingColor(String salaryDateStr) {
    try {
      final salaryDate = _parseDate(salaryDateStr);
      final now = DateTime.now();
      final difference = salaryDate.difference(now).inDays;
      
      if (difference == 0) {
        return Colors.red; // Today - urgent
      } else if (difference == 1) {
        return Colors.orange; // Tomorrow - high priority
      } else if (difference > 1 && difference <= 3) {
        return Colors.amber; // Within 3 days - medium priority
      } else {
        return Colors.green; // More than 3 days - low priority
      }
    } catch (e) {
      return Colors.grey;
    }
  }

  Future<void> _updateSalaryIncrementalDate(AppUser user) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() => _updatingUsers[user.id] = true);
      
      try {
        final formattedDate = '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
        
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.id)
            .update({
          'salary_incremental_date': formattedDate,
          'last_updated': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Salary date updated for ${user.name}'),
            backgroundColor: Colors.green,
          ),
        );

        // Reload the list
        _loadUpcomingSalaryIncrements();

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating date: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _updatingUsers.remove(user.id));
      }
    }
  }

  Widget _buildEmployeeCard(AppUser employee) {
    final daysRemaining = _getDaysRemaining(employee.salaryIncrementalDate!);
    final daysColor = _getDaysRemainingColor(employee.salaryIncrementalDate!);
    final isToday = daysRemaining == 'Today';

    return Card(
      elevation: isToday ? 4 : 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      color: isToday ? Colors.red.shade50 : Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isToday ? Colors.red.shade100 : Colors.blue.shade100,
          child: Icon(
            isToday ? Icons.warning : Icons.person,
            color: isToday ? Colors.red : Colors.blue,
          ),
        ),
        title: Text(
          employee.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isToday ? Colors.red.shade800 : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${employee.role} • ${employee.department}',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Salary Date: ${employee.salaryIncrementalDate}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: daysColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: daysColor.withOpacity(0.3)),
              ),
              child: Text(
                daysRemaining,
                style: TextStyle(
                  color: daysColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _updatingUsers[employee.id] == true
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: Icon(
                      Icons.calendar_today,
                      color: Colors.blue.shade700,
                    ),
                    onPressed: () => _updateSalaryIncrementalDate(employee),
                    tooltip: 'Update Salary Date',
                  ),
          ],
        ),
        onTap: () {
          _showEmployeeDetails(employee);
        },
      ),
    );
  }

  void _showEmployeeDetails(AppUser employee) {
    final daysRemaining = _getDaysRemaining(employee.salaryIncrementalDate!);
    final daysColor = _getDaysRemainingColor(employee.salaryIncrementalDate!);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Employee Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Name', employee.name),
              _buildDetailRow('Email', employee.email),
              _buildDetailRow('Phone', employee.phone),
              _buildDetailRow('Role', employee.role),
              _buildDetailRow('Department', employee.department),
              _buildDetailRow('Salary Increment Date', employee.salaryIncrementalDate!),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: daysColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: daysColor),
                ),
                child: Center(
                  child: Text(
                    'Salary Increment: $daysRemaining',
                    style: TextStyle(
                      color: daysColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.pop(context);
              _updateSalaryIncrementalDate(employee);
            },
            tooltip: 'Update Salary Date',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.celebration,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Upcoming Salary Increments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Employees with salary incremental dates\nwithin the next 7 days will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: Icon(Icons.refresh),
            label: Text('Refresh'),
            onPressed: _loadUpcomingSalaryIncrements,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Salary Increments', style: TextStyle(
          color: Colors.black,
        ),),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUpcomingSalaryIncrements,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.blue.shade100),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This Week\'s Salary Increments',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Showing employees with salary incremental dates within the next 7 days',
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Results Count
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_upcomingEmployees.length} employees found',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),

          // Employees List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _upcomingEmployees.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadUpcomingSalaryIncrements,
                        child: ListView.builder(
                          itemCount: _upcomingEmployees.length,
                          itemBuilder: (context, index) {
                            return _buildEmployeeCard(_upcomingEmployees[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}