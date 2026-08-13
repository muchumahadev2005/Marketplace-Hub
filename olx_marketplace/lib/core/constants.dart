// ─────────────────────────────────────────────
//  LAYOUT CONSTANTS  (spacing, radii, sizes)
// ─────────────────────────────────────────────

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
}

class AppRadius {
  AppRadius._();

  static const double card = 12;
  static const double chip = 6;
  static const double searchBar = 12;
  static const double circle = 999; // large enough for any circle
}

class AppDimensions {
  AppDimensions._();

  /// Diameter of category avatar circles
  static const double categoryCircle = 60;

  /// Image area height inside a Featured product card
  static const double featuredImageHeight = 132;

  /// Image area height inside a regular product card
  static const double productImageHeight = 112;

  /// Full height of each product card (image + info)
  static const double featuredCardHeight = 228;
  static const double productCardHeight = 208;

  /// Width of a product card (2 per row with 16 px side padding and 8 px gap)
  /// Computed at runtime via: (screenWidth - 32 - 8) / 2
  /// This value is just used as a named reference; actual calc is in the widget.
  static const double productCardGap = 8;
  static const double sidepadding = 16;

  /// Height of the bottom navigation bar
  static const double bottomNavHeight = 64;
}
