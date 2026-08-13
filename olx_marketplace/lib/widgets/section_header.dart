import 'package:flutter/material.dart';
import '../core/theme.dart';

// ─────────────────────────────────────────────
//  SECTION HEADER
//
//  Row shown at the top of every home-screen section:
//    Featured  10+           See more
// ─────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  /// Main section title, e.g. "Featured"
  final String title;

  /// Optional count badge, e.g. "10+"
  final String? count;

  /// Called when "See more" is tapped (stub in Phase 1)
  final VoidCallback? onSeeMore;

  const SectionHeader({
    super.key,
    required this.title,
    this.count,
    this.onSeeMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          Text(title, style: AppTextStyles.sectionTitle),

          // Count badge (e.g. " 10+")
          if (count != null) ...[
            const SizedBox(width: 5),
            Text(count!, style: AppTextStyles.sectionCount),
          ],

          const Spacer(),

          // "See more" link
          GestureDetector(
            onTap: onSeeMore ?? () {},
            child: Padding(
              // Extra tap area without visual padding
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Text('See more', style: AppTextStyles.seeMore),
            ),
          ),
        ],
      ),
    );
  }
}
