import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmployeeRequestsPage extends StatefulWidget {
  const EmployeeRequestsPage({super.key});

  @override
  State<EmployeeRequestsPage> createState() => _EmployeeRequestsPageState();
}

class _EmployeeRequestsPageState extends State<EmployeeRequestsPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Lists to hold data
  List<Map<String, dynamic>> _registrationRequests = [];
  List<Map<String, dynamic>> _dispatchRequests = [];

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
    try {
      // Load registration requests (users with pending status)
      final registrationQuery = await _firestore
          .collection('users')
          .where('status', isEqualTo: 'pending')
          .get();
      
      _registrationRequests = registrationQuery.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
      
      // Load dispatch requests
      final dispatchQuery = await _firestore
          .collection('dispatchRequests')
          .where('status', isEqualTo: 'Pending')
          .get();
      
      _dispatchRequests = dispatchQuery.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading requests: $e');
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading requests: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _approveRegistration(String userId) async {
    try {
      // Update user status to active
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'status': 'Active'});
      
      // Remove from local list
      setState(() {
        _registrationRequests.removeWhere((user) => user['id'] == userId);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('User account activated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error approving registration: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectRegistration(String userId) async {
    try {
      // Delete user from Firebase
      await _firestore.collection('users').doc(userId).delete();
      
      // If user has auth account, delete it too (optional)
      try {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        final email = userDoc['email'];
        final user = await _auth.fetchSignInMethodsForEmail(email);
        if (user.isNotEmpty) {
          // Note: This requires admin privileges or custom cloud function
          print('User auth account exists but cannot delete without admin privileges');
        }
      } catch (e) {
        print('Error checking auth account: $e');
      }
      
      // Remove from local list
      setState(() {
        _registrationRequests.removeWhere((user) => user['id'] == userId);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('User registration rejected and deleted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error rejecting registration: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _approveDispatchRequest(String requestId) async {
    try {
      // Update dispatch request status to Approved
      await _firestore
          .collection('dispatchRequests')
          .doc(requestId)
          .update({'status': 'Approved'});
      
      // Remove from local list
      setState(() {
        _dispatchRequests.removeWhere((request) => request['id'] == requestId);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Dispatch request approved'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error approving dispatch request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectDispatchRequest(String requestId) async {
    try {
      // Update dispatch request status to Rejected
      await _firestore
          .collection('dispatchRequests')
          .doc(requestId)
          .update({'status': 'Rejected'});
      
      // Remove from local list
      setState(() {
        _dispatchRequests.removeWhere((request) => request['id'] == requestId);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Dispatch request rejected'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error rejecting dispatch request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            Tab(text: 'New Registration Requests', icon: Icon(Iconsax.profile_2user)),
            Tab(text: 'Dispatch Requests', icon: Icon(Iconsax.car)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRegistrationRequestsTab(theme),
                _buildDispatchRequestsTab(theme),
              ],
            ),
    );
  }

  Widget _buildRegistrationRequestsTab(ThemeData theme) {
    return _registrationRequests.isEmpty
        ? _buildEmptyState('No registration requests pending')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _registrationRequests.length,
            itemBuilder: (context, index) {
              final user = _registrationRequests[index];
              return _buildRegistrationRequestCard(theme, user);
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

  Widget _buildRegistrationRequestCard(ThemeData theme, Map<String, dynamic> user) {
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
                  user['name'] ?? 'Unknown',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Pending',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Iconsax.sms,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  user['email'] ?? 'No email',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (user['phone'] != null) ...[
              Row(
                children: [
                  Icon(
                    Iconsax.call,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user['phone'],
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (user['department'] != null) ...[
              Row(
                children: [
                  Icon(
                    Iconsax.building,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user['department'],
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (user['position'] != null) ...[
              Row(
                children: [
                  Icon(
                    Iconsax.briefcase,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user['position'],
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rejectRegistration(user['id']),
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
                    onPressed: () => _approveRegistration(user['id']),
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

  Widget _buildDispatchRequestCard(ThemeData theme, Map<String, dynamic> request) {
    final statusColor = _getStatusColor(request['status']);

    // Parse dates
    DateTime departureDate;
    if (request['departureDate'] is Timestamp) {
      departureDate = (request['departureDate'] as Timestamp).toDate();
    } else if (request['departureDate'] is String) {
      departureDate = DateTime.parse(request['departureDate']);
    } else {
      departureDate = DateTime.now();
    }

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
                  request['employeeName'] ?? 'Unknown',
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
                    request['status'] ?? 'Pending',
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
              'Purpose: ${request['purpose'] ?? 'Not specified'}',
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
                  request['destination'] ?? 'Unknown destination',
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
                  request['vehicleRequired'] == true ? 'Vehicle Required' : 'No Vehicle Needed',
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
                  DateFormat('MMM dd, yyyy').format(departureDate),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (request['status'] == 'Pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rejectDispatchRequest(request['id']),
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
                      onPressed: () => _approveDispatchRequest(request['id']),
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