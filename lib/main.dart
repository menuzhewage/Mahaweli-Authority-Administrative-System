import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mahaweli_admin_system/app_layout/main_wrapper.dart';
import 'package:mahaweli_admin_system/screens/homepage.dart';
import 'package:mahaweli_admin_system/services/auth/login.dart';
import 'package:mahaweli_admin_system/services/auth/register.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: RegistrationFlow(),
    );
  }
}