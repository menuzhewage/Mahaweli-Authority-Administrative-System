import 'package:flutter/material.dart';
import 'package:mahaweli_admin_system/components/left_sidebar.dart';
import 'package:mahaweli_admin_system/components/right_sidebar.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final bool showLeftSidebar;
  final bool showRightSidebar;

  const AppLayout({
    super.key,
    required this.child,
    this.showLeftSidebar = true,
    this.showRightSidebar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 1200;
          final isMediumScreen = constraints.maxWidth > 800;

          return Padding(
            padding: EdgeInsets.all(isLargeScreen ? 16.0 : 8.0),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: EdgeInsets.zero,
              child: Row(
                children: [
                  // Left Sidebar
                  if (showLeftSidebar && isMediumScreen) ...[
                    Container(
                      width: isLargeScreen
                          ? constraints.maxWidth * 0.18
                          : constraints.maxWidth * 0.22,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(16),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isLargeScreen ? 20.0 : 12.0,
                          vertical: 30,
                        ),
                        child: const LeftSidebar(),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: constraints.maxHeight,
                      color: Colors.grey.withOpacity(0.1),
                    ),
                  ],

                  // Main Content
                  Expanded(
                    child: Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: Padding(
                        padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
                        child: child,
                      ),
                    ),
                  ),

                  // Right Sidebar
                  if (showRightSidebar && isLargeScreen) ...[
                    Container(
                      width: 1,
                      height: constraints.maxHeight,
                      color: Colors.grey.withOpacity(0.1),
                    ),
                    Container(
                      width: constraints.maxWidth * 0.18,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(16),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 30,
                        ),
                        child: RightSidebar(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
