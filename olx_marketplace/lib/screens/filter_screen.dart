import 'package:flutter/material.dart';
import '../core/theme.dart';

class FilterScreen extends StatefulWidget {
  final List<String> initialFilters;

  const FilterScreen({
    super.key,
    required this.initialFilters,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // Custom states
  RangeValues _priceRange = const RangeValues(10000, 800000);
  bool _conditionNew = true;
  bool _conditionUsed = true;
  String _selectedRegion = 'Punjab';

  void _applyFilters() {
    // Collect updated mock filters based on states
    final List<String> updated = [];
    if (_conditionNew) updated.add('New');
    if (_conditionUsed) updated.add('Used');
    updated.add(_selectedRegion);
    updated.add('Price: < ${(_priceRange.end / 1000).round()}k');

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Filters',
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _conditionNew = false;
                _conditionUsed = false;
                _priceRange = const RangeValues(10000, 800000);
              });
            },
            child: const Text('Reset All', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.divider,
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Section
            _buildSectionHeader('Category'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.searchBarBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Mobiles -> Mobile Phones', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  Icon(Icons.keyboard_arrow_right, size: 18),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Price Range Section
            _buildSectionHeader('Price Range'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Min Price',
                      hintText: 'Rs ${(_priceRange.start).round()}',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Max Price',
                      hintText: 'Rs ${(_priceRange.end).round()}',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: _priceRange,
              min: 1000,
              max: 1000000,
              divisions: 100,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.divider,
              labels: RangeLabels(
                'Rs ${(_priceRange.start).round()}',
                'Rs ${(_priceRange.end).round()}',
              ),
              onChanged: (values) {
                setState(() {
                  _priceRange = values;
                });
              },
            ),
            const SizedBox(height: 24),

            // Condition Section
            _buildSectionHeader('Condition'),
            CheckboxListTile(
              title: const Text('New', style: TextStyle(fontSize: 13)),
              value: _conditionNew,
              activeColor: AppColors.primary,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) {
                setState(() {
                  _conditionNew = val ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Used', style: TextStyle(fontSize: 13)),
              value: _conditionUsed,
              activeColor: AppColors.primary,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) {
                setState(() {
                  _conditionUsed = val ?? false;
                });
              },
            ),
            const SizedBox(height: 24),

            // Location/Region Section
            _buildSectionHeader('Region'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedRegion,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: ['Punjab', 'Sindh', 'KPK', 'Balochistan'].map((r) {
                return DropdownMenuItem(
                  value: r,
                  child: Text(r, style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedRegion = val;
                  });
                }
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _applyFilters,
            child: const Text(
              'Apply Filters',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.sectionTitle.copyWith(fontSize: 14),
    );
  }
}
