import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mahaweli_admin_system/providers.dart';
import 'package:mahaweli_admin_system/screens/employee_profiles.dart';
import 'package:mahaweli_admin_system/screens/employee_requests_page.dart';
import 'package:mahaweli_admin_system/screens/leave_request_management.dart';
import 'package:mahaweli_admin_system/screens/leave_requests_details_page.dart';
import 'package:mahaweli_admin_system/services/auth/login.dart';
import 'package:mahaweli_admin_system/services/complain/presentation/pages/complain_management.dart';
import 'package:mahaweli_admin_system/services/dispatch/dashboard_screen.dart';
import 'package:mahaweli_admin_system/services/leave/presentation/pages/leave_application_page.dart';
import 'package:mahaweli_admin_system/services/leave/presentation/pages/leave_manage.dart';
import 'package:mahaweli_admin_system/services/resource_mapping/pages/map_screen.dart';
import 'package:mahaweli_admin_system/services/user_service.dart';
import 'package:mahaweli_admin_system/user_management_screen.dart';
import 'package:provider/provider.dart';
import '../screens/upcoming_salary_increment_screen.dart';
import '../services/dispatch/view_dispatch_screen.dart';

class LeftSidebar extends StatefulWidget {
  const LeftSidebar({super.key});

  @override
  State<LeftSidebar> createState() => _LeftSidebarState();
}

class _LeftSidebarState extends State<LeftSidebar> {
  String? _selectedItem;
  NavigationProvider navigationProvider = NavigationProvider();

  // Map to track which page corresponds to which navigation item
  final Map<Type, String> _pageToItemMap = {
    EmployeeManagementPage: 'Employee Profiles',
    EmployeeRequestsPage: 'Request Management',
    LeaveApplicationForm: 'Apply Leave',
    ApproveLeavePage: 'Leave Management',
    ComplainManagement: 'Complain Management',
    ViewComplains: 'View Complains',
    AllLeaveRequestsPage: 'Leave Request Management',
    EmployeeLeaveHistoryPage: 'Leave Request Details',
    MapScreen: 'Resource Mapping',
    DashboardScreen: 'Dispatch Management',
    ViewDispatchScreen: 'Dispatch Requests',
    UserManagementScreen: 'Employee Profiles Management',
    UpcomingSalaryIncrementScreen: 'Upcoming Salary Incremental'
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSelectionFromCurrentPage();
    });
  }

  void _updateSelectionFromCurrentPage() {
    final currentRoute = ModalRoute.of(context);
    if (currentRoute != null) {
      final currentPage = currentRoute.settings.name;

      // Try to find a matching page in our map
      for (var entry in _pageToItemMap.entries) {
        if (currentPage?.contains(entry.key.toString()) ?? false) {
          setState(() {
            _selectedItem = entry.value;
          });
          break;
        }
      }
    }
  }

  //logout function
  Future<void> _logout(BuildContext context) async {
    await UserService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const PurpleLoginPage(),
      ),
    );
  }

  String _currentIndex = '1';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    String? role = UserService.currentUserRole;

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
              '${UserService.currentUserRole} Dashboard',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        //Administrator specific buttons
        if (role == 'Administrator') ...[
          _buildSidebarButton(
            context,
            Icons.people_alt_outlined,
            'Employee Profiles',
            isSelected: _selectedItem == 'Employee Profiles',
          ),
          const SizedBox(height: 12),
          _buildSidebarButton(
            context,
            Icons.request_page_outlined,
            'Request Management',
            isSelected: _selectedItem == 'Request Management',
          ),
          const SizedBox(height: 12),
          _buildSidebarButton(
            context,
            Icons.manage_accounts,
            'Leave Management',
            isSelected: _selectedItem == 'Leave Management',
          ),
          const SizedBox(height: 12),
          _buildSidebarButton(
            context,
            Iconsax.map,
            'Resource Mapping',
            isSelected: _selectedItem == 'Resource Mapping',
          ),
        ],

        if (role == 'Personal File Handler') ...[

          _buildSidebarButton(
            context,
            Iconsax.user,
            'Employee Profiles Management',
            isSelected: _selectedItem == 'Employee Profiles Management',
          ),

          const SizedBox(height: 12,),

          _buildSidebarButton(
            context,
            Iconsax.money,
            'Upcoming Salary Incremental',
            isSelected: _selectedItem == 'Upcoming Salary Incremental',
          ),

        ],

        if (role == 'Complain Handler') ...[
          _buildSidebarButton(
            context,
            Icons.report_gmailerrorred_outlined,
            'Complain Management',
            isSelected: _selectedItem == 'Complain Management',
          ),

          const SizedBox(height: 12),

        ],

        if (role == 'RPM') ...[
          _buildSidebarButton(
            context,
            Icons.manage_accounts,
            'Leave Management',
            isSelected: _selectedItem == 'Leave Management',
          ),
          const SizedBox(height: 12),
          _buildSidebarButton(
            context,
            Icons.attach_file_outlined,
            'View Complains',
            isSelected: _selectedItem == 'View Complains',
          ),
          const SizedBox(height: 12),
        ],

        if (role == 'Leave Handler') ...[
          _buildSidebarButton(
            context,
            Icons.manage_accounts,
            'Leave Request Management',
            isSelected: _selectedItem == 'Leave Request Management',
          ),
          const SizedBox(height: 12),
        ],

        if (role == 'Dispatch Handler') ...[
          _buildSidebarButton(
            context,
            Icons.newspaper,
            'Dispatch Management',
            isSelected: _selectedItem == 'Dispatch Management',
          ),
        ],

        const SizedBox(height: 12),

        //Common buttons
        role != 'RPM'
            ? _buildSidebarButton(
                context,
                Icons.calendar_month_outlined,
                'Apply Leave',
                isSelected: _selectedItem == 'Apply Leave',
              )
            : const SizedBox(),
        const SizedBox(height: 12),

        role != 'RPM'
            ? _buildSidebarButton(
                context,
                Icons.details,
                'Leave Request Details',
                isSelected: _selectedItem == 'Leave Request Details',
              )
            : const SizedBox(),

        const SizedBox(height: 12),

        _buildSidebarButton(
          context,
          Icons.newspaper,
          'Dispatch Requests',
          isSelected: _selectedItem == 'Dispatch Requests',
        ),

        const SizedBox(height: 12),
        _buildSidebarButton(
          context,
          Iconsax.logout,
          'Logout',
          isSelected: false,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSidebarButton(
    BuildContext context,
    IconData icon,
    String text, {
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              width: 3,
            ),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: OutlinedButton.icon(
          icon: Icon(
            icon,
            size: 20,
            color: isSelected ? colorScheme.primary : null,
          ),
          label: Text(
            text,
            style: TextStyle(
              color: isSelected ? colorScheme.primary : null,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          style: OutlinedButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: BorderSide.none,
            backgroundColor: Colors.transparent,
          ),
          onPressed: () {
            setState(() {
              _selectedItem = text;
            });

            //Switch for navigation
            switch (text) {
              case "Employee Profiles":
                {
                  final navigationProvider =
                      Provider.of<NavigationProvider>(context, listen: false);
                  navigationProvider.updateCurrentIndex('Employee Profiles');
                }
                break;
              case "Request Management":
                {
                  final navigationProvider =
                      Provider.of<NavigationProvider>(context, listen: false);
                  navigationProvider.updateCurrentIndex('Request Management');
                }
                break;
              case "Apply Leave":
                {
                  final navigationProvider =
                      Provider.of<NavigationProvider>(context, listen: false);
                  navigationProvider.updateCurrentIndex('Apply Leave');
                }
                break;
              case "Leave Management":
                {
                  final navigationProvider =
                      Provider.of<NavigationProvider>(context, listen: false);
                  navigationProvider.updateCurrentIndex('Leave Management');
                }
                break;
              case "Complain Management":
                {
                  final navigationProvider =
                      Provider.of<NavigationProvider>(context, listen: false);
                  navigationProvider.updateCurrentIndex('Complain Management');
                }
                break;
              case "View Complains":
                {
                  final navigationProvider =
                      Provider.of<NavigationProvider>(context, listen: false);
                  navigationProvider.updateCurrentIndex('View Complains');
                }
                break;
              case "Logout":
                {
                  _logout(context);
                }
                break;
              case "Leave Request Management":
                {
                  final navigationProvider =
                      Provider.of<NavigationProvider>(context, listen: false);
                  navigationProvider
                      .updateCurrentIndex('Leave Request Management');
                }
                break;
              case "Leave Request Details":
                {
                  final navigationProvider =
                      Provider.of<NavigationProvider>(context, listen: false);
                  navigationProvider
                      .updateCurrentIndex('Leave Request Details');
                }
                break;

              case "Resource Mapping":
                {
                  final navigationProvider =
                      Provider.of<NavigationProvider>(context, listen: false);
                  navigationProvider.updateCurrentIndex('Resource Mapping');
                }
                break;

              case "Dispatch Management":
                {
                  final navigationProvider =
                      Provider.of<NavigationProvider>(context, listen: false);
                  navigationProvider.updateCurrentIndex('Dispatch Management');
                }
                break;
              case "Dispatch Requests":
                {
                  final navigationProvider =
                      Provider.of<NavigationProvider>(context, listen: false);
                  navigationProvider.updateCurrentIndex('Dispatch Requests');
                }
                break;
              case "Employee Profiles Management":
                {
                  final navigationProvider =
                      Provider.of<NavigationProvider>(context, listen: false);
                  navigationProvider
                      .updateCurrentIndex('Employee Profiles Management');
                }
                break;
              case "Staff Dashboard":
                {
                  final navigationProvider =
                      Provider.of<NavigationProvider>(context, listen: false);
                  navigationProvider.updateCurrentIndex('Staff Dashboard');
                }
                break;
              case "Upcoming Salary Incremental":
                {
                  final navigationProvider =
                        Provider.of<NavigationProvider>(context, listen: false);
                    navigationProvider.updateCurrentIndex('Upcoming Salary Incremental');
                }
                break;
              default:
            }
          },
        ),
      ),
    );
  }
}
