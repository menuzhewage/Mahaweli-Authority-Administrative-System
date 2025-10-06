// screens/view_dispatch_screen.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mahaweli_admin_system/services/user_service.dart';
import 'package:provider/provider.dart';

import '../firestore_service.dart';

class ViewDispatchScreen extends StatefulWidget {
  const ViewDispatchScreen({super.key});

  @override
  State<ViewDispatchScreen> createState() => _ViewDispatchScreenState();
}

class _ViewDispatchScreenState extends State<ViewDispatchScreen> {
  String? _currentUserId = UserService.currentUserId;
  String _filterStatus = 'all';
  bool _isLoading = true;
  bool _debugMode = false;
  List<QueryDocumentSnapshot> _allDispatches = [];
  String _debugInfo = 'Loading...';

  @override
  void initState() {
    super.initState();
    _currentUserId = UserService.currentUserId;
    print('Current User ID: $_currentUserId');
    _loadDispatches();
  }

  Future<void> _loadDispatches() async {
    if (_currentUserId == null) {
      setState(() {
        _isLoading = false;
        _debugInfo = 'Error: Current user ID is null';
      });
      return;
    }

    try {
      setState(() {
        _debugInfo = 'Loading dispatches for user: $_currentUserId';
      });

      // Try to get all dispatch requests
      final snapshot = await FirebaseFirestore.instance
          .collection('dispatch_requests')
          .get();

      setState(() {
        _debugInfo = 'Total documents found: ${snapshot.docs.length}\n';
      });

      // Debug: print all documents to see their structure
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final debugLine = 'Doc ${doc.id}: ${data.toString()}\n';
        setState(() {
          _debugInfo += debugLine;
        });
        print(debugLine);
      }

      // Filter for current user's dispatches - try different field names
      final userDispatches = snapshot.docs.where((doc) {
        final data = doc.data();

        // Try different possible field names for user ID
        final assignedUserId = data['assignedUserId'];

        print('Checking document: ${doc.id}, assignedUserId: $assignedUserId');

        return assignedUserId == _currentUserId;
      }).toList();

      print('User-specific dispatches found: ${userDispatches.length}');

      setState(() {
        _allDispatches = userDispatches;
        _isLoading = false;
        _debugInfo += '\nUser dispatches found: ${userDispatches.length}';
      });
    } catch (e) {
      print('Error loading dispatches: $e');
      setState(() {
        _isLoading = false;
        _debugInfo = 'Error: $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dispatch Letters',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: Icon(_filterStatus == 'all'
                ? Iconsax.filter
                : Iconsax.filter_remove),
            onPressed: () {
              setState(() {
                _filterStatus = _filterStatus == 'all' ? 'pending' : 'all';
              });
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.info_circle),
            onPressed: () {
              setState(() {
                _debugMode = !_debugMode;
              });
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: _loadDispatches,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentUserId == null) {
      return _buildErrorState('User not authenticated. Please log in again.');
    }

    final filteredDispatches = _filterStatus == 'all'
        ? _allDispatches
        : _allDispatches.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return (data['status'] ?? 'pending') == _filterStatus;
          }).toList();

    if (_allDispatches.isEmpty) {
      return _buildEmptyState();
    }

    if (filteredDispatches.isEmpty) {
      return _buildNoFilteredResultsState();
    }

    return Column(
      children: [
        if (_filterStatus != 'all')
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Chip(
              label: Text('Filter: ${_filterStatus.toUpperCase()}'),
              onDeleted: () {
                setState(() {
                  _filterStatus = 'all';
                });
              },
            ),
          ),
        if (_debugMode) _buildDebugInfo(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredDispatches.length,
            itemBuilder: (context, index) {
              final dispatch =
                  filteredDispatches[index].data() as Map<String, dynamic>;
              final dispatchId = filteredDispatches[index].id;
              return _buildDispatchCard(dispatch, dispatchId, context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDebugInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('DEBUG INFO',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Current User ID: $_currentUserId'),
            const SizedBox(height: 8),
            Text('Total documents in collection: ${_allDispatches.length}'),
            const SizedBox(height: 8),
            Text('Debug info:\n$_debugInfo'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Test different collection names
                _testCollectionNames();
              },
              child: const Text('Test Collection Names'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testCollectionNames() async {
    // Test common collection name variations
    final possibleCollections = [
      'dispatchRequests',
      'dispatch_requests',
      'dispatches',
      'dispatch',
      'letters',
      'dispatchLetters'
    ];

    for (var collection in possibleCollections) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection(collection)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          setState(() {
            _debugInfo +=
                '\nFound collection: $collection (${snapshot.docs.length} docs)';
          });
          print('Found collection: $collection');
        }
      } catch (e) {
        setState(() {
          _debugInfo += '\nCollection $collection not found or error: $e';
        });
        print('Collection $collection not found: $e');
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.document, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No dispatch letters found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'You haven\'t been assigned any dispatch letters yet.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDispatches,
            child: const Text('Refresh'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _debugMode = true;
              });
            },
            child: const Text('Debug Info'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoFilteredResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.filter, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No $_filterStatus dispatches',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try changing your filter or check back later.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _filterStatus = 'all';
              });
            },
            child: const Text('Show All Dispatches'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.warning_2, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDispatches,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDispatchCard(
      Map<String, dynamic> dispatch, String dispatchId, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    dispatch['subject'] ?? 'No Subject',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                _buildStatusBadge(dispatch['status'] ?? 'pending'),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
                Iconsax.tag, 'Reference:', dispatch['referenceNumber']),
            _buildInfoRow(Iconsax.calendar, 'Date:', dispatch['dispatchDate']),
            _buildInfoRow(Iconsax.user, 'Assigned to:',
                dispatch['assignedUserName'] ?? dispatch['assignedUser']),
            const SizedBox(height: 12),
            Text(
              dispatch['description'] ?? 'No description provided',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Iconsax.clock, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      'Created: ${_formatDate(dispatch['createdAt'])}',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () =>
                      _showDispatchDetails(dispatch, dispatchId, context),
                  child: const Text('View Details',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ... (keep the rest of the methods: _buildInfoRow, _buildStatusBadge,
  // _formatDate, _showDispatchDetails, _buildDetailItem)

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: '$label ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: value ?? 'N/A'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'completed':
        color = Colors.green;
        icon = Iconsax.tick_circle;
        break;
      case 'pending':
        color = Colors.orange;
        icon = Iconsax.clock;
        break;
      case 'rejected':
        color = Colors.red;
        icon = Iconsax.close_circle;
        break;
      default:
        color = Colors.grey;
        icon = Iconsax.info_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown date';

    try {
      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is DateTime) {
        date = timestamp;
      } else if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else {
        return 'Invalid date';
      }

      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  void _showDispatchDetails(
      Map<String, dynamic> dispatch, String dispatchId, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        backgroundColor: Colors.white,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        dispatch['subject'] ?? 'Dispatch Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.close_circle, size: 24),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.grey[600],
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                _buildStatusChip(dispatch['status'] ?? 'pending'),
                const SizedBox(height: 24),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic Information Section
                        _buildSectionHeader('Basic Information'),
                        const SizedBox(height: 12),

                        _buildDetailCard(
                          children: [
                            _buildDetailRow(
                              icon: Iconsax.tag,
                              label: 'Reference Number',
                              value: dispatch['referenceNumber'],
                              iconColor: Colors.blue,
                            ),
                            _buildDetailRow(
                              icon: Iconsax.calendar,
                              label: 'Dispatch Date',
                              value: dispatch['dispatchDate'],
                              iconColor: Colors.green,
                            ),
                            _buildDetailRow(
                              icon: Iconsax.user,
                              label: 'Assigned To',
                              value: dispatch['assignedUserName'] ??
                                  dispatch['assignedUser'],
                              iconColor: Colors.purple,
                            ),
                            _buildDetailRow(
                              icon: Iconsax.clock,
                              label: 'Created',
                              value: _formatDate(dispatch['createdAt']),
                              iconColor: Colors.orange,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Description Section
                        _buildSectionHeader('Description'),
                        const SizedBox(height: 12),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Text(
                            dispatch['description'] ??
                                'No description provided',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                              height: 1.5,
                            ),
                          ),
                        ),

                        if (_debugMode) ...[
                          const SizedBox(height: 24),
                          _buildSectionHeader('Debug Information'),
                          const SizedBox(height: 12),
                          _buildDetailCard(
                            children: [
                              _buildDetailRow(
                                icon: Iconsax.document,
                                label: 'Document ID',
                                value: dispatchId,
                                iconColor: Colors.red,
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // Footer Actions
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: colorScheme.primary),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        // Add action for edit or other operations
                        _handleEditDispatch(dispatch, dispatchId, context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Edit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDetailCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String? value,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? 'Not specified',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String statusText;

    switch (status.toLowerCase()) {
      case 'completed':
        backgroundColor = Colors.green[50]!;
        textColor = Colors.green[800]!;
        icon = Iconsax.tick_circle;
        statusText = 'COMPLETED';
        break;
      case 'pending':
        backgroundColor = Colors.orange[50]!;
        textColor = Colors.orange[800]!;
        icon = Iconsax.clock;
        statusText = 'PENDING';
        break;
      case 'rejected':
        backgroundColor = Colors.red[50]!;
        textColor = Colors.red[800]!;
        icon = Iconsax.close_circle;
        statusText = 'REJECTED';
        break;
      case 'in_progress':
        backgroundColor = Colors.blue[50]!;
        textColor = Colors.blue[800]!;
        icon = Iconsax.activity;
        statusText = 'IN PROGRESS';
        break;
      default:
        backgroundColor = Colors.grey[50]!;
        textColor = Colors.grey[800]!;
        icon = Iconsax.info_circle;
        statusText = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String? value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? 'Not specified',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

// Add this method to handle the edit action
  void _handleEditDispatch(
      Map<String, dynamic> dispatch, String dispatchId, BuildContext context) {
    Navigator.pop(context); // Close the details dialog first

    // Navigate to edit screen or show edit dialog
    _showEditDialog(dispatch, dispatchId, context);
  }

  void _showEditDialog(
      Map<String, dynamic> dispatch, String dispatchId, BuildContext context) {
    final theme = Theme.of(context);
    final TextEditingController subjectController =
        TextEditingController(text: dispatch['subject']);
    final TextEditingController descriptionController =
        TextEditingController(text: dispatch['description']);
    final TextEditingController referenceController =
        TextEditingController(text: dispatch['referenceNumber']);

    String? selectedStatus = dispatch['status'] ?? 'pending';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Dispatch',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle, size: 24),
                    onPressed: () => Navigator.pop(context),
                    color: Colors.grey[600],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Edit Form
              TextFormField(
                controller: subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  prefixIcon: const Icon(Iconsax.document),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: referenceController,
                decoration: InputDecoration(
                  labelText: 'Reference Number',
                  prefixIcon: const Icon(Iconsax.tag),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Status',
                  prefixIcon: const Icon(Iconsax.status),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(
                      value: 'in_progress', child: Text('In Progress')),
                  DropdownMenuItem(
                      value: 'completed', child: Text('Completed')),
                  DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                ],
                onChanged: (value) {
                  selectedStatus = value;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(Iconsax.note),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      await _updateDispatch(
                        dispatchId: dispatchId,
                        subject: subjectController.text,
                        description: descriptionController.text,
                        referenceNumber: referenceController.text,
                        status: selectedStatus!,
                        context: context,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save Changes',
                        style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateDispatch({
    required String dispatchId,
    required String subject,
    required String description,
    required String referenceNumber,
    required String status,
    required BuildContext context,
  }) async {
    try {
      final firestoreService =
          Provider.of<FirestoreService>(context, listen: false);

      final updateData = {
        'subject': subject,
        'description': description,
        'referenceNumber': referenceNumber,
        'status': status,
        'updatedAt': DateTime.now(),
      };

      await firestoreService.updateDispatchRequest(dispatchId, updateData);

      Navigator.pop(context); // Close edit dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dispatch updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh the data
      _loadDispatches();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating dispatch: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}