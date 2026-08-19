import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';
import '../services/auth_service.dart';
import 'my_ads_screen.dart';
import 'chats_screen.dart';
import 'my_promotions_screen.dart';
import 'seller_dashboard_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Logout?',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to logout?',
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
                Navigator.pop(context); // close dialog
                await AuthService.instance.logout();
              },
              child: Text(
                'Logout',
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
    return ListenableBuilder(
      listenable: AuthService.instance,
      builder: (context, _) {
        final user = AuthService.instance.currentUser;
        final name = user?.name ?? 'Mahadev';
        final email = user?.email ?? 'mahadev@example.com';
        final avatar = user?.avatarUrl ??
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&q=80';

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'Profile',
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header Card
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundImage: NetworkImage(avatar),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: AppTextStyles.productMeta,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.primary),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Edit Profile',
                                style: AppTextStyles.seeMore.copyWith(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Main Menu Sections
                _buildMenuSection([
                  _buildMenuItem(Icons.dashboard_customize_outlined, 'Seller Dashboard ⭐', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SellerDashboardScreen()),
                    );
                  }),
                  _buildMenuItem(Icons.campaign_outlined, 'My Promotions ⭐', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyPromotionsScreen()),
                    );
                  }),
                  _buildMenuItem(Icons.inventory_2_outlined, 'My Ads', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyAdsScreen()),
                    );
                  }),
                  _buildMenuItem(Icons.favorite_border, 'Favorites', () {}),
                  _buildMenuItem(Icons.chat_bubble_outline, 'Messages', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatsScreen()),
                    );
                  }),
                  _buildMenuItem(Icons.notifications_none, 'Notifications', () {}),
                ]),
                const SizedBox(height: 12),

                _buildMenuSection([
                  _buildMenuItem(Icons.settings_outlined, 'Settings', () {}),
                  _buildMenuItem(Icons.help_outline, 'Help & Support', () {}),
                ]),
                const SizedBox(height: 12),

                // Logout Button Section
                Material(
                  color: Colors.white,
                  child: InkWell(
                    onTap: () => _showLogoutConfirmation(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      child: Row(
                        children: [
                          const Icon(Icons.logout, color: Colors.redAccent, size: 22),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Logout',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuSection(List<Widget> children) {
    return Container(
      color: Colors.white,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: ListTile(
            leading: Icon(icon, color: AppColors.textPrimary, size: 22),
            title: Text(
              title,
              style: AppTextStyles.productTitle.copyWith(fontSize: 14),
            ),
            trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
            onTap: onTap,
          ),
        ),
        const Divider(height: 1, indent: 56, color: AppColors.divider),
      ],
    );
  }
}
