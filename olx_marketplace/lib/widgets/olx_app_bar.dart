import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'app_logo.dart';

// ─────────────────────────────────────────────
//  OLX APP BAR
//
//  Matches the Figma design:
//    [OLX logo]  [Accessories ▾]  ...  [🔍] [🔔]
// ─────────────────────────────────────────────

class OlxAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onCategoryTap;
  final VoidCallback? onSearchTap;

  const OlxAppBar({
    super.key,
    this.onCategoryTap,
    this.onSearchTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

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
          const AppLogo(fontSize: 22),
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
