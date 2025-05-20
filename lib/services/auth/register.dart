import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mahaweli_admin_system/services/auth/login.dart';

class RegistrationFlow extends StatefulWidget {
  const RegistrationFlow({super.key});

  @override
  State<RegistrationFlow> createState() => _RegistrationFlowState();
}

class _RegistrationFlowState extends State<RegistrationFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final _formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>()];
  
  // Form data
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _department = '';
  String _role = '';
  String _employeeId = '';

  final List<String> _departments = [
    'Irrigation',
    'Agriculture',
    'Engineering',
    'Finance',
    'Administration',
    'Field Operations'
  ];

  final List<String> _roles = [
    'Manager',
    'Engineer',
    'Field Officer',
    'Accountant',
    'Technical Staff',
    'Administrator'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_formKeys[_currentPage].currentState!.validate()) {
      if (_currentPage < 2) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() => _currentPage++);
      } else {
        _submitRegistration();
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage--);
    }
  }

  Future<void> _submitRegistration() async {
    // Here you would normally send data to your backend/Firebase
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrationPendingPage(
          email: _email,
          department: _department,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = _currentPage == 2;

    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient (same as login)
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
            child: Stack(
              children: [
                Positioned(
                  top: -100,
                  left: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.deepPurple.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -150,
                  right: -150,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.purple.withOpacity(0.1),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(60.0),
              child: Column(
                children: [
                  // Progress indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(3, (index) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: index <= _currentPage 
                                    ? Colors.white 
                                    : Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
              
                  // Page content
                  Expanded(
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 0.5,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          // Page 1: Email & Password
                          _buildAccountSetupPage(theme),
                          
                          // Page 2: Department & Role
                          _buildDepartmentRolePage(theme),
                          
                          // Page 3: Employee ID
                          _buildEmployeeIdPage(theme),
                        ],
                      ),
                    ),
                  ),
              
                  // Navigation buttons
                  Container(
                    width: MediaQuery.sizeOf(context).width * 0.5,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          if (_currentPage > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _previousPage,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: const BorderSide(color: Colors.white),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'BACK',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          if (_currentPage > 0) const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton(
                              onPressed: _nextPage,
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                isLastPage ? 'SUBMIT' : 'NEXT',
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSetupPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: const Icon(
              Iconsax.profile_circle,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Account Setup',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Step 1 of 3 - Basic account information',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 40),

          // Form
          Form(
            key: _formKeys[0],
            child: Column(
              children: [
                // Email field
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Work Email',
                    prefixIcon: const Icon(Iconsax.sms),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Please enter your email';
                  //   }
                  //   if (!value.contains('@')) {
                  //     return 'Please enter a valid email';
                  //   }
                  //   return null;
                  // },
                  onSaved: (value) => _email = value ?? '',
                ),
                const SizedBox(height: 20),

                // Password field
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Iconsax.lock_1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Please enter a password';
                  //   }
                  //   if (value.length < 6) {
                  //     return 'Password must be at least 6 characters';
                  //   }
                  //   return null;
                  // },
                  onSaved: (value) => _password = value ?? '',
                ),
                const SizedBox(height: 20),

                // Confirm Password field
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Iconsax.lock_1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  // validator: (value) {
                  //   if (value != _password) {
                  //     return 'Passwords do not match';
                  //   }
                  //   return null;
                  // },
                  onSaved: (value) => _confirmPassword = value ?? '',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentRolePage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: const Icon(
              Iconsax.building_3,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Department & Role',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Step 2 of 3 - Organizational information',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 40),

          // Form
          Form(
            key: _formKeys[1],
            child: Column(
              children: [
                // Department dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Department',
                    prefixIcon: const Icon(Iconsax.building),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                  ),
                  items: _departments.map((dept) {
                    return DropdownMenuItem(
                      value: dept,
                      child: Text(dept),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your department';
                    }
                    return null;
                  },
                  onChanged: (value) => _department = value ?? '',
                ),
                const SizedBox(height: 20),

                // Role dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Role/Position',
                    prefixIcon: const Icon(Iconsax.user_square),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                  ),
                  items: _roles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your role';
                    }
                    return null;
                  },
                  onChanged: (value) => _role = value ?? '',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeIdPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: const Icon(
              Iconsax.profile_2user,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Employee Verification',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Step 3 of 3 - Official identification',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 40),

          // Form
          Form(
            key: _formKeys[2],
            child: Column(
              children: [
                // Employee ID field
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Employee ID',
                    prefixIcon: const Icon(Iconsax.card),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your employee ID';
                    }
                    return null;
                  },
                  onSaved: (value) => _employeeId = value ?? '',
                ),
                const SizedBox(height: 20),

                // Info text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.deepPurple.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    'Your registration will be reviewed by administration before account activation.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
          // Background with gradient (same as login)
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

          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: MediaQuery.sizeOf(context).width * 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated checkmark (would use Lottie in real app)
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
                
                    // Status card
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
                          _buildStatusRow('Email', email, Iconsax.sms),
                          const Divider(height: 32, color: Colors.white30),
                          _buildStatusRow('Department', department, Iconsax.building_3),
                          const Divider(height: 32, color: Colors.white30),
                          _buildStatusRow('Status', 'Pending Approval', Iconsax.clock),
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
                
                    // Action button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PurpleLoginPage()));
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

  Widget _buildStatusRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}