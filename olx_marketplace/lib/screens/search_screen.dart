import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'listing_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _recentSearches = [
    'iphone 12 pro max',
    'iphone 12 pro max',
  ];

  final List<Map<String, dynamic>> _popularCategories = [
    {'name': 'Mobiles', 'icon': Icons.phone_android},
    {'name': 'Vehicles', 'icon': Icons.directions_car},
    {'name': 'Property for sale', 'icon': Icons.home},
    {'name': 'Fashions and Beauty', 'icon': Icons.shopping_bag_outlined},
  ];

  void _onSearchSubmit(String query) {
    if (query.trim().isEmpty) return;
    
    // Save to recents
    setState(() {
      if (!_recentSearches.contains(query.trim())) {
        _recentSearches.insert(0, query.trim());
      }
    });

    // Navigate to listing screen with query
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListingScreen(searchQuery: query.trim()),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.searchBarBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.textMuted, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _onSearchSubmit,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Find Cars, Mobiles and more',
                    hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchController.clear();
                    });
                  },
                  child: const Icon(Icons.clear, color: AppColors.textSecondary, size: 18),
                ),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.divider,
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recent searches header
            if (_recentSearches.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Last search',
                      style: AppTextStyles.sectionTitle.copyWith(fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _recentSearches.clear();
                        });
                      },
                      child: Text(
                        'Clear all',
                        style: AppTextStyles.seeMore.copyWith(fontSize: 12, color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ),
              // Recent searches list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentSearches.length,
                itemBuilder: (context, index) {
                  final search = _recentSearches[index];
                  return ListTile(
                    leading: const Icon(Icons.history, color: AppColors.textMuted, size: 20),
                    title: Text(search, style: AppTextStyles.productTitle),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                      onPressed: () {
                        setState(() {
                          _recentSearches.removeAt(index);
                        });
                      },
                    ),
                    onTap: () {
                      _searchController.text = search;
                      _onSearchSubmit(search);
                    },
                  );
                },
              ),
            ],
            
            // Popular categories
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                'Popular Categories',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 14),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _popularCategories.length,
              itemBuilder: (context, index) {
                final cat = _popularCategories[index];
                return ListTile(
                  leading: Icon(cat['icon'], color: AppColors.textSecondary, size: 22),
                  title: Text(cat['name'], style: AppTextStyles.productTitle),
                  trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                  onTap: () {
                    _onSearchSubmit(cat['name']);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
