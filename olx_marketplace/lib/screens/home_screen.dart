import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';
import '../core/constants.dart';
import '../data/mock_data.dart';
import '../models/ad.dart';
import '../services/ad_repository.dart';
import '../services/category_service.dart';
import '../services/favorite_service.dart';
import '../widgets/olx_app_bar.dart';
import '../widgets/location_bar.dart';
import '../widgets/category_card.dart';
import '../widgets/section_header.dart';
import '../widgets/product_card.dart';
import '../widgets/olx_bottom_nav.dart';

// Import sub-screens
import 'chats_screen.dart';
import 'my_ads_screen.dart';
import 'account_screen.dart';
import 'search_screen.dart';
import 'location_screen.dart';
import 'category_screen.dart';
import 'listing_screen.dart';
import 'product_details_screen.dart';
import 'post_ad_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Which bottom nav tab is active (0 = HOME)
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load real data from backend on first open
    AdRepository.instance.loadHomeData();
    CategoryService.instance.loadCategories();
    FavoriteService.instance.loadFavorites();
  }

  void _openPostAd() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const PostAdScreen()),
    );
    if (result == true) {
      setState(() {
        _selectedIndex = 3; // Navigate to My Ads
      });
    }
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const ChatsScreen();
      case 3:
        return const MyAdsScreen();
      case 4:
        return const AccountScreen();
      default:
        return _buildHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ── App bar (only shown on HOME tab) ──────────────────────────────
      appBar: _selectedIndex == 0
          ? OlxAppBar(
              onSearchTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
              onCategoryTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CategoryScreen(categoryName: 'Categories')),
                );
              },
            )
          : null,

      // ── Floating SELL button ─────────────────
      floatingActionButton: _SellFab(
        onTap: _openPostAd,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ── Bottom navigation ────────────────────
      bottomNavigationBar: OlxBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 2) {
            _openPostAd();
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
      ),

      // ── Current screen body ───────────────────────
      body: ListenableBuilder(
        listenable: Listenable.merge([
          AdRepository.instance,
          CategoryService.instance,
        ]),
        builder: (context, _) => _buildBody(),
      ),
    );
  }

  Widget _buildHomeContent() {
    final featuredAds = AdRepository.instance.getFeaturedAds();
    final mobileAds = AdRepository.instance.getAdsByCategory('Mobiles');
    final activeAds = AdRepository.instance.getActiveAds();
    final bikeAds = AdRepository.instance.getAdsByCategory('Bikes');

    return ScrollConfiguration(
      behavior: const NoOverscrollBehavior(),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Location strip
            LocationBar(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LocationScreen()),
                );
              },
            ),

            const SizedBox(height: 8),

            // 2. Browse Categories
            _Section(
              header: SectionHeader(
                title: 'Browse Categories',
                count: '${CategoryService.instance.categories.length}',
                onSeeMore: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CategoryScreen(categoryName: 'Categories')),
                  );
                },
              ),
              content: const _CategoryRow(),
            ),

            const SizedBox(height: 6),

            // 3. Featured
            if (featuredAds.isNotEmpty) ...[
              _Section(
                header: SectionHeader(
                  title: 'Featured',
                  count: '${featuredAds.length}',
                  onSeeMore: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ListingScreen(categoryName: 'Featured')),
                    );
                  },
                ),
                content: _ProductRow(
                  products: featuredAds,
                  imageHeight: AppDimensions.featuredImageHeight,
                  cardHeight: AppDimensions.featuredCardHeight,
                ),
              ),
              const SizedBox(height: 6),
            ],

            // 4. Mobile
            if (mobileAds.isNotEmpty) ...[
              _Section(
                header: SectionHeader(
                  title: 'Mobile',
                  count: '${mobileAds.length}',
                  onSeeMore: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ListingScreen(categoryName: 'Mobiles')),
                    );
                  },
                ),
                content: _ProductRow(
                  products: mobileAds,
                ),
              ),
              const SizedBox(height: 6),
            ],

            // 5. Interstitial Ad banner
            const _NikeAdBanner(),

            const SizedBox(height: 6),

            // 6. Most Viewed / Latest
            _Section(
              header: SectionHeader(
                title: 'Most Viewed',
                count: '${activeAds.length}',
                onSeeMore: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ListingScreen(categoryName: 'Most Viewed')),
                  );
                },
              ),
              content: _ProductRow(
                products: activeAds,
              ),
            ),

            const SizedBox(height: 6),

            // 7. MotorBikes
            if (bikeAds.isNotEmpty) ...[
              _Section(
                header: SectionHeader(
                  title: 'MotorBikes',
                  count: '${bikeAds.length}',
                  onSeeMore: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ListingScreen(categoryName: 'MotorBikes')),
                    );
                  },
                ),
                content: _ProductRow(
                  products: bikeAds,
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── No Overscroll Behavior ───────────────────
class NoOverscrollBehavior extends ScrollBehavior {
  const NoOverscrollBehavior();

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

// ── Floating SELL Button ──────────────────────
class _SellFab extends StatelessWidget {
  final VoidCallback onTap;

  const _SellFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF7B9EFF), AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.40),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

// ── Reusable Section ─────────────────────────
class _Section extends StatelessWidget {
  final Widget header;
  final Widget content;

  const _Section({required this.header, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}

// ── Category Row ─────────────────────────────
class _CategoryRow extends StatelessWidget {
  const _CategoryRow();

  @override
  Widget build(BuildContext context) {
    final list = CategoryService.instance.categories.isNotEmpty
        ? CategoryService.instance.categories
        : MockData.categories;
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: list.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final cat = list[index];
          return CategoryCard(
            category: cat,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryScreen(categoryName: cat.name.replaceAll('\n', ' ')),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Product Row ──────────────────────────────
class _ProductRow extends StatelessWidget {
  final List<Ad> products;
  final double? imageHeight;
  final double? cardHeight;

  const _ProductRow({
    required this.products,
    this.imageHeight,
    this.cardHeight,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth > 0
        ? ((screenWidth - AppDimensions.sidepadding * 2 - AppDimensions.productCardGap) / 2).clamp(100.0, 600.0)
        : 160.0;

    final double listHeight = cardHeight ?? AppDimensions.productCardHeight;

    return SizedBox(
      height: listHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: products.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppDimensions.productCardGap),
        itemBuilder: (context, index) {
          final product = products[index];
          return SizedBox(
            width: cardWidth,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailsScreen(product: product),
                  ),
                );
              },
              child: ProductCard(
                product: product,
                imageHeight: imageHeight,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Ad Banner ────────────────────────────────
class _NikeAdBanner extends StatelessWidget {
  const _NikeAdBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        color: const Color(0xFF1A1A2E),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 180,
            child: CachedNetworkImage(
              imageUrl: MockData.nikeAdImageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(color: const Color(0xFF1A1A2E)),
              errorWidget: (context, url, error) =>
                  Container(color: const Color(0xFF1A1A2E)),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xCC1A1A2E),
                  Colors.transparent,
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Ad',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Nike',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Free Metcon',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '₹ 12,099',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
