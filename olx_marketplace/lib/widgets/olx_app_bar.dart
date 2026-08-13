import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

// ─────────────────────────────────────────────
//  OLX APP BAR
//
//  Matches the Figma design:
//    [OLX logo]  [Accessories ▾]  ...  [🔍] [🔔]
// ─────────────────────────────────────────────

class OlxAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onCategoryTap;

  const OlxAppBar({
    super.key,
    this.onSearchTap,
    this.onCategoryTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black12,
      titleSpacing: 16,
      // Left side: OLX logo + category dropdown
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _OlxLogo(),
          const SizedBox(width: 10),
          _CategoryDropdown(onTap: onCategoryTap),
        ],
      ),
      // Right side: search + notification icons
      actions: [
        IconButton(
          onPressed: onSearchTap ?? () {},
          icon: const Icon(Icons.search, size: 22),
          color: AppColors.textPrimary,
          splashRadius: 20,
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined, size: 22),
          color: AppColors.textPrimary,
          splashRadius: 20,
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// ── OLX Logo ─────────────────────────────────
// Reproduces the "o|lx" logo: a blue circle (with white hole = letter "O")
// followed by "lx" in bold blue Poppins.
class _OlxLogo extends StatelessWidget {
  const _OlxLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // The "O": blue circle with white circle inside
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 11,
              height: 11,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(width: 2),
        // "lx" text
        Text(
          'lx',
          style: GoogleFonts.poppins(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

// ── Category Dropdown Chip ────────────────────
// Rounded pill showing the selected category filter.
class _CategoryDropdown extends StatelessWidget {
  final VoidCallback? onTap;

  const _CategoryDropdown({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Accessories', style: AppTextStyles.dropdownText),
            const SizedBox(width: 3),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 15,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
