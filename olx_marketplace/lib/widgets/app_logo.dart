import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

/// Reusable MHB Brand Logo widget matching the Marketplace Hub brand identity.
class AppLogo extends StatelessWidget {
  final double fontSize;
  final Color? color;
  final bool showBadge;
  final bool isDarkBackground;

  const AppLogo({
    super.key,
    this.fontSize = 24,
    this.color,
    this.showBadge = false,
    this.isDarkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? (isDarkBackground ? Colors.white : AppColors.primary);

    Widget logoText = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          'M',
          style: GoogleFonts.poppins(
            fontSize: fontSize * 1.25,
            fontWeight: FontWeight.w900,
            color: baseColor,
            height: 1.0,
            letterSpacing: -1.0,
          ),
        ),
        Text(
          'HB',
          style: GoogleFonts.poppins(
            fontSize: fontSize * 0.92,
            fontWeight: FontWeight.w800,
            color: baseColor,
            height: 1.0,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );

    if (showBadge) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: fontSize * 0.5,
          vertical: fontSize * 0.3,
        ),
        decoration: BoxDecoration(
          color: isDarkBackground ? Colors.white : AppColors.primary,
          borderRadius: BorderRadius.circular(fontSize * 0.35),
          boxShadow: [
            if (!isDarkBackground)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: AppLogo(
          fontSize: fontSize,
          color: isDarkBackground ? AppColors.primary : Colors.white,
          showBadge: false,
        ),
      );
    }

    return logoText;
  }
}
