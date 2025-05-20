import 'package:flutter/material.dart';

class RightSidebar extends StatelessWidget {
  const RightSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildRightSidebar(context);
  }

  Widget _buildRightSidebar(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'To-Do List',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: [
              _buildTodoItem(
                'Review Q1 reports',
                'High',
                true,
              ),
              _buildTodoItem(
                'Approve leave requests',
                'Medium',
                false,
              ),
              _buildTodoItem(
                'Update system docs',
                'Low',
                false,
              ),
              _buildTodoItem(
                'Team meeting prep',
                'High',
                true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),
        Expanded(
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Activity',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildActivityItem(
                    'Approved leave request',
                    '2 hours ago',
                  ),
                  _buildActivityItem(
                    'Uploaded Q1 report',
                    '5 hours ago',
                  ),
                  _buildActivityItem(
                    'Completed system update',
                    'Yesterday',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildTodoItem(String task, String priority, bool urgent) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: urgent ? Colors.red : Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Text(
                task,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Chip(
              label: Text(priority),
              backgroundColor: urgent
                  ? Colors.red.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              labelStyle: TextStyle(
                color: urgent ? Colors.red : Colors.orange,
                fontSize: 12,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String action, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}