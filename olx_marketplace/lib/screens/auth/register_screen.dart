import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';
import '../../widgets/auth/auth_logo_badge.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/auth_primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final usernameValid = _usernameController.text.trim().isNotEmpty;
    final email = _emailController.text.trim();
    final emailValid = email.isNotEmpty && email.contains('@') && email.contains('.');
    final password = _passwordController.text;
    final passwordValid = password.length >= 6;
    final confirmValid = password == _confirmPasswordController.text && password.isNotEmpty;

    return usernameValid && emailValid && passwordValid && confirmValid;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final success = await AuthService.instance.register(
      name: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      phone: '+91 9876543210',
      password: _passwordController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed. Try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F6FA),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF1A1A2E)),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Logo Badge
                const AuthLogoBadge(size: 72),
                const SizedBox(height: 20),

                // 2. Heading & Subtitle
                Text(
                  'Register',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter Your Personal Information',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFFA0A5BA),
                  ),
                ),

                const SizedBox(height: 28),

                // 3. Username
                Align(
                  alignment: Alignment.centerLeft,
                  child: AuthTextField(
                    label: 'Username',
                    hintText: 'Enter your name',
                    controller: _usernameController,
                    onChanged: (_) => setState(() {}),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Username is required';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // 4. Email
                Align(
                  alignment: Alignment.centerLeft,
                  child: AuthTextField(
                    label: 'Email',
                    hintText: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => setState(() {}),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter a valid email';
                      }
                      final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegExp.hasMatch(val.trim())) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // 5. Password
                Align(
                  alignment: Alignment.centerLeft,
                  child: AuthTextField(
                    label: 'Password',
                    hintText: 'Enter password',
                    controller: _passwordController,
                    isPassword: true,
                    onChanged: (_) => setState(() {}),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Password is required';
                      }
                      if (val.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // 6. Confirm Password
                Align(
                  alignment: Alignment.centerLeft,
                  child: AuthTextField(
                    label: 'Confirm password',
                    hintText: 'Enter confirm password',
                    controller: _confirmPasswordController,
                    isPassword: true,
                    onChanged: (_) => setState(() {}),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (val != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // 7. Register Button
                AuthPrimaryButton(
                  text: 'Register',
                  isEnabled: _isFormValid,
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                ),

                const SizedBox(height: 28),

                // 8. Already have an account? Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Login',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0066FF),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
