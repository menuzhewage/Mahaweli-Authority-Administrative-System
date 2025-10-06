import 'package:flutter/material.dart';
import 'package:mahaweli_admin_system/components/bottum_navigation_bar.dart';
import 'package:mahaweli_admin_system/screens/employee_profiles.dart';
import 'package:mahaweli_admin_system/services/chat/pages/home_page.dart';
import 'package:mahaweli_admin_system/services/complain/presentation/pages/complain_management.dart';
import 'package:mahaweli_admin_system/services/note/presentation/pages/notes_page.dart';
import 'package:provider/provider.dart';
import '../providers.dart';
import '../screens/homepage.dart';
import '../screens/profile_page.dart';
import 'app_layout.dart';

class MainWrapper extends StatefulWidget {

  const MainWrapper({super.key});
  @override
  State<MainWrapper> createState() => _MainWrapperState();

}

class _MainWrapperState extends State<MainWrapper> {
  
  int _currentIndex = 0;

  void _onTap(int index) {
    switch (index) {
      case 0:
        {
          final navigationProvider =
              Provider.of<NavigationProvider>(context, listen: false);
          navigationProvider.updateCurrentIndex('Dashboard');
        }
      case 1:
        {
          final navigationProvider =
              Provider.of<NavigationProvider>(context, listen: false);
          navigationProvider.updateCurrentIndex('Chat');
        }
      case 2:
        {
          final navigationProvider =
              Provider.of<NavigationProvider>(context, listen: false);
          navigationProvider.updateCurrentIndex('Notes');
        }
      case 3:
        {
          final navigationProvider =
              Provider.of<NavigationProvider>(context, listen: false);
          navigationProvider.updateCurrentIndex('Profile');
        }
    }
  }

  final List<Widget> _pages = [
    const HomePage(),
    ChatHome(),
    const NotesPage(),
    const ProfilePage(),
    const EmployeeManagementPage(),
    const ComplainManagement(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AppLayout(
            child: _pages[_currentIndex],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.4,
                child: CustomBottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (v) {
                    print('Tapped index: $v');
                    _onTap(v);
                    setState(() {
                      _currentIndex = v;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
