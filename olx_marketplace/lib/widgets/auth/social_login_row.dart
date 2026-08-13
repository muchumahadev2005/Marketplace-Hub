import 'package:flutter/material.dart';
import 'google_sign_in_button.dart';

// ─────────────────────────────────────────────
//  SINGLE GOOGLE SIGN-IN BUTTON WIDGET
//  (Only Google Sign-In with exact official Google symbol)
// ─────────────────────────────────────────────

class SocialLoginRow extends StatelessWidget {
  final VoidCallback onGooglePressed;

  const SocialLoginRow({
    super.key,
    required this.onGooglePressed,
    VoidCallback? onFacebookPressed,
    VoidCallback? onApplePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onGooglePressed,
        child: Container(
          width: 72,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFE8ECEF), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: CustomPaint(
              size: Size(24, 24),
              painter: GoogleLogoPainter(),
            ),
          ),
        ),
      ),
    );
  }
}
