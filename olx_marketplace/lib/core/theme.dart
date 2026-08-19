import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
//  COLOUR PALETTE  (from Figma reference)
// ─────────────────────────────────────────────
class AppColors {
  AppColors._();

  /// OLX brand blue  #3D5AF1
  static const Color primary = Color(0xFF3D5AF1);

  /// Lighter tint of primary used in gradients
  static const Color primaryLight = Color(0xFF6B8EFF);

  /// Yellow badge used for "Featured" label
  static const Color featuredBadge = Color(0xFFF5C518);

  /// App / page background
  static const Color background = Color(0xFFF5F5F5);

  /// Card / surface background
  static const Color cardBg = Colors.white;

  /// Main text – near black
  static const Color textPrimary = Color(0xFF1A1A2E);

  /// Secondary text – medium grey
  static const Color textSecondary = Color(0xFF666666);

  /// Muted text – used for nav icons, placeholders
  static const Color textMuted = Color(0xFF9E9E9E);

  /// Dividers and borders
  static const Color divider = Color(0xFFE0E0E0);

  /// Search bar and image placeholder fill
  static const Color searchBarBg = Color(0xFFF0F0F0);
}

// ─────────────────────────────────────────────
//  TEXT STYLES   (Poppins via google_fonts)
// ─────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  // -- Section headers
  static final TextStyle sectionTitle = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final TextStyle sectionCount = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static final TextStyle seeMore = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  // -- Product card
  static final TextStyle productTitle = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.3,  // explicit: prevents overflow from Poppins default ~1.5x
  );

  static final TextStyle productPrice = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static final TextStyle productMeta = GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.3,
  );
  // -- Featured badge on product image
  static final TextStyle featuredLabel = GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // -- Category circle label
  static final TextStyle categoryLabel = GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.3,  // prevents 2-line text from overflowing the 96 px category row
  );

  // -- AppBar: category dropdown chip text
  static final TextStyle dropdownText = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // -- Location bar
  static final TextStyle locationText = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // -- Bottom navigation labels
  static TextStyle navLabel({required bool selected}) => GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: selected ? AppColors.primary : AppColors.textMuted,
      );
}

// ─────────────────────────────────────────────
//  SHADOWS
// ─────────────────────────────────────────────
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> appBar = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> bottomNav = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 12,
      offset: Offset(0, -2),
    ),
  ];
}

// ─────────────────────────────────────────────
//  MATERIALAPP THEME
// ─────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      // Apply Poppins globally via textTheme
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      // Remove default splash / highlight on taps
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }
}
