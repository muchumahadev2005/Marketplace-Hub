import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../core/theme.dart';
import '../core/constants.dart';
import '../models/ad.dart';
import '../services/ad_repository.dart';
import '../services/location_service.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';
import 'filter_screen.dart';
import 'sort_screen.dart';

class ListingScreen extends StatefulWidget {
  final String? searchQuery;
  final String? categoryName;

  const ListingScreen({
    super.key,
    this.searchQuery,
    this.categoryName,
  });

  @override
  State<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends State<ListingScreen> {
  List<String> _filters = [];
  String _currentSort = 'Lowest price';
  bool _isGridView = true;
  List<Ad>? _searchResults;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filters = [
      LocationService.instance.selectedLocation.shortName,
      if (widget.categoryName != null) widget.categoryName!,
    ];
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      _fetchSearchResults();
    }
  }

  Future<void> _fetchSearchResults() async {
    setState(() {
      _isSearching = true;
    });
    final results = await AdRepository.instance.fetchSearch(widget.searchQuery!);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  List<Ad> _getFilteredProducts() {
    List<Ad> filtered;

    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      filtered = _searchResults ?? AdRepository.instance.searchAds(widget.searchQuery!);
    } else if (widget.categoryName != null && widget.categoryName != 'Featured' && widget.categoryName != 'Most Viewed') {
      filtered = AdRepository.instance.getAdsByCategory(widget.categoryName!);
    } else if (widget.categoryName == 'Featured') {
      filtered = AdRepository.instance.getFeaturedAds();
    } else {
      filtered = AdRepository.instance.getActiveAds();
    }

    // Filter by active location filter if present in _filters
    final selectedLocationChip = _filters.firstWhere(
      (f) => f == LocationService.instance.selectedLocation.shortName || f.contains('Lahore') || f.contains('Karachi'),
      orElse: () => '',
    );

    if (selectedLocationChip.isNotEmpty) {
      final locLower = selectedLocationChip.toLowerCase().split(',').first.trim();
      final locationMatches = filtered.where((ad) => ad.location.toLowerCase().contains(locLower)).toList();
      if (locationMatches.isNotEmpty) {
        filtered = locationMatches;
      }
    }

    List<Ad> list = List.from(filtered);

    // Sort simulated
    if (_currentSort == 'Lowest price') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (_currentSort == 'Highest price') {
      list.sort((a, b) => b.price.compareTo(a.price));
    }

    return list;
  }

  void _openFilter() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => FilterScreen(initialFilters: _filters),
      ),
    );
    if (result != null) {
      setState(() {
        _filters = result;
      });
    }
  }

  void _openSort() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SortScreen(
        selectedSort: _currentSort,
        onSortSelected: (sort) {
          setState(() {
            _currentSort = sort;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String queryTitle = widget.searchQuery ?? widget.categoryName ?? 'Marketplace';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Container(
          height: 38,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.searchBarBg,
            borderRadius: BorderRadius.circular(AppRadius.searchBar),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.textMuted, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  queryTitle,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_headline : Icons.grid_view,
              color: AppColors.textPrimary,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.swap_vert, color: AppColors.textPrimary, size: 20),
            onPressed: _openSort,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListenableBuilder(
        listenable: AdRepository.instance,
        builder: (context, _) {
          final products = _getFilteredProducts();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Row
              _buildFilterChipsRow(),
              const Divider(height: 1, color: AppColors.divider),
              
              // Results Header (count + sort summary)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'Found Results : ',
                        style: AppTextStyles.productMeta.copyWith(fontSize: 12),
                        children: [
                          TextSpan(
                            text: '${products.length} ads',
                            style: AppTextStyles.sectionTitle.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _openSort,
                      child: Row(
                        children: [
                          Text(
                            'Sort By : ',
                            style: AppTextStyles.productMeta.copyWith(fontSize: 12),
                          ),
                          Text(
                            _currentSort,
                            style: AppTextStyles.seeMore.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main Product Feed
              Expanded(
                child: _isSearching
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : products.isEmpty
                        ? const Center(
                            child: Text('No results found. Try another search!'),
                          )
                        : _isGridView
                            ? _buildGridView(products)
                            : _buildListView(products),
              ),
            ],
          );
        },
      ),
    );
  }

  // Filter Chips Row
  Widget _buildFilterChipsRow() {
    return Container(
      color: Colors.white,
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Filter button
          GestureDetector(
            onTap: _openFilter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(AppRadius.chip),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tune, color: Colors.white, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    'Filters (${_filters.length})',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Chip items
          ..._filters.map((filter) {
            return Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.searchBarBg,
                borderRadius: BorderRadius.circular(AppRadius.chip),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Text(
                    filter,
                    style: AppTextStyles.productMeta.copyWith(fontSize: 10, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _filters.remove(filter);
                      });
                    },
                    child: const Icon(Icons.close, size: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }),

          // See More link
          GestureDetector(
            onTap: _openFilter,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 4, right: 16),
                child: Text(
                  'See more ▾',
                  style: AppTextStyles.seeMore.copyWith(fontSize: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2-column Grid View
  Widget _buildGridView(List<Ad> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.76,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsScreen(product: product),
              ),
            );
          },
          child: ProductCard(product: product),
        );
      },
    );
  }

  // List View alternative
  Widget _buildListView(List<Ad> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsScreen(product: product),
              ),
            );
          },
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.title, style: AppTextStyles.productTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(product.formattedPrice, style: AppTextStyles.productPrice),
                        const SizedBox(height: 4),
                        Text('${product.condition} · ${product.rating}', style: AppTextStyles.productMeta),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(product.location, style: AppTextStyles.productMeta, overflow: TextOverflow.ellipsis)),
                            Text(product.date, style: AppTextStyles.productMeta),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
