// lib/utils/pdf_export_utils.dart
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import '../models/user_model.dart';

class PDFExportUtils {


  // Add this method to the PDFExportUtils class
static Future<pw.Document> generateUserDetailPDF(AppUser user) async {
  final pdf = pw.Document();
  final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  final now = DateTime.now();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Center(
              child: pw.Text(
                'Employee Details',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                'Generated on: ${dateFormat.format(now)}',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 20),

            // User Information
            pw.Text(
              'Personal Information',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue700,
              ),
            ),
            pw.SizedBox(height: 15),
            _buildDetailRow('Full Name', user.name),
            _buildDetailRow('Email Address', user.email),
            _buildDetailRow('Phone Number', user.phone),
            _buildDetailRow('Location', user.location),
            pw.SizedBox(height: 20),

            // Professional Information
            pw.Text(
              'Professional Information',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue700,
              ),
            ),
            pw.SizedBox(height: 15),
            _buildDetailRow('Employee ID', user.id),
            _buildDetailRow('Role', user.role),
            _buildDetailRow('Department', user.department),
            _buildDetailRow('Status', user.isActive ? 'Active' : 'Inactive'),
            _buildDetailRow('Join Date', dateFormat.format(user.createdAt)),
            pw.SizedBox(height: 20),

            // Status Indicator
            pw.Center(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: user.isActive ? PdfColors.green100 : PdfColors.red100,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(
                    color: user.isActive ? PdfColors.green : PdfColors.red,
                    width: 1,
                  ),
                ),
                child: pw.Text(
                  user.isActive ? 'ACTIVE EMPLOYEE' : 'INACTIVE EMPLOYEE',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: user.isActive ? PdfColors.green : PdfColors.red,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );

  return pdf;
}

// Helper method for detail rows
static pw.Widget _buildDetailRow(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '$label:',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 12),
          ),
        ),
      ],
    ),
  );
}




  static Future<pw.Document> generateUsersPDF(List<AppUser> users, {String? filter}) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final now = DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        
        header: (context) => pw.Header(
          level: 0,
          child: pw.Column(
            children: [
              pw.Text(
                'User Management Report',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Generated on: ${dateFormat.format(now)}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              if (filter != null) pw.Text(
                'Filter: $filter',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Footer(
          title: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                'Confidential - Internal Use Only',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
        build: (context) => [
          pw.SizedBox(height: 20),
          _buildSummary(users),
          pw.SizedBox(height: 20),
          _buildUsersTable(users, dateFormat),
        ],
      ),
    );

    return pdf;
  }

  static pw.Widget _buildSummary(List<AppUser> users) {
    final activeUsers = users.where((user) => user.isActive).length;
    final admins = users.where((user) => user.role == 'Admin').length;
    final departments = users.map((user) => user.department).toSet().length;

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        _buildSummaryItem('Total Users', users.length.toString()),
        _buildSummaryItem('Active Users', activeUsers.toString()),
        _buildSummaryItem('Admins', admins.toString()),
        _buildSummaryItem('Departments', departments.toString()),
      ],
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  static pw.Widget _buildUsersTable(List<AppUser> users, DateFormat dateFormat) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.5),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.2),
        4: const pw.FlexColumnWidth(1.2),
        5: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableHeader('Name'),
            _buildTableHeader('Email'),
            _buildTableHeader('Phone'),
            _buildTableHeader('Role'),
            _buildTableHeader('Status'),
            _buildTableHeader('Created At'),
          ],
        ),
        ...users.map((user) => pw.TableRow(
          children: [
            _buildTableCell(user.name),
            _buildTableCell(user.email),
            _buildTableCell(user.phone),
            _buildTableCell(user.role),
            _buildTableCell(user.isActive ? 'Active' : 'Inactive', 
                color: user.isActive ? PdfColors.green : PdfColors.red),
            _buildTableCell(dateFormat.format(user.createdAt)),
          ],
        )).toList(),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, {PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          color: color,
        ),
      ),
    );
  }
}