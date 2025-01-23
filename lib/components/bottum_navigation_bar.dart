import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class BottomNavigationBarExample extends StatelessWidget {
  const BottomNavigationBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      height: 50,
      backgroundColor: const Color.fromARGB(255, 25, 25, 25),
      color: const Color.fromARGB(255, 50, 50, 50),
      buttonBackgroundColor: const Color.fromARGB(255, 70, 70, 70),
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 500),
      items: const <Widget>[
        Icon(Icons.home_rounded, size: 30, color: Colors.white),
        Icon(Icons.chat_bubble, size: 30, color: Colors.white),
        Icon(Icons.summarize_rounded, size: 30, color: Colors.white),
        Icon(Icons.person_rounded, size: 30, color: Colors.white),
      ],
      onTap: (index) {
        debugPrint("Selected Index: $index");
      },
    );
  }
}
