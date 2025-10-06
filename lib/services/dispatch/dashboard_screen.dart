// screens/dashboard_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mahaweli_admin_system/app_layout/app_layout.dart';
import 'package:mahaweli_admin_system/providers.dart';
import 'package:provider/provider.dart';
import './view_dispatch_screen.dart';
import 'dispatc_for_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {


  final Map<Type, String> _pageToItemMap = {
    DispatchFormScreen: "Dispatch Form Screen",

  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dispatch Management',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWelcomeCard(context),
            SizedBox(height: 30),
            _buildActionButton(
              context: context,
              icon: Iconsax.add,
              label: 'Create New Dispatch',
              onPressed: () {
                final navigationProvider =
                      Provider.of<NavigationProvider>(context, listen: false);
                  navigationProvider.updateCurrentIndex('Dispatch Form Screen');
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Iconsax.document_favorite, size: 48, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Welcome, ${user?.email ?? 'User'}!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Manage your dispatch letters efficiently',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
