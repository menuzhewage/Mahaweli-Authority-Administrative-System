import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class EmployeeManagementPage extends StatefulWidget {
  const EmployeeManagementPage({super.key});

  @override
  State<EmployeeManagementPage> createState() => _EmployeeManagementPageState();
}

class _EmployeeManagementPageState extends State<EmployeeManagementPage> {
  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _employees = [
        Employee(
          id: 'EMP001',
          name: 'K. D. Perera',
          position: 'Senior Engineer',
          department: 'Irrigation',
          office: 'Polgolla',
          contact: '0771234567',
          status: 'Active',
          avatarUrl: ''),
        Employee(
            id: 'EMP002',
            name: 'N. S. Fernando',
            position: 'Field Officer',
            department: 'Agriculture',
            office: 'Victoria',
            contact: '0712345678',
            status: 'Active',
            avatarUrl: ''),
        Employee(
            id: 'EMP003',
            name: 'R. M. Bandara',
            position: 'Accountant',
            department: 'Finance',
            office: 'Head Office',
            contact: '0762345678',
            status: 'Active',
            avatarUrl: ''),
        Employee(
            id: 'EMP004',
            name: 'S. P. Jayawardena',
            position: 'Technical Assistant',
            department: 'Maintenance',
            office: 'Randenigala',
            contact: '0753456789',
            status: 'On Leave',
            avatarUrl: ''),
        Employee(
            id: 'EMP005',
            name: 'L. K. Silva',
            position: 'Project Manager',
            department: 'Construction',
            office: 'Moragahakanda',
            contact: '0724567890',
            status: 'Active',
            avatarUrl: ''),
      ];
      _filteredEmployees = _employees;
      _isLoading = false;
    });
  }

  void _filterEmployees() {
    setState(() {
      _filteredEmployees = _employees.where((employee) {
        final matchesSearch = employee.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            employee.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            employee.position.toLowerCase().contains(_searchQuery.toLowerCase());
        
        final matchesFilter = _selectedFilter == 'All' || 
            employee.status == _selectedFilter;
        
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  void _showEmployeeDetails(Employee employee) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EmployeeDetailSheet(employee: employee),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Management'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.filter),
            onPressed: _showFilterOptions,
          ),
          IconButton(
            icon: const Icon(Iconsax.add),
            onPressed: () => _showAddEmployeeDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Iconsax.search_normal),
                hintText: 'Search employees...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _filterEmployees();
              },
            ),
          ),
          _isLoading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : _filteredEmployees.isEmpty
                  ? _buildEmptyState()
                  : Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredEmployees.length,
                        itemBuilder: (context, index) => EmployeeCard(
                          employee: _filteredEmployees[index],
                          onTap: () => _showEmployeeDetails(_filteredEmployees[index]),
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.people, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No employees found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => _showAddEmployeeDialog(),
            child: const Text('Add New Employee'),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Employees',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...['All', 'Active', 'On Leave', 'Inactive'].map((filter) => RadioListTile(
                    title: Text(filter),
                    value: filter,
                    groupValue: _selectedFilter,
                    onChanged: (value) {
                      setState(() => _selectedFilter = value!);
                      _filterEmployees();
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddEmployeeDialog() {
    // Implement add employee functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Employee'),
        content: const Text('Employee creation form would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // Save new employee
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onTap;

  const EmployeeCard({super.key, required this.employee, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(employee.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.profile_circle,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${employee.position} • ${employee.department}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employee.office,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  employee.status,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'On Leave':
        return Colors.orange;
      case 'Inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class EmployeeDetailSheet extends StatelessWidget {
  final Employee employee;

  const EmployeeDetailSheet({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(employee.status);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.profile_circle,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  employee.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Center(
                child: Text(
                  employee.id,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Position', employee.position, Iconsax.briefcase),
              _buildDetailRow('Department', employee.department, Iconsax.building),
              _buildDetailRow('Office Location', employee.office, Iconsax.location),
              _buildDetailRow('Contact Number', employee.contact, Iconsax.call),
              _buildDetailRowWithStatus('Status', employee.status, statusColor, Iconsax.activity),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Iconsax.message),
                      label: const Text('Message'),
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Iconsax.edit),
                      label: const Text('Edit'),
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithStatus(String label, String value, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'On Leave':
        return Colors.orange;
      case 'Inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class Employee {
  final String id;
  final String name;
  final String position;
  final String department;
  final String office;
  final String contact;
  final String status;
  final String avatarUrl;

  Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.department,
    required this.office,
    required this.contact,
    required this.status,
    required this.avatarUrl,
  });
}