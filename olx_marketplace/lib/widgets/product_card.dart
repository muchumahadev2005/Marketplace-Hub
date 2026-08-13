import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../models/product.dart';

// ─────────────────────────────────────────────
//  PRODUCT CARD
//
//  Used in Featured, Mobile, Most Viewed,
//  MotorBikes sections.
//
//  Card layout:
//  ┌──────────────────────────────┐
//  │  [product image]         [♡] │  ← imageHeight (px)
//  │  [Featured]                  │  ← badge (optional)
//  ├──────────────────────────────┤
//  │  Title                       │
//  │  Rs 400,000                  │
//  │  New · 10/10                 │
//  │  Gulberg Phase 4...  22 Sep  │
//  └──────────────────────────────┘
// ─────────────────────────────────────────────

class ProductCard extends StatelessWidget {
  final Product product;

  /// Override image height — Featured section uses a taller image area.
  final double? imageHeight;

  const ProductCard({
    super.key,
    required this.product,
    this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    final double imgH = imageHeight ?? AppDimensions.productImageHeight;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image area ─────────────────────
          _ProductImage(product: product, imageHeight: imgH),

          // ── Info area ──────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  product.title,
                  style: AppTextStyles.productTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),

                // Price
                Text(
                  product.formattedPrice,
                  style: AppTextStyles.productPrice,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),

                // Condition · Rating
                Text(
                  '${product.condition} · ${product.rating}',
                  style: AppTextStyles.productMeta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),

                // Location + Date
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.location,
                        style: AppTextStyles.productMeta,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      product.date,
                      style: AppTextStyles.productMeta,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Private: image section with overlay widgets ──
class _ProductImage extends StatelessWidget {
  final Product product;
  final double imageHeight;

  const _ProductImage({
    required this.product,
    required this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Network image
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.card),
            topRight: Radius.circular(AppRadius.card),
          ),
          child: CachedNetworkImage(
            imageUrl: product.imageUrl,
            width: double.infinity,
            height: imageHeight,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: imageHeight,
              color: AppColors.searchBarBg,
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: imageHeight,
              color: AppColors.searchBarBg,
              child: const Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.textMuted,
                  size: 28,
                ),
              ),
            ),
          ),
        ),

        // Heart / favourite button — top right
        const Positioned(
          top: 8,
          right: 8,
          child: _HeartButton(),
        ),

        // "Featured" golden badge — bottom left (only when isFeatured)
        if (product.isFeatured)
          const Positioned(
            bottom: 8,
            left: 8,
            child: _FeaturedBadge(),
          ),
      ],
    );
  }
}

// ── Heart button (white circle + outlined heart) ──
class _HeartButton extends StatelessWidget {
  const _HeartButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.favorite_border,
          size: 15,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ── "Featured" golden label badge ──
class _FeaturedBadge extends StatelessWidget {
  const _FeaturedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.featuredBadge,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Text('Featured', style: AppTextStyles.featuredLabel),
    );
  }
}
