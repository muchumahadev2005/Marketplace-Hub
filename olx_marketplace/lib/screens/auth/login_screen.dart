import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';
import '../../widgets/auth/auth_logo_badge.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/auth_primary_button.dart';
import '../../widgets/auth/google_sign_in_button.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    AuthService.instance.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (AuthService.instance.isAuthenticated && mounted) {
      // Pop back to root — ListenableBuilder in main.dart will show HomeScreen
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    AuthService.instance.removeListener(_onAuthChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateCanSubmit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final emailValid = email.isNotEmpty &&
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    final passwordValid = password.length >= 6;
    final valid = emailValid && passwordValid;
    if (valid != _canSubmit) {
      setState(() => _canSubmit = valid);
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isEmailLoading = true;
    });

    final success = await AuthService.instance.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      setState(() {
        _isEmailLoading = false;
      });
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AuthService.instance.errorMessage ?? 'Invalid email or password'),
          ),
        );
      }
      // On success, _onAuthChanged listener handles navigation automatically
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isGoogleLoading = true;
    });

    final success = await AuthService.instance.loginWithGoogle();

    if (mounted) {
      setState(() {
        _isGoogleLoading = false;
      });
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AuthService.instance.errorMessage ?? 'Google Sign-In failed'),
          ),
        );
      }
      // On success, _onAuthChanged listener handles navigation automatically
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Logo Badge
                const AuthLogoBadge(size: 72),
                const SizedBox(height: 20),

                // 2. Heading & Subtitle
                Text(
                  'Login',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Login to continue using the app',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFFA0A5BA),
                  ),
                ),

                const SizedBox(height: 28),

                // 3. Email Field
                Align(
                  alignment: Alignment.centerLeft,
                  child: AuthTextField(
                    label: 'Email',
                    hintText: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => _updateCanSubmit(),
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

                // 4. Password Field
                Align(
                  alignment: Alignment.centerLeft,
                  child: AuthTextField(
                    label: 'Password',
                    hintText: 'Enter password',
                    controller: _passwordController,
                    isPassword: true,
                    onChanged: (_) => _updateCanSubmit(),
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

                const SizedBox(height: 10),

                // 5. Forgot Password link
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8C91A5),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // 6. Login Button
                AuthPrimaryButton(
                  text: 'Login',
                  isEnabled: _canSubmit,
                  isLoading: _isEmailLoading,
                  onPressed: _handleLogin,
                ),

                const SizedBox(height: 24),

                // 7. Or Login with divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xFFE8ECEF))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Text(
                        'Or Login with',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFFA0A5BA),
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: Color(0xFFE8ECEF))),
                  ],
                ),

                const SizedBox(height: 20),

                // 8. Single Google Sign-In Button (Exact Official 4-Color Google Logo)
                GoogleSignInButton(
                  isLoading: _isGoogleLoading,
                  onPressed: _handleGoogleLogin,
                ),

                const SizedBox(height: 32),

                // 9. Don't have an account? Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Register',
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
