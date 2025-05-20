import 'package:flutter/material.dart';
import 'package:mahaweli_admin_system/screens/employee_profiles.dart';
import 'package:mahaweli_admin_system/screens/employee_requests_page.dart';

class LeftSidebar extends StatelessWidget {
  const LeftSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildLeftSidebar(context);
  }

  Widget _buildLeftSidebar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: Center(
            child: Text(
              'Admin Dashboard',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildSidebarButton(
          context,
          Icons.people_alt_outlined,
          'Employee Profiles',
        ),
        const SizedBox(height: 12),
        _buildSidebarButton(
          context,
          Icons.request_page_outlined,
          'Request Management',
        ),
        const SizedBox(height: 12),
        _buildSidebarButton(
          context,
          Icons.calendar_month_outlined,
          'Leave Management',
        ),
        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 24),
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
                    'Team Chat',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildChatItem(
                    'Sarah Johnson',
                    'About the quarterly report...',
                    true,
                  ),
                  _buildChatItem(
                    'Michael Chen',
                    'I sent the budget files',
                    false,
                  ),
                  _buildChatItem(
                    'Emma Wilson',
                    'Meeting at 2pm tomorrow',
                    true,
                  ),
                  const Spacer(),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: colorScheme.surfaceVariant.withOpacity(0.4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.send,
                          color: colorScheme.primary,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarButton(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(icon, size: 20),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: theme.dividerColor.withOpacity(0.5),
            ),
          ),
        ),
        onPressed: () {
          if (text == "Employee Profiles"){
            Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeManagementPage()));
          } else if (text == "Request Management"){
            Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeRequestsPage()));
          }
        },
      ),
    );
  }

  Widget _buildChatItem(String name, String message, bool unread) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[200],
            child: Text(
              name.substring(0, 1),
              style: const TextStyle(color: Colors.black),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: unread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: unread ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (unread)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}