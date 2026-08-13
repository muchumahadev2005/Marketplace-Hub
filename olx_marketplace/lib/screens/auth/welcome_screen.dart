import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/auth/auth_logo_badge.dart';
import '../../widgets/auth/auth_primary_button.dart';
import '../../widgets/auth/welcome_illustration.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // 1. Top Store Vector Illustration (Screen 1 Design)
              SizedBox(
                height: screenHeight * 0.46,
                child: const WelcomeIllustration(),
              ),

              const SizedBox(height: 12),

              // 2. Content & Buttons Section (Tight, Natural Spacing)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo + Brand Name
                    Row(
                      children: [
                        const AuthLogoBadge(size: 36),
                        const SizedBox(width: 10),
                        Text(
                          'Localshop',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Title
                    Text(
                      'Everything you need is in\none place',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A2E),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      "Find your daily necessities at Brand. The world's largest fashion e-commerce has arrived in a mobile, shop now!",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF8C91A5),
                        height: 1.5,
                      ),
                    ),

                    // Normal tight spacing to buttons (No giant gap!)
                    const SizedBox(height: 24),

                    // Login Button (Primary Blue Pill)
                    AuthPrimaryButton(
                      text: 'Login',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Register Button (Outlined Pill)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF1A1A2E), width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        onPressed: () {
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
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
