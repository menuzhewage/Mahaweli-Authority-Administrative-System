import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:mahaweli_admin_system/services/user_service.dart';

class EmployeeLeaveHistoryPage extends StatefulWidget {
  const EmployeeLeaveHistoryPage({super.key});

  @override
  _EmployeeLeaveHistoryPageState createState() =>
      _EmployeeLeaveHistoryPageState();
}

class _EmployeeLeaveHistoryPageState extends State<EmployeeLeaveHistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? uid = UserService.currentUserId;
  String? employeeName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchEmployeeName();
    uid = UserService.currentUserId;
  }

  Future<void> _fetchEmployeeName() async {
    if (uid != null) {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        setState(() {
          employeeName = doc['name'] ?? 'Employee';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(employeeName != null
            ? '$employeeName\'s Leave History'
            : 'Leave History'),
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
            onPressed: _isLoading ? null : () => _exportAllApprovedLeaves(),
            tooltip: 'Export Approved Leaves as PDF',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('leave_requests')
            .where('uid', isEqualTo: uid)
            .snapshots(),
            
        builder: (context, snapshot) {
          print(uid);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
          } else if (snapshot.hasData) {
            final leaveRequests = snapshot.data!.docs;


            print('Fetched ${leaveRequests.length} ');
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: leaveRequests.length,
              itemBuilder: (context, index) {
                final request = leaveRequests[index];
                final data = request.data() as Map<String, dynamic>;
                return _buildLeaveCard(data, context, request.id);
              },
            );
          } else {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red[700]),
              ),
            );
          }
        },
      ),
    );
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
            // Status and dates row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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

            // Leave type and duration
            Text(
              data['leave_type'] ?? 'N/A',
              style: const TextStyle(
                fontSize: 18,
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

            // Download button for approved leaves
            if (isApproved) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
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
              ),
            ],
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

  Future<void> _exportAllApprovedLeaves() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot = await _firestore
          .collection('leave_requests')
          .where('uid', isEqualTo: uid)
          .where('status', isEqualTo: 'Approved')
          .orderBy('leave_start_date', descending: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No approved leaves to export')),
        );
        return;
      }

      final approvedLeaves =
          querySnapshot.docs.map((doc) => doc.data()).toList();
      await _generateAndDownloadPdf(approvedLeaves, 'All_Approved_Leaves');
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
      await _generateAndDownloadPdf(
          [leaveData], 'Leave_${_formatDate(leaveData['leave_start_date'])}');
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
    final employeeName = await _getEmployeeName();

    pdf.addPage(
      pw.MultiPage(
        header: (context) => pw.Header(
          level: 0,
          child: pw.Text(
            'Leave Records - $employeeName',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
        ),
        build: (context) => [
          pw.SizedBox(height: 20),
          pw.Text(
              'Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}'),
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
            leave['leave_type'] ?? 'N/A',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Text('Status: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(leave['status'] ?? 'N/A'),
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
          if (leave['reason'] != null && leave['reason'].isNotEmpty)
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Reason: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Expanded(child: pw.Text(leave['reason'])),
              ],
            ),
          if (leave['leave_type'] == 'Official Leave') ...[
            pw.Row(
              children: [
                pw.Text('Route: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(leave['route_details'] ?? 'N/A'),
              ],
            ),
            pw.Row(
              children: [
                pw.Text('Vehicle: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(leave['vehicle_number'] ?? 'N/A'),
              ],
            ),
          ],
          if (leave['approved_by'] != null)
            pw.Row(
              children: [
                pw.Text('Approved by: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(leave['approved_by'] ?? 'N/A'),
              ],
            ),
          pw.SizedBox(height: 10),
          pw.Divider(),
        ],
      ),
    );
  }

  Future<String> _getEmployeeName() async {
    if (employeeName != null) return employeeName!;

    if (uid != null) {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc['name'] ?? 'Employee';
    }

    return 'Employee';
  }
}
