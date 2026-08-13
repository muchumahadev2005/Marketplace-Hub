import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'listing_screen.dart';

class CategoryScreen extends StatelessWidget {
  final String categoryName;

  const CategoryScreen({
    super.key,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    // Subcategories mock list for Mobiles, since it's the primary figma flow
    final List<String> subcategories = [
      'Tablets',
      'Accessories',
      'Chargers',
      'Mobile Phones',
      'Smart Watches',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          categoryName,
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.divider,
            height: 1,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "See all in..." link
          ListTile(
            title: Text(
              'See all in $categoryName',
              style: AppTextStyles.productTitle.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: AppColors.primary, size: 20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListingScreen(
                    categoryName: categoryName,
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1, color: AppColors.divider),
          
          Expanded(
            child: ListView.separated(
              itemCount: subcategories.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, index) {
                final sub = subcategories[index];
                return ListTile(
                  title: Text(sub, style: AppTextStyles.productTitle),
                  trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListingScreen(
                          categoryName: '$categoryName - $sub',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
