import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../models/product.dart';

// ─────────────────────────────────────────────
//  CATEGORY CARD
//
//  Used in the "Browse Categories" horizontal row.
//  Layout:
//    ┌────────────────┐
//    │   (circle img) │
//    │    Category    │
//    │      Name      │
//    └────────────────┘
// ─────────────────────────────────────────────

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular avatar with network image
            Container(
              width: AppDimensions.categoryCircle,
              height: AppDimensions.categoryCircle,
              decoration: const BoxDecoration(
                color: AppColors.searchBarBg,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: category.imageUrl,
                  width: AppDimensions.categoryCircle,
                  height: AppDimensions.categoryCircle,
                  fit: BoxFit.cover,
                  // Grey shimmer while loading
                  placeholder: (context, url) => Container(
                    color: AppColors.searchBarBg,
                  ),
                  // Icon fallback if image fails to load
                  errorWidget: (context, url, error) => const Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.textMuted,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Category name (up to 2 lines, centered)
            Text(
              category.name,
              style: AppTextStyles.categoryLabel,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
