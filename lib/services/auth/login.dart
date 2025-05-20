import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PurpleLoginPage extends StatefulWidget {
  const PurpleLoginPage({super.key});

  @override
  State<PurpleLoginPage> createState() => _PurpleLoginPageState();
}

class _PurpleLoginPageState extends State<PurpleLoginPage> {
  final _formKey = GlobalKey<FormState>();
  // final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Unique card shape
  final ShapeBorder _loginCardShape = const ContinuousRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(60),
      bottomRight: Radius.circular(60),
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(20),
    ),
  );

  @override
  // void dispose() {
  //   _emailController.dispose();
  //   _passwordController.dispose();
  //   super.dispose();
  // }

  // Future<void> _signIn() async {
  //   if (!_formKey.currentState!.validate()) return;
    
  //   setState(() => _isLoading = true);
    
  //   try {
  //     await _auth.signInWithEmailAndPassword(
  //       email: _emailController.text.trim(),
  //       password: _passwordController.text.trim(),
  //     );
  //     // Success handled automatically by Firebase Auth listener
  //   } on FirebaseAuthException catch (e) {
  //     // Fluttertoast.showToast(
  //     //    msg: _getErrorMessage(e.code),
  //     //   toastLength: Toast.LENGTH_LONG,
  //     //   gravity: ToastGravity.BOTTOM,
  //     //   backgroundColor: Colors.deepPurple,
  //     //   textColor: Colors.white,
  //     // );
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }

  // String _getErrorMessage(String code) {
  //   switch (code) {
  //     case 'user-not-found':
  //       return 'No user found with this email';
  //     case 'wrong-password':
  //       return 'Incorrect password';
  //     case 'invalid-email':
  //       return 'Invalid email format';
  //     default:
  //       return 'Login failed. Please try again';
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient and floating elements
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
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and title
                  Column(
                    children: [
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
                          Iconsax.security_safe,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'MAHAWELI ADMIN',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Secure Access Portal',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Unique login card
                  Container(
                    width: MediaQuery.sizeOf(context).width * 0.5,
                    child: Material(
                      elevation: 8,
                      shape: _loginCardShape,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Email field
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: const Icon(Iconsax.sms),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.withOpacity(0.1),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                    
                              // Password field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Iconsax.lock_1),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Iconsax.eye_slash
                                          : Iconsax.eye,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    }),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.withOpacity(0.1),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                    
                              // Remember me & forgot password
                              Row(
                                children: [
                                  Checkbox(
                                    value: true,
                                    onChanged: (value) {},
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    fillColor: MaterialStateProperty.resolveWith<Color>(
                                      (states) => Colors.deepPurple,
                                    ),
                                  ),
                                  Text(
                                    'Remember me',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      // Add forgot password flow
                                    },
                                    child: Text(
                                      'Forgot Password?',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                    
                              // Login button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        )
                                      : Text(
                                          'SIGN IN',
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
                  ),

                  const SizedBox(height: 24),

                  // Footer
                  Text(
                    '© 2023 Mahaweli Authority | v2.0.0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.6),
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
}