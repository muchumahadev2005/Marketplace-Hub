import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../models/ad.dart';
import '../services/ad_repository.dart';
import '../services/auth_service.dart';
import '../services/favorite_service.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';
import 'map_view_screen.dart';
import 'promote_ad_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Ad product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = FavoriteService.instance.isFavorite(widget.product.id);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Collapsible AppBar with Product Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.8),
                child: IconButton(
                  icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(
                      text: 'Check out this ${product.title} on OLX: ${product.formattedPrice} in ${product.location}',
                    ));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ad details copied to clipboard!')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.8),
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : AppColors.textPrimary,
                  ),
                  onPressed: () async {
                    final newFav = await FavoriteService.instance.toggleFavorite(product.id);
                    setState(() {
                      _isFavorite = newFav;
                    });
                    AdRepository.instance.toggleFavorite(product.id);
                  },
                ),
              ),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  if (product.isFeatured)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.featuredBadge,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Featured',
                          style: AppTextStyles.featuredLabel.copyWith(fontSize: 11),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Details content
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price
                    Text(
                      product.formattedPrice,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Title
                    Text(
                      product.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Meta row
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(product.location, style: AppTextStyles.productMeta, overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.access_time, color: AppColors.textSecondary, size: 14),
                        const SizedBox(width: 4),
                        Text(product.date, style: AppTextStyles.productMeta),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Location Card with View on Map Button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.searchBarBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.place, color: AppColors.primary, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Item Location',
                                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                                Text(
                                  product.location,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            icon: const Icon(Icons.map, size: 14),
                            label: const Text(
                              'View on Map',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MapViewScreen(
                                    title: product.title,
                                    locationName: product.location,
                                    latitude: product.latitude ?? 31.5204,
                                    longitude: product.longitude ?? 74.3587,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 32, thickness: 1, color: AppColors.divider),
                    
                    // Product specifics
                    Text('Details', style: AppTextStyles.sectionTitle.copyWith(fontSize: 15)),
                    const SizedBox(height: 12),
                    _buildDetailRow('Condition', product.condition),
                    _buildDetailRow('Rating', product.rating),
                    _buildDetailRow('Category', product.category),
                    if (product.brand != null && product.brand!.isNotEmpty)
                      _buildDetailRow('Brand', product.brand!),
                    if (product.model != null && product.model!.isNotEmpty)
                      _buildDetailRow('Model', product.model!),
                    if (product.reasonForSelling != null && product.reasonForSelling!.isNotEmpty)
                      _buildDetailRow('Reason for Selling', product.reasonForSelling!),

                    const Divider(height: 32, thickness: 1, color: AppColors.divider),

                    // Description
                    Text('Description', style: AppTextStyles.sectionTitle.copyWith(fontSize: 15)),
                    const SizedBox(height: 8),
                    Text(
                      product.description.isNotEmpty
                          ? product.description
                          : 'No description provided.',
                      style: AppTextStyles.productMeta.copyWith(fontSize: 13, height: 1.5, color: AppColors.textPrimary),
                    ),

                    if (product.additionalDetails != null && product.additionalDetails!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text('Additional Details', style: AppTextStyles.sectionTitle.copyWith(fontSize: 14)),
                      const SizedBox(height: 6),
                      Text(
                        product.additionalDetails!,
                        style: AppTextStyles.productMeta.copyWith(fontSize: 12, height: 1.4),
                      ),
                    ],

                    const Divider(height: 32, thickness: 1, color: AppColors.divider),

                    // Seller info
                    Text('Seller Profile', style: AppTextStyles.sectionTitle.copyWith(fontSize: 15)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(product.sellerImage),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.sellerName, style: AppTextStyles.sectionTitle.copyWith(fontSize: 13)),
                                Text('Member since 2022', style: AppTextStyles.productMeta),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: (AuthService.instance.currentUser != null &&
                (product.userId == AuthService.instance.currentUser!.id ||
                 product.sellerName == AuthService.instance.currentUser!.name))
            ? SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.campaign, color: Colors.white, size: 20),
                  label: const Text('Promote This Ad ⭐', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PromoteAdScreen(ad: product),
                      ),
                    );
                  },
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.call, color: AppColors.primary, size: 18),
                        label: const Text('Call Seller', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Phone: ${product.sellerPhone}')),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
                        label: const Text('Chat Seller', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Starting chat...'), duration: Duration(milliseconds: 1500)),
                          );
                          final room = await ChatService.instance.getOrCreateRoom(product.id);
                          if (room != null) {
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    chatId: room.id,
                                    userName: room.otherUserName,
                                    productName: room.adTitle,
                                  ),
                                ),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Could not start chat. Are you logged in?')),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.productMeta.copyWith(fontSize: 13)),
          Text(value, style: AppTextStyles.productMeta.copyWith(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
