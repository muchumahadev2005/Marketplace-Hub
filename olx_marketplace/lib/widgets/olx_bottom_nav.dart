import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/constants.dart';

// ─────────────────────────────────────────────
//  OLX BOTTOM NAVIGATION BAR
//
//  Returns a BottomAppBar with a circular notch
//  for the floating "SELL" button.
//
//  Tabs:  HOME · CHATS · [SELL FAB] · MY ADS · ACCOUNT
//
//  Usage in Scaffold:
//    floatingActionButton: _buildSellFab(),
//    floatingActionButtonLocation:
//        FloatingActionButtonLocation.centerDocked,
//    bottomNavigationBar: OlxBottomNav(
//      currentIndex: _selectedIndex,
//      onTap: (i) => setState(() => _selectedIndex = i),
//    ),
// ─────────────────────────────────────────────

class OlxBottomNav extends StatelessWidget {
  /// Index of the currently selected tab.
  /// 0 = HOME, 1 = CHATS, 2 = SELL (FAB), 3 = MY ADS, 4 = ACCOUNT
  final int currentIndex;

  /// Called whenever the user taps a tab item.
  final ValueChanged<int> onTap;

  const OlxBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      // Creates the circular cutout for the FAB
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      // Disable Material 3 primary-colour surface tint.
      // Without this, M3 overlays a blue hue on the white bar which makes
      // grey (unselected) icons look incorrectly selected.
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shadowColor: const Color(0x1A000000),
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: AppDimensions.bottomNavHeight,
        child: Row(
          children: [
            // HOME (index 0)
            _NavItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: 'HOME',
              selected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            // CHATS (index 1)
            _NavItem(
              icon: Icons.chat_bubble_outline,
              selectedIcon: Icons.chat_bubble,
              label: 'CHATS',
              selected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            // Centre space — "SELL" label sits below the FAB here
            _SellPlaceholder(selected: currentIndex == 2),
            // MY ADS (index 3)
            _NavItem(
              icon: Icons.favorite_border,
              selectedIcon: Icons.favorite,
              label: 'MY ADS',
              selected: currentIndex == 3,
              onTap: () => onTap(3),
            ),
            // ACCOUNT (index 4)
            _NavItem(
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              label: 'ACCOUNT',
              selected: currentIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

// ── A single nav item (icon + label) ─────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textMuted;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? selectedIcon : icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.navLabel(selected: selected),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Centre placeholder — shows "SELL" label under the FAB ──
class _SellPlaceholder extends StatelessWidget {
  final bool selected;

  const _SellPlaceholder({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // FAB sits above this area; just show the SELL label
          Text(
            'SELL',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.primary : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
