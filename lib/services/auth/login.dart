import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mahaweli_admin_system/app_layout/main_wrapper.dart';
import 'package:mahaweli_admin_system/queue_user.dart';
import 'package:mahaweli_admin_system/services/auth/register.dart';
import 'package:mahaweli_admin_system/services/user_service.dart';
import 'dart:html' as html;

class PurpleLoginPage extends StatefulWidget {
  const PurpleLoginPage({super.key});

  @override
  State<PurpleLoginPage> createState() => _PurpleLoginPageState();
}

class _PurpleLoginPageState extends State<PurpleLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ShapeBorder _loginCardShape = const ContinuousRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(60),
      bottomRight: Radius.circular(60),
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(20),
    ),
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadRememberedUser();
    // UserService.getCurrentUserLeaveBlanace();
  }

  void _loadRememberedUser() {
    // Check if rememberMe is enabled
    final remembered = html.window.localStorage['rememberMe'] == 'true';

    if (remembered) {
      _emailController.text = html.window.localStorage['email'] ?? '';
      // Note: For security, we're NOT storing the password in localStorage
    }

    setState(() {
      _rememberMe = remembered;
    });
  }

  Future<void> _signInWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (_rememberMe) {
        html.window.localStorage['rememberMe'] = 'true';
        html.window.localStorage['email'] = _emailController.text.trim();
      } else {
        html.window.localStorage.remove('rememberMe');
        html.window.localStorage.remove('email');
      }

      await UserService.getCurrentUserRole();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainWrapper(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Login failed. Please try again.";

      if (e.code == 'user-not-found') {
        errorMessage = "No user found with this email.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password.";
      } else if (e.code == 'user-disabled') {
        errorMessage = "This account has been disabled.";
      } else if (e.code == 'too-many-requests') {
        errorMessage = "Too many attempts. Try again later.";
      }

      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An unexpected error occurred",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      Fluttertoast.showToast(
        msg: "Please enter a valid email address",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      Fluttertoast.showToast(
        msg: "Password reset email sent",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to send reset email",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

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
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: Image.asset(
                          '/images/logo_mahaweli.png',
                          width: 120,
                          height: 120,
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
                  SizedBox(
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
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    fillColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (states) => Colors.deepPurple,
                                    ),
                                  ),
                                  Text(
                                    'Remember me',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    // onPressed: (){},
                                    onPressed:
                                        _isLoading ? null : _resetPassword,
                                    child: Text(
                                      'Forgot Password?',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
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
                                  // onPressed: (){},
                                  onPressed: _isLoading
                                      ? null
                                      : _signInWithEmailAndPassword,
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
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              GestureDetector(
                                child: const Text('Sign up'),
                                onTap: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const RegistrationFlow()));
                                },
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
