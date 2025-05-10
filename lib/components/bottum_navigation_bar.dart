// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import 'package:flutter/material.dart';

// class CustomBottomNavigationBar extends StatelessWidget {
//   const CustomBottomNavigationBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return CurvedNavigationBar(
//       height: 50,
//       backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//       color: const Color.fromARGB(255, 50, 50, 50),
//       buttonBackgroundColor: const Color.fromARGB(255, 70, 70, 70),
//       animationCurve: Curves.easeInOut,
//       animationDuration: const Duration(milliseconds: 500),
//       items: const <Widget>[
//         Icon(Icons.home_rounded, size: 30, color: Colors.white),
//         Icon(Icons.chat_bubble, size: 30, color: Colors.white),
//         Icon(Icons.summarize_rounded, size: 30, color: Colors.white),
//         Icon(Icons.person_rounded, size: 30, color: Colors.white),
//       ],
//       onTap: (index) {
//         debugPrint("Selected Index: $index");
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    debugPrint("Selected Index: $index");
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 65,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 3,
      indicatorColor: const Color(0xFFE3D7FF), // Soft purple highlight when selected
      shadowColor: Colors.grey.withOpacity(0.2),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline_rounded),
          selectedIcon: Icon(Icons.chat_bubble_rounded),
          label: 'Chat',
        ),
        NavigationDestination(
          icon: Icon(Icons.summarize_outlined),
          selectedIcon: Icon(Icons.summarize_rounded),
          label: 'Reports',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}

