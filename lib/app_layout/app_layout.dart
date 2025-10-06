import 'package:flutter/material.dart';
import 'package:mahaweli_admin_system/components/left_sidebar.dart';
import 'package:mahaweli_admin_system/components/right_sidebar.dart';
import 'package:mahaweli_admin_system/providers.dart';
import 'package:mahaweli_admin_system/screens/homepage.dart';
import 'package:mahaweli_admin_system/screens/upcoming_salary_increment_screen.dart';
import 'package:mahaweli_admin_system/services/dispatch/dispatc_for_screen.dart';
import 'package:mahaweli_admin_system/services/leave/presentation/pages/leave_manage.dart';
import 'package:provider/provider.dart';
import '../screens/employee_profiles.dart';
import '../screens/employee_requests_page.dart';
import '../screens/leave_request_management.dart';
import '../screens/leave_requests_details_page.dart';
import '../screens/profile_page.dart';
import '../services/chat/pages/home_page.dart';
import '../services/complain/presentation/pages/complain_management.dart';
import '../services/dispatch/dashboard_screen.dart';
import '../services/dispatch/view_dispatch_screen.dart';
import '../services/leave/presentation/pages/leave_application_page.dart';
import '../services/note/presentation/pages/notes_page.dart';
import '../services/resource_mapping/pages/map_screen.dart';
import '../user_management_screen.dart';

class AppLayout extends StatefulWidget {
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
  State<AppLayout> createState() => _AppLayoutState();
}



class _AppLayoutState extends State<AppLayout> {
  Widget _getPage(String pageName) {
    switch (pageName) {
      case 'Dashboard':
        return const HomePage();
      case 'Chat':
        return ChatHome();
      case 'Notes':
        return const NotesPage();
      case 'Profile':
        return const ProfilePage();
      case 'Employee Profiles':
        return const EmployeeManagementPage();
      case 'Request Management':
        return const EmployeeRequestsPage();
      case 'Apply Leave':
        return const LeaveApplicationForm();
      case 'Leave Management':
        return const ApproveLeavePage();
      case 'Complain Management':
        return const ComplainManagement();
      case 'View Complains':
        return const ViewComplains();
      case 'Leave Request Management':
        return const AllLeaveRequestsPage();
      case 'Leave Request Details':
        return const EmployeeLeaveHistoryPage();
      case 'Resource Mapping':
        return const MapScreen();
      case 'Dispatch Management':
        return const DashboardScreen();
      case 'Dispatch Requests':
        return const ViewDispatchScreen();
      case 'Employee Profiles Management':
        return const UserManagementScreen();
      case 'Dispatch Form Screen':
        return const DispatchFormScreen();
      case 'Upcoming Salary Incremental':
        return const UpcomingSalaryIncrementScreen();
      default:
        return Center(child: Text('Page not found: $pageName'));
    }
  }

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
                  if (widget.showLeftSidebar && isMediumScreen) ...[
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

                  
                  Expanded(
                    child: Consumer<NavigationProvider>(
                      builder: (context, navigation, child) {
                        // Get the current page based on the navigation index
                        final currentPage = _getPage(navigation.currentIndex);
                    
                        return Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: Padding(
                            padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
                            child: currentPage,
                          ),
                        );
                      },
                    ),
                  ),

                  // Right Sidebar
                  if (widget.showRightSidebar && isLargeScreen) ...[
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
