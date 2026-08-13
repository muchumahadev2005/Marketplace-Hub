import 'package:flutter/material.dart';
import '../core/theme.dart';

class SortScreen extends StatelessWidget {
  final String selectedSort;
  final ValueChanged<String> onSortSelected;

  const SortScreen({
    super.key,
    required this.selectedSort,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> sortOptions = [
      'Most relevant',
      'Newly listed',
      'Close to me',
      'Lowest price',
      'Highest price',
    ];

    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sort By',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 20, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.divider),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortOptions.length,
            itemBuilder: (context, index) {
              final option = sortOptions[index];
              final isSelected = option == selectedSort;
              return ListTile(
                title: Text(
                  option,
                  style: AppTextStyles.productTitle.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary, size: 20) : null,
                onTap: () {
                  onSortSelected(option);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
