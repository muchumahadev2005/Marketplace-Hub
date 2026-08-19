import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';
import '../models/ad.dart';
import '../services/ad_repository.dart';
import 'post_ad_screen.dart';
import 'promote_ad_screen.dart';

class MyAdsScreen extends StatefulWidget {
  const MyAdsScreen({super.key});

  @override
  State<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen> {
  @override
  void initState() {
    super.initState();
    AdRepository.instance.loadMyAds();
  }

  void _showDeleteConfirmation(BuildContext context, Ad ad) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Delete this ad?',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'This action cannot be undone.',
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () async {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final success = await AdRepository.instance.deleteAd(ad.id);
                if (mounted) {
                  navigator.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Ad deleted successfully' : 'Failed to delete ad'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmMarkAsSold(BuildContext context, Ad ad) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Mark as Sold?',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'This ad will be moved to the Sold tab and removed from active buyer listings.',
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () async {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final success = await AdRepository.instance.markAsSold(ad.id);
                if (mounted) {
                  navigator.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Ad marked as Sold' : 'Failed to update status'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text(
                'Confirm',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'My Ads',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(text: 'ACTIVE'),
              Tab(text: 'SOLD'),
              Tab(text: 'PENDING'),
            ],
          ),
        ),
        body: ListenableBuilder(
          listenable: AdRepository.instance,
          builder: (context, _) {
            final activeAds = AdRepository.instance.getMyActiveAds();
            final soldAds = AdRepository.instance.getMySoldAds();
            final pendingAds = AdRepository.instance.getMyPendingAds();

            return TabBarView(
              children: [
                _buildAdsList(context, activeAds, 'active'),
                _buildAdsList(context, soldAds, 'sold'),
                _buildAdsList(context, pendingAds, 'pending'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAdsList(BuildContext context, List<Ad> ads, String targetStatus) {
    if (ads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              'No ${targetStatus.toUpperCase()} ads found',
              style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: ads.length,
      itemBuilder: (context, index) {
        final ad = ads[index];

        Color statusColor;
        String statusLabel;

        switch (ad.status) {
          case 'active':
            statusColor = Colors.green;
            statusLabel = 'ACTIVE';
            break;
          case 'sold':
            statusColor = Colors.grey;
            statusLabel = 'SOLD';
            break;
          case 'pending':
          default:
            statusColor = Colors.orange;
            statusLabel = 'PENDING';
            break;
        }

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: ad.imageUrl,
                        width: 85,
                        height: 85,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          width: 85,
                          height: 85,
                          color: AppColors.searchBarBg,
                          child: const Icon(Icons.image_not_supported, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Text(ad.date, style: AppTextStyles.productMeta),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            ad.title,
                            style: AppTextStyles.productTitle.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ad.formattedPrice,
                            style: AppTextStyles.productPrice.copyWith(color: AppColors.primary),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${ad.condition}  •  ',
                                style: AppTextStyles.productMeta.copyWith(fontWeight: FontWeight.w500),
                              ),
                              Expanded(
                                child: Text(
                                  ad.location,
                                  style: AppTextStyles.productMeta,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20, color: AppColors.divider),
                
                // Action Buttons: Promote, Edit, Mark as Sold, Delete
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Promote Button (only if active)
                    if (ad.status == 'active') ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.campaign, size: 14, color: Colors.white),
                        label: Text(
                          ad.isFeatured ? 'Promoted ⭐' : 'Promote ⭐',
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PromoteAdScreen(ad: ad),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Edit Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 14, color: AppColors.primary),
                      label: Text(
                        'Edit',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostAdScreen(adToEdit: ad),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),

                    // Mark as Sold Button (only if active)
                    if (ad.status == 'active') ...[
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          side: BorderSide(color: Colors.green.shade700),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: Icon(Icons.check_circle_outline, size: 14, color: Colors.green.shade700),
                        label: Text(
                          'Mark as Sold',
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green.shade700),
                        ),
                        onPressed: () => _confirmMarkAsSold(context, ad),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Delete Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.delete_outline, size: 14, color: Colors.red),
                      label: Text(
                        'Delete',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.red),
                      ),
                      onPressed: () => _showDeleteConfirmation(context, ad),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
