import 'package:flutter/material.dart';
import 'package:mahaweli_admin_system/services/todo/presentation/pages/to_do_page.dart';

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
        const Expanded(
          child: ToDoPage(),
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),
      ],
    );
  }
}