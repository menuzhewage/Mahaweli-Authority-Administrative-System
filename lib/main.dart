import 'package:flutter/material.dart';
import 'package:mahaweli_admin_system/screens/homepage.dart';
import 'package:mahaweli_admin_system/screens/login.dart';
import 'package:mahaweli_admin_system/screens/leavehandler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: Leavehandler(),
    );
  }
}
