import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
//  EXACT OFFICIAL GOOGLE LOGO & SIGN-IN BUTTON
// ─────────────────────────────────────────────

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFE8ECEF), width: 1.2),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF0066FF),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CustomPaint(
                    size: Size(22, 22),
                    painter: GoogleLogoPainter(),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Continue with Google',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// CustomPainter rendering the exact official 4-color Google 'G' logo:
/// Red (Top), Yellow (Left), Green (Bottom), Blue (Right & Bar)
class GoogleLogoPainter extends CustomPainter {
  const GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double strokeWidth = w * 0.22;

    final rect = Rect.fromCircle(
      center: Offset(cx, cy),
      radius: (w - strokeWidth) / 2,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // 1. Red Top Arc (from -45 deg to ~120 deg angle)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -0.785, 2.1, false, paint);

    // 2. Yellow Left Arc
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 1.315, 1.05, false, paint);

    // 3. Green Bottom Arc
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 2.365, 1.15, false, paint);

    // 4. Blue Right Arc
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.785, 1.0, false, paint);

    // 5. Blue Horizontal Crossbar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTRB(cx - 1, cy - strokeWidth / 2, w, cy + strokeWidth / 2),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
