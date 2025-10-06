// lib/screens/user_management_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../utils/pdf_export_utils.dart';
import '../models/user_model.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final List<AppUser> _allUsers = [];
  List<AppUser> _filteredUsers = [];
  String _searchQuery = '';
  String _selectedRole = 'All';
  String _selectedStatus = 'All';
  String _selectedDepartment = 'All';
  bool _isLoading = false;
  final Map<String, bool> _downloadingUsers = {};

  final List<String> _roles = [
    'All',
    'Administrator',
    'RPM',
    'Personal File Handler',
    'Leave Handler',
    'Complain Handler',
    'Employee'
  ];
  final List<String> _statuses = ['All', 'Active', 'Inactive', 'pending'];
  final List<String> _departments = [
    'All',
    'Administration',
    'IT',
    'HR',
    'Land',
    'Operations',
    'Marketing',
    'Sales'
  ];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _exportUserToPDF(AppUser user) async {
    setState(() => _downloadingUsers[user.id] = true);
    try {
      final pdf = await PDFExportUtils.generateUserDetailPDF(user);

      await Printing.layoutPdf(
        onLayout: (format) => pdf.save(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${user.name}\'s details exported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting PDF: $e')),
      );
    } finally {
      setState(() => _downloadingUsers.remove(user.id));
    }
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      _allUsers.clear();
      for (var doc in snapshot.docs) {
        _allUsers.add(AppUser.fromMap(doc.data(), doc.id));
      }

      _applyFilters();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final matchesSearch =
            user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                user.email.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesRole =
            _selectedRole == 'All' || user.role == _selectedRole;
        final matchesStatus = _selectedStatus == 'All' ||
            (_selectedStatus == 'Active' && user.isActive) ||
            (_selectedStatus == 'Inactive' && !user.isActive);
        final matchesDepartment = _selectedDepartment == 'All' ||
            user.department == _selectedDepartment;

        return matchesSearch &&
            matchesRole &&
            matchesStatus &&
            matchesDepartment;
      }).toList();
    });
  }

  Future<void> _exportToPDF() async {
    setState(() => _isLoading = true);
    try {
      String filterDescription = _getFilterDescription();

      final pdf = await PDFExportUtils.generateUsersPDF(
        _filteredUsers,
        filter: filterDescription,
      );

      await Printing.layoutPdf(
        onLayout: (format) => pdf.save(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF exported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting PDF: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getFilterDescription() {
    List<String> filters = [];
    if (_selectedRole != 'All') filters.add('Role: $_selectedRole');
    if (_selectedStatus != 'All') filters.add('Status: $_selectedStatus');
    if (_selectedDepartment != 'All')
      filters.add('Department: $_selectedDepartment');
    if (_searchQuery.isNotEmpty) filters.add('Search: "$_searchQuery"');

    return filters.isEmpty ? 'All Users' : filters.join(', ');
  }

  // Add this method to update salary incremental date
  Future<void> _updateSalaryIncrementalDate(AppUser user) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      final formattedDate = '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
      
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.id)
            .update({
          'salary_incremental_date': formattedDate,
          'last_updated': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Salary incremental date updated for ${user.name}'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Reload users to reflect the change
        _loadUsers();

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating date: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFilterDropdown(
          value: _selectedRole,
          items: _roles,
          onChanged: (value) {
            setState(() => _selectedRole = value!);
            _applyFilters();
          },
          label: 'Role',
        ),
        _buildFilterDropdown(
          value: _selectedStatus,
          items: _statuses,
          onChanged: (value) {
            setState(() => _selectedStatus = value!);
            _applyFilters();
          },
          label: 'Status',
        ),
        _buildFilterDropdown(
          value: _selectedDepartment,
          items: _departments,
          onChanged: (value) {
            setState(() => _selectedDepartment = value!);
            _applyFilters();
          },
          label: 'Department',
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String label,
  }) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildUserCard(AppUser user) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              user.isActive ? Colors.green.shade100 : Colors.red.shade100,
          child: Icon(
            Icons.person,
            color: user.isActive ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          user.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: user.isActive ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            Text('${user.role} • ${user.department}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(
                user.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              backgroundColor: user.isActive ? Colors.green : Colors.red,
            ),
            SizedBox(width: 8),
            _downloadingUsers[user.id] == true
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: Icon(Icons.download, size: 20),
                    onPressed: () => _exportUserToPDF(user),
                    tooltip: 'Download details as PDF',
                  ),
            IconButton(
              icon: Icon(Icons.calendar_today, size: 20),
              onPressed: () => _updateSalaryIncrementalDate(user),
              tooltip: 'Update Salary Incremental Date',
            ),
          ],
        ),
        onTap: () {
          _showUserDetails(user);
        },
      ),
    );
  }

  void _showUserDetails(AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Name', user.name),
              _buildDetailRow('Email', user.email),
              _buildDetailRow('Phone', user.phone),
              _buildDetailRow('Role', user.role),
              _buildDetailRow('Department', user.department),
              _buildDetailRow('Location', user.location),
              _buildDetailRow('Status', user.isActive ? 'Active' : 'Inactive'),
              _buildDetailRow(
                'Salary Incremental Date', 
                user.salaryIncrementalDate?.isNotEmpty == true 
                  ? user.salaryIncrementalDate! 
                  : 'Not set'
              ),
              _buildDetailRow('Created',
                  DateFormat('yyyy-MM-dd HH:mm').format(user.createdAt)),
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
              _updateSalaryIncrementalDate(user);
            },
            tooltip: 'Update Salary Date',
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () {
              Navigator.pop(context);
              _exportUserToPDF(user);
            },
            tooltip: 'Download as PDF',
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
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportToPDF,
            tooltip: 'Export to PDF',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _applyFilters();
              },
            ),
          ),

          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildFilterChips(),
          ),

          // Results Count
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredUsers.length} users found',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
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

          // Users List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? const Center(
                        child: Text(
                          'No users found',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: ListView.builder(
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            return _buildUserCard(_filteredUsers[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}