import 'package:flutter/material.dart';
import 'package:mahaweli_admin_system/screens/chat_page.dart';
import 'package:mahaweli_admin_system/screens/homepage.dart';
import 'package:mahaweli_admin_system/screens/profile_page.dart';
import 'package:mahaweli_admin_system/screens/reports_page.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: NavigationBar(
          height: 72,
          backgroundColor: colorScheme.surface,
          surfaceTintColor: colorScheme.surfaceTint,
          elevation: 0,
          indicatorShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          indicatorColor: colorScheme.primary.withOpacity(0.1),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          selectedIndex: currentIndex,
          animationDuration: const Duration(milliseconds: 300),
          onDestinationSelected: onTap,
          destinations: [
            _buildNavigationDestination(
              context,
              Icons.home_outlined,
              Icons.home_rounded,
              'Home',
              currentIndex == 0,
            ),
            _buildNavigationDestination(
              context,
              Icons.chat_bubble_outline_rounded,
              Icons.chat_bubble_rounded,
              'Chat',
              currentIndex == 1,
            ),
            _buildNavigationDestination(
              context,
              Icons.assessment_outlined,
              Icons.assessment_rounded,
              'Reports',
              currentIndex == 2,
            ),
            _buildNavigationDestination(
              context,
              Icons.person_outline_rounded,
              Icons.person_rounded,
              'Profile',
              currentIndex == 3,
            ),
          ],
        ),
      ),
    );
  }

  NavigationDestination _buildNavigationDestination(
    BuildContext context,
    IconData icon,
    IconData selectedIcon,
    String label,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return NavigationDestination(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? colorScheme.primary.withOpacity(0.1) : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 24,
          color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      selectedIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: colorScheme.primary.withOpacity(0.1),
        ),
        child: Icon(
          selectedIcon,
          size: 24,
          color: colorScheme.primary,
        ),
      ),
      label: label,
    );
  }
}