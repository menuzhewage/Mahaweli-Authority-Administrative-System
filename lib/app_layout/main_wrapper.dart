import 'package:flutter/material.dart';
import 'package:mahaweli_admin_system/components/bottum_navigation_bar.dart';
import 'package:mahaweli_admin_system/screens/employee_profiles.dart';
import 'package:mahaweli_admin_system/screens/reports_page.dart';

import '../screens/chat_page.dart';
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
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _pages = [
    const HomePage(),
    const ChatPage(),
    const UserReportsPage(userId: '',),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppLayout(
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: _currentIndex, onTap: _onTap),
    );
  }
}