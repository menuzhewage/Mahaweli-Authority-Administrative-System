import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
          height: 60,
          backgroundColor: Colors.transparent,
          surfaceTintColor: colorScheme.surfaceTint,
          elevation: 0,
          indicatorShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          indicatorColor: colorScheme.primary.withOpacity(0.1),
          selectedIndex: currentIndex,
          animationDuration: const Duration(milliseconds: 300),
          onDestinationSelected: onTap,
          destinations: [
            _buildNavigationDestination(
              context,
              Iconsax.home,
              Iconsax.home,
              '',
              currentIndex == 0,
            ),
            _buildNavigationDestination(
              context,
              Iconsax.message,
              Iconsax.message,
              '',
              currentIndex == 1,
            ),
            _buildNavigationDestination(
              context,
              Iconsax.document,
              Iconsax.document,
              '',
              currentIndex == 2,
            ),
            _buildNavigationDestination(
              context,
              Iconsax.user,
              Iconsax.user,
              '',
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
      icon: Icon(
        icon,
        size: 16,
        color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.6),
      ),
      selectedIcon: Icon(
        size: 16,
        selectedIcon,
        color: colorScheme.primary,
      ),
      label: label,
    );
  }
}