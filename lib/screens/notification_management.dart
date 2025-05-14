import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mahaweli_admin_system/components/annual_task_card.dart';
import 'package:mahaweli_admin_system/components/bottum_navigation_bar.dart';
import 'package:mahaweli_admin_system/components/build_media_section_card.dart';

class NotificationManagement extends StatefulWidget {
  const NotificationManagement({super.key});

  @override
  _NotificationManagementState createState() => _NotificationManagementState();
}

class _NotificationManagementState extends State<NotificationManagement> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Management'),
      ),
      body: const Center(
        child: Text('Notification Management Screen'),
      ),
    );
  }
}