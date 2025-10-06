import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mahaweli_admin_system/services/auth/components/status_row.dart';
import 'package:mahaweli_admin_system/services/auth/login.dart';

class RegistrationPendingPage extends StatelessWidget {
  final String email;
  final String department;

  const RegistrationPendingPage({
    super.key,
    required this.email,
    required this.department,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2D1A4A),
                  Color(0xFF4A2C80),
                ],
              ),
            ),
          ),

          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.deepPurple,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Iconsax.tick_circle,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                
                    Text(
                      'Registration Submitted!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          StatusRow(icon: Iconsax.sms, label: 'Email', value: email,),
                          const Divider(height: 32, color: Colors.white30),
                          StatusRow(label: 'Department',value: department,icon: Iconsax.building_3),
                          const Divider(height: 32, color: Colors.white30),
                          const StatusRow(label: 'Status', value: 'Pending Approval', icon: Iconsax.clock),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                
                    Text(
                      'Your registration is under review\nYou will receive an email once approved',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PurpleLoginPage()));
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'RETURN TO LOGIN',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}