import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../classes/task.dart';

class AnnualTaskCard {
  static Widget buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_outlined,
              size: 96,
              color: colorScheme.primary.withOpacity(0.2),
            ),
            const SizedBox(height: 24),
            Text(
              'No Tasks Found',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You currently have no tasks scheduled.\nTap the + button to create a new task.',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.tonal(
              onPressed: () {
                // Handle create new task
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
              ),
              child: const Text('Create New Task'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildCard(Task task) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Card(
            margin: EdgeInsets.all(isMobile ? 8 : 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // Handle task card tap
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                        child: CachedNetworkImage(
                          imageUrl: task.imageUrl,
                          fit: BoxFit.cover,
                          height: isMobile
                              ? 120
                              : constraints.maxWidth > 900
                                  ? 180
                                  : 150,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            color: colorScheme.surfaceVariant,
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: colorScheme.errorContainer,
                            child: Icon(Icons.error_outline,
                                color: colorScheme.onErrorContainer),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Chip(
                          label: Text('High Priority',
                              style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onErrorContainer)),
                          backgroundColor: colorScheme.errorContainer,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(isMobile ? 12 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(task.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.primary),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded,
                                size: 16, color: colorScheme.primary),
                          ],
                        ),
                        SizedBox(height: isMobile ? 8 : 12),
                        Text(task.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.8)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        SizedBox(height: isMobile ? 8 : 12),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 16, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Due: ${_formatDate(task.dueDate.toString())}',
                              style: theme.textTheme.labelSmall
                                  ?.copyWith(color: colorScheme.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _calculateProgress(task),
                          backgroundColor: colorScheme.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              _getProgressColor(
                                  _calculateProgress(task), colorScheme)),
                          borderRadius: BorderRadius.circular(8),
                          minHeight: 6,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    return DateFormat('MMM dd, y').format(parsedDate);
  }

  static double _calculateProgress(Task task) {
    // Implement your progress calculation logic
    return 0.65; // Example value
  }

  static Color _getProgressColor(double progress, ColorScheme colorScheme) {
    if (progress < 0.3) return colorScheme.error;
    if (progress < 0.7) return colorScheme.primary;
    return colorScheme.tertiary;
  }
}
