import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:open_filex/open_filex.dart';

import '../models/report_model.dart';
import '../src/local_repository.dart';

class UserReportsPage extends StatefulWidget {
  final String userId;
  
  const UserReportsPage({super.key, required this.userId});

  @override
  State<UserReportsPage> createState() => _UserReportsPageState();
}

class _UserReportsPageState extends State<UserReportsPage> with SingleTickerProviderStateMixin {
  final LocalReportRepository _repository = LocalReportRepository();
  List<Report> _reports = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  late AnimationController _emptyStateController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _emptyStateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _loadUserReports();
  }

  @override
  void dispose() {
    _emptyStateController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserReports() async {
    try {
      setState(() => _isRefreshing = true);
      final reports = await _repository.getUserReports(widget.userId);
      setState(() {
        _reports = reports;
        _isLoading = false;
        _isRefreshing = false;
      });
      
      if (_reports.isEmpty) {
        _emptyStateController.forward();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
      _emptyStateController.forward();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading reports: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _addNewReport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'png', 'jpg', 'jpeg'],
      dialogTitle: 'Select Report File',
    );

    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      final newReport = Report(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: widget.userId,
        title: file.name,
        description: 'Uploaded ${file.extension?.toUpperCase()} file',
        status: 'uploaded',
        createdAt: DateTime.now(),
        filePath: file.path,
      );

      await _repository.addReport(newReport);
      await _loadUserReports();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${file.name} uploaded successfully'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewReport,
        child: const Icon(Iconsax.document_upload),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? _buildEmptyState()
              : CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverAppBar(
                      title: const Text('My Reports'),
                      floating: true,
                      snap: true,
                      actions: [
                        IconButton(
                          icon: const Icon(Iconsax.search_normal),
                          onPressed: () => _showSearchDialog(),
                        ),
                        IconButton(
                          icon: const Icon(Iconsax.filter),
                          onPressed: () => _showFilterOptions(),
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Text(
                          '${_reports.length} report${_reports.length != 1 ? 's' : ''} found',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildReportCard(_reports[index]),
                          childCount: _reports.length,
                        ),
                      ),
                    ),
                    if (_isRefreshing)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildReportCard(Report report) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final iconColor = _getStatusColor(report.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.surfaceVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openFile(report),
        onLongPress: () => _showReportOptions(report),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getFileIcon(report.title),
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.title,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatFileSize(report.filePath),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(report.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      report.status.toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        color: _getStatusColor(report.status),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                report.description,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Iconsax.calendar,
                    size: 16,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(report.createdAt),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Iconsax.more,
                      size: 20,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                    onPressed: () => _showReportOptions(report),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.document,
                size: 60,
                color: colorScheme.primary.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Reports Found',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload your medical reports, lab results,\nor other documents to get started',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _addNewReport,
              icon: const Icon(Iconsax.document_upload, size: 18),
              label: const Text('Upload Report'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFile(Report report) async {
    if (report.filePath == null) return;
    
    try {
      final result = await OpenFilex.open(report.filePath!);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file: ${result.message}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteReport(String reportId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text('This action cannot be undone. Are you sure you want to delete this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _repository.deleteReport(reportId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Report deleted successfully'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      await _loadUserReports();
    }
  }

  Future<void> _showReportOptions(Report report) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Iconsax.document_download),
              title: const Text('Download'),
              onTap: () {
                Navigator.pop(context);
                // Implement download functionality
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // Implement share functionality
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.edit),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(report);
              },
            ),
            ListTile(
              leading: Icon(Iconsax.trash, color: Colors.red[400]),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteReport(report.id);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _showRenameDialog(Report report) async {
    final controller = TextEditingController(text: report.title);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Report'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New Report Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                // final updatedReport = report.copyWith(title: controller.text.trim());
                // await _repository.updateReport(updatedReport);
                if (mounted) {
                  Navigator.pop(context);
                  await _loadUserReports();
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSearchDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Reports'),
        content: const Text('Search functionality will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilterOptions() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Filter Reports',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            ListTile(
              leading: const Icon(Iconsax.document),
              title: const Text('All Reports'),
              trailing: const Icon(Iconsax.tick_circle),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Iconsax.document_upload, color: Colors.blue[400]),
              title: const Text('Uploaded'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Iconsax.document_text, color: Colors.green[400]),
              title: const Text('Processed'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Iconsax.document_cloud, color: Colors.red[400]),
              title: const Text('Failed'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Iconsax.document_text;
      case 'doc':
      case 'docx':
        return Iconsax.document_text;
      case 'xls':
      case 'xlsx':
        return Iconsax.document_text;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Iconsax.gallery;
      default:
        return Iconsax.document;
    }
  }

  String _formatFileSize(String? filePath) {
    if (filePath == null) return 'Unknown size';
    // Implement actual file size calculation if needed
    return '${(filePath.length % 1000)} KB'; // Placeholder
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'uploaded':
        return Colors.blue;
      case 'processed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}