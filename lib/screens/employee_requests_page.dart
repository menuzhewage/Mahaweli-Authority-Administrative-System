import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class EmployeeRequestsPage extends StatefulWidget {
  const EmployeeRequestsPage({super.key});

  @override
  State<EmployeeRequestsPage> createState() => _EmployeeRequestsPageState();
}

class _EmployeeRequestsPageState extends State<EmployeeRequestsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<LeaveRequest> _leaveRequests = [];
  List<DispatchRequest> _dispatchRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    // Simulate API calls
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _leaveRequests = [
        LeaveRequest(
          id: 'LV001',
          employeeName: 'K. D. Perera',
          employeeId: 'EMP001',
          leaveType: 'Annual',
          startDate: DateTime.now().add(const Duration(days: 2)),
          endDate: DateTime.now().add(const Duration(days: 5)),
          reason: 'Family function',
          status: 'Pending',
          submittedDate: DateTime.now(),
        ),
        LeaveRequest(
          id: 'LV002',
          employeeName: 'N. S. Fernando',
          employeeId: 'EMP002',
          leaveType: 'Medical',
          startDate: DateTime.now().subtract(const Duration(days: 1)),
          endDate: DateTime.now().add(const Duration(days: 3)),
          reason: 'Hospitalization',
          status: 'Approved',
          submittedDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];

      _dispatchRequests = [
        DispatchRequest(
          id: 'DS001',
          employeeName: 'R. M. Bandara',
          employeeId: 'EMP003',
          purpose: 'Field inspection at Polgolla',
          destination: 'Polgolla Dam Site',
          vehicleRequired: true,
          departureDate: DateTime.now().add(const Duration(days: 1)),
          returnDate: DateTime.now().add(const Duration(days: 1)),
          status: 'Pending',
          submittedDate: DateTime.now(),
        ),
      ];

      _isLoading = false;
    });
  }

  void _approveRequest(String id, String type) {
    setState(() {
      if (type == 'leave') {
        _leaveRequests = _leaveRequests.map((request) {
          if (request.id == id) {
            return request.copyWith(status: 'Approved');
          }
          return request;
        }).toList();
      } else {
        _dispatchRequests = _dispatchRequests.map((request) {
          if (request.id == id) {
            return request.copyWith(status: 'Approved');
          }
          return request;
        }).toList();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type request approved'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _rejectRequest(String id, String type) {
    setState(() {
      if (type == 'leave') {
        _leaveRequests = _leaveRequests.map((request) {
          if (request.id == id) {
            return request.copyWith(status: 'Rejected');
          }
          return request;
        }).toList();
      } else {
        _dispatchRequests = _dispatchRequests.map((request) {
          if (request.id == id) {
            return request.copyWith(status: 'Rejected');
          }
          return request;
        }).toList();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type request rejected'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Requests'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Leave Requests', icon: Icon(Iconsax.calendar_remove)),
            Tab(text: 'Dispatch Requests', icon: Icon(Iconsax.car)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLeaveRequestsTab(theme),
                _buildDispatchRequestsTab(theme),
              ],
            ),
    );
  }

  Widget _buildLeaveRequestsTab(ThemeData theme) {
    return _leaveRequests.isEmpty
        ? _buildEmptyState('No leave requests pending')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _leaveRequests.length,
            itemBuilder: (context, index) {
              final request = _leaveRequests[index];
              return _buildLeaveRequestCard(theme, request);
            },
          );
  }

  Widget _buildDispatchRequestsTab(ThemeData theme) {
    return _dispatchRequests.isEmpty
        ? _buildEmptyState('No dispatch requests pending')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _dispatchRequests.length,
            itemBuilder: (context, index) {
              final request = _dispatchRequests[index];
              return _buildDispatchRequestCard(theme, request);
            },
          );
  }

  Widget _buildLeaveRequestCard(ThemeData theme, LeaveRequest request) {
    final statusColor = _getStatusColor(request.status);

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  request.employeeName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    request.status,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${request.leaveType} Leave',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Iconsax.calendar_1,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('MMM dd').format(request.startDate)} - ${DateFormat('MMM dd, yyyy').format(request.endDate)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Reason: ${request.reason}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            if (request.status == 'Pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rejectRequest(request.id, 'leave'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _approveRequest(request.id, 'leave'),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDispatchRequestCard(ThemeData theme, DispatchRequest request) {
    final statusColor = _getStatusColor(request.status);

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  request.employeeName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    request.status,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Purpose: ${request.purpose}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Iconsax.location,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  request.destination,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Iconsax.car,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  request.vehicleRequired ? 'Vehicle Required' : 'No Vehicle Needed',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Iconsax.calendar_1,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM dd, yyyy').format(request.departureDate),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (request.status == 'Pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rejectRequest(request.id, 'dispatch'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _approveRequest(request.id, 'dispatch'),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.note_remove, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class LeaveRequest {
  final String id;
  final String employeeName;
  final String employeeId;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status;
  final DateTime submittedDate;

  LeaveRequest({
    required this.id,
    required this.employeeName,
    required this.employeeId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.submittedDate,
  });

  LeaveRequest copyWith({
    String? status,
  }) {
    return LeaveRequest(
      id: id,
      employeeName: employeeName,
      employeeId: employeeId,
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      status: status ?? this.status,
      submittedDate: submittedDate,
    );
  }
}

class DispatchRequest {
  final String id;
  final String employeeName;
  final String employeeId;
  final String purpose;
  final String destination;
  final bool vehicleRequired;
  final DateTime departureDate;
  final DateTime returnDate;
  final String status;
  final DateTime submittedDate;

  DispatchRequest({
    required this.id,
    required this.employeeName,
    required this.employeeId,
    required this.purpose,
    required this.destination,
    required this.vehicleRequired,
    required this.departureDate,
    required this.returnDate,
    required this.status,
    required this.submittedDate,
  });

  DispatchRequest copyWith({
    String? status,
  }) {
    return DispatchRequest(
      id: id,
      employeeName: employeeName,
      employeeId: employeeId,
      purpose: purpose,
      destination: destination,
      vehicleRequired: vehicleRequired,
      departureDate: departureDate,
      returnDate: returnDate,
      status: status ?? this.status,
      submittedDate: submittedDate,
    );
  }
}