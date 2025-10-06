import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:mahaweli_admin_system/services/user_service.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class AllLeaveRequestsPage extends StatefulWidget {
  const AllLeaveRequestsPage({super.key});

  @override
  _AllLeaveRequestsPageState createState() => _AllLeaveRequestsPageState();
}

class _AllLeaveRequestsPageState extends State<AllLeaveRequestsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  // Filters
  String _statusFilter = 'All';
  String _typeFilter = 'All';
  String _departmentFilter = 'All';
  String _searchQuery = '';
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;

  // Departments list (you can fetch this from Firestore if needed)
  final List<String> _departments = [
    'All',
    'IT',
    'HR',
    'Finance',
    'Operations',
    'Marketing',
    'Sales'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Leave Requests'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: _isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    strokeWidth: 2)
                : const Icon(Iconsax.document_download),
            onPressed: _isLoading ? null : () => _exportFilteredLeaves(),
            tooltip: 'Export Filtered Leaves as PDF',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          _buildFilterSection(),
          const SizedBox(height: 8),
          // Search Bar
          _buildSearchBar(),
          const SizedBox(height: 8),
          // Leave Requests List
          Expanded(
            child: _buildLeaveRequestsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Status and Type Filters
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _statusFilter,
                    items: ['All', 'pending', 'approved', 'rejected']
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _statusFilter = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _typeFilter,
                    items: [
                      'All',
                      'සාමාන්‍ය නිවාඩු',
                      'දවසකින් කොටසක් සදහා නිවාඩු',
                      'අනියම් නිවාඩු',
                      'අසනීප නිවාඩු',
                      'හිලවු නිවාඩු',
                      'විවේක නිවාඩු',
                      'හදිසි අනතුරු නිවාඩු හා විශේෂ අසනීප නිවාඩු',
                      'ඉකුත් නිවාඩු',
                      'විශ්‍රාම පූර්ව නිවාඩු',
                      'විශේෂ නිවාඩු',
                      'රාජකාරි නිවාඩු',
                      'සම්පූර්න වැටුප් සහිත අද්‍යයන නිවාඩු',
                      'වැටුප් රහිත මෙරට අද්‍යයන නිවාඩු',
                      'විදේශ අද්‍යයන සහ/හෝ රැකියා සදහා වැටුප් රහිත නිවාඩු',
                      'ඉපැයූ නිවාඩු',
                      'ප්‍රසූති නිවාඩු',
                      'රජයේ විභාග වලට පෙනී සිටීම සදහා නිවාඩු',
                      'අනිවාර්‍ය නිවාඩු',
                      'අඩ වැටුප් නිවාඩු',
                      'වැටුප් රහිත නිවාඩු',
                      'දිවයිනෙන් බැහැර ගත කරන නිවාඩු',
                      'ගුරුවරුන් සදහා නිවාඩු',
                    ]
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _typeFilter = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Leave Type',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Department and Date Filters
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _departmentFilter,
                    items: _departments
                        .map((dept) => DropdownMenuItem(
                              value: dept,
                              child: Text(dept),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _departmentFilter = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDateRange(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date Range',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _startDateFilter != null && _endDateFilter != null
                                ? '${DateFormat('MMM dd').format(_startDateFilter!)} - ${DateFormat('MMM dd').format(_endDateFilter!)}'
                                : 'Select Date Range',
                            style: TextStyle(
                              color: _startDateFilter != null
                                  ? Colors.black
                                  : Colors.grey[600],
                            ),
                          ),
                          const Icon(Iconsax.calendar, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Clear Filters Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by employee name, reason...',
          prefixIcon: const Icon(Iconsax.search_normal),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Iconsax.close_circle),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildLeaveRequestsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('leave_requests').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.note_remove, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No leave requests found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        var leaveRequests = snapshot.data!.docs;

        // Apply filters
        leaveRequests = _applyFilters(leaveRequests);

        if (leaveRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.filter_remove, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No leave requests match your filters',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear Filters'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: leaveRequests.length,
          itemBuilder: (context, index) {
            final request = leaveRequests[index];
            final data = request.data() as Map<String, dynamic>;
            return _buildLeaveCard(data, context, request.id);
          },
        );
      },
    );
  }

  List<QueryDocumentSnapshot> _applyFilters(
      List<QueryDocumentSnapshot> requests) {
    return requests.where((request) {
      final data = request.data() as Map<String, dynamic>;

      // Status filter
      if (_statusFilter != 'All' && (data['status'] ?? '') != _statusFilter) {
        return false;
      }

      // Type filter
      if (_typeFilter != 'All' && (data['leave_type'] ?? '') != _typeFilter) {
        return false;
      }

      // Department filter
      if (_departmentFilter != 'All' &&
          (data['department'] ?? '') != _departmentFilter) {
        return false;
      }

      // Date range filter
      if (_startDateFilter != null && _endDateFilter != null) {
        final startDate = _parseDate(data['leave_start_date']);
        if (startDate == null ||
            startDate.isBefore(_startDateFilter!) ||
            startDate.isAfter(_endDateFilter!)) {
          return false;
        }
      }

      // Search query
      if (_searchQuery.isNotEmpty) {
        final employeeName =
            (data['employee_name'] ?? '').toString().toLowerCase();
        final reason = (data['reason'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();

        if (!employeeName.contains(query) && !reason.contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  DateTime? _parseDate(dynamic date) {
    if (date == null) return null;

    if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Widget _buildLeaveCard(
      Map<String, dynamic> data, BuildContext context, String requestId) {
    final status = data['status'] ?? 'pending';
    final isApproved = status == 'Approved';
    final isRejected = status == 'Rejected';
    final isOfficialLeave = data['leave_type'] == 'Official Leave';

    // Format dates
    final startDate = _formatDate(data['leave_start_date']);
    final endDate = _formatDate(data['leave_end_date']);
    final appliedDate = _formatDate(data['applied_date']);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with employee info and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['employee_name'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${data['department'] ?? 'N/A'} • ${data['job_role'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isApproved
                        ? Colors.green.withOpacity(0.1)
                        : isRejected
                            ? Colors.red.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isApproved
                            ? Iconsax.tick_circle
                            : isRejected
                                ? Iconsax.close_circle
                                : Iconsax.clock,
                        size: 14,
                        color: isApproved
                            ? Colors.green
                            : isRejected
                                ? Colors.red
                                : Colors.orange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isApproved
                              ? Colors.green
                              : isRejected
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Leave details
            Text(
              data['leave_type'] ?? 'N/A',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Iconsax.calendar, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '$startDate - $endDate',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  appliedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Additional details for official leave
            if (isOfficialLeave) ...[
              _buildDetailRow(
                icon: Iconsax.map,
                text: data['route_details'] ?? 'N/A',
              ),
              const SizedBox(height: 6),
              _buildDetailRow(
                icon: Iconsax.car,
                text: data['vehicle_number'] ?? 'N/A',
              ),
              const SizedBox(height: 12),
            ],

            // Reason for leave
            if (data['reason'] != null && data['reason'].isNotEmpty) ...[
              Text(
                'Reason: ${data['reason']}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
            ],

            // Approved/Rejected by
            if (isApproved || isRejected) ...[
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    isApproved ? Iconsax.user_tick : Iconsax.user_octagon,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${isApproved ? 'Approved' : 'Rejected'} by: ${data['approved_by'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Download button
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Iconsax.document_download, size: 16),
                  label: const Text('Download as PDF'),
                  onPressed: () => _generateSingleLeavePdf(data),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[50],
                    foregroundColor: Colors.blue[700],
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';

    if (date is Timestamp) {
      return DateFormat('MMM dd, yyyy').format(date.toDate());
    } else if (date is String) {
      try {
        final parsedDate = DateTime.parse(date);
        return DateFormat('MMM dd, yyyy').format(parsedDate);
      } catch (e) {
        return date;
      }
    }
    return 'N/A';
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _startDateFilter != null && _endDateFilter != null
          ? DateTimeRange(start: _startDateFilter!, end: _endDateFilter!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDateFilter = picked.start;
        _endDateFilter = picked.end;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _statusFilter = 'All';
      _typeFilter = 'All';
      _departmentFilter = 'All';
      _searchQuery = '';
      _startDateFilter = null;
      _endDateFilter = null;
    });
  }

  Future<void> _exportFilteredLeaves() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot = await _firestore
          .collection('leave_requests')
          .orderBy('applied_date', descending: true)
          .get();

      var filteredLeaves = querySnapshot.docs;
      // filteredLeaves = _applyFilters(filteredLeaves);

      if (filteredLeaves.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No leaves to export with current filters')),
        );
        return;
      }

      final leavesData = filteredLeaves.map((doc) => doc.data()).toList();
      await _generateAndDownloadPdf(leavesData, 'Filtered_Leave_Requests');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting leaves: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateSingleLeavePdf(Map<String, dynamic> leaveData) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _generateAndDownloadPdf([
        leaveData
      ], 'Leave_${_formatDate(leaveData['leave_start_date'])}_${leaveData['employee_name']}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateAndDownloadPdf(
      List<Map<String, dynamic>> leaves, String fileName) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Header(
          level: 0,
          child: pw.Text(
            'Leave Requests Report',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
        ),
        build: (context) => [
          pw.SizedBox(height: 20),
          pw.Text(
              'Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}'),
          if (_statusFilter != 'All') pw.Text('Status: $_statusFilter'),
          if (_typeFilter != 'All') pw.Text('Leave Type: $_typeFilter'),
          if (_departmentFilter != 'All')
            pw.Text('Department: $_departmentFilter'),
          if (_startDateFilter != null && _endDateFilter != null)
            pw.Text(
                'Date Range: ${DateFormat('yyyy-MM-dd').format(_startDateFilter!)} - ${DateFormat('yyyy-MM-dd').format(_endDateFilter!)}'),
          if (_searchQuery.isNotEmpty) pw.Text('Search Query: $_searchQuery'),
          pw.SizedBox(height: 20),
          pw.Text('Total Records: ${leaves.length}'),
          pw.SizedBox(height: 20),
          ...leaves.map((leave) => _buildLeavePdfSection(leave)).toList(),
        ],
      ),
    );

    // Convert PDF to bytes
    final Uint8List pdfBytes = await pdf.save();

    // Create a blob and download link for web
    final html.Blob blob = html.Blob([pdfBytes], 'application/pdf');
    final String url = html.Url.createObjectUrlFromBlob(blob);

    // Create a download link and trigger click
    final html.AnchorElement anchor = html.AnchorElement(href: url)
      ..setAttribute('download', '$fileName.pdf')
      ..click();

    // Clean up
    html.Url.revokeObjectUrl(url);
  }

  pw.Widget _buildLeavePdfSection(Map<String, dynamic> leave) {
    // Helper function to handle text
    String _getText(String? text) {
      return text ?? 'N/A';
    }

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      padding: const pw.EdgeInsets.all(10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Employee: ${_getText(leave['employee_name'])}',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Text('Department: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  '${_getText(leave['department'])} • ${_getText(leave['job_role'])}'),
            ],
          ),
          pw.Row(
            children: [
              pw.Text('Leave Type: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(_getText(leave['leave_type'])),
            ],
          ),
          pw.Row(
            children: [
              pw.Text('Status: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(_getText(leave['status'])),
            ],
          ),
          pw.Row(
            children: [
              pw.Text('Period: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  '${_formatDate(leave['leave_start_date'])} - ${_formatDate(leave['leave_end_date'])}'),
            ],
          ),
          pw.Row(
            children: [
              pw.Text('Applied Date: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(_formatDate(leave['applied_date'])),
            ],
          ),
          if (leave['reason'] != null && leave['reason'].isNotEmpty)
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Reason: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Expanded(child: pw.Text(_getText(leave['reason']))),
              ],
            ),
          if (leave['leave_type'] == 'Official Leave') ...[
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Route: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Expanded(child: pw.Text(_getText(leave['route_details']))),
              ],
            ),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Vehicle: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Expanded(child: pw.Text(_getText(leave['vehicle_number']))),
              ],
            ),
          ],
          if (leave['approved_by'] != null)
            pw.Row(
              children: [
                pw.Text('Approved by: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(_getText(leave['approved_by'])),
              ],
            ),
          pw.SizedBox(height: 10),
          pw.Divider(),
        ],
      ),
    );
  }
}
