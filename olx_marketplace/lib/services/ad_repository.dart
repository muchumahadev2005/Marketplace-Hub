import 'package:flutter/foundation.dart';
import '../models/ad.dart';
import 'api_client.dart';
import 'auth_service.dart';

// ─────────────────────────────────────────────
//  AD REPOSITORY
//  Single shared source of truth for ad data.
//  All reads/writes go through the Spring Boot backend.
//  Keeps an in-memory cache and notifies listeners on change.
//
//  Endpoints used:
//  • GET  /api/home               → home feed
//  • GET  /api/ads?page=0&size=50 → all active ads
//  • GET  /api/ads/my             → current user's ads
//  • GET  /api/ads/search         → keyword/category search
//  • POST /api/ads                → create ad
//  • PUT  /api/ads/{id}           → update ad
//  • PATCH /api/ads/{id}/sold     → mark as sold
//  • DELETE /api/ads/{id}         → delete ad
// ─────────────────────────────────────────────

class AdRepository extends ChangeNotifier {
  static final AdRepository _instance = AdRepository._internal();
  static AdRepository get instance => _instance;

  AdRepository._internal();

  // ── State ──────────────────────────────────────────────────────────
  final List<Ad> _ads = [];        // Active marketplace ads (home feed)
  final List<Ad> _myAds = [];      // Current user's ads
  bool _isLoading = false;
  bool _isLoaded = false;
  String? _error;

  // ── Getters ────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  String? get error => _error;

  List<Ad> getAllAds() => List.unmodifiable(_ads);

  List<Ad> getActiveAds() =>
      _ads.where((ad) => ad.status == 'active').toList();

  List<Ad> getFeaturedAds() =>
      _ads.where((ad) => ad.status == 'active' && ad.isFeatured).toList();

  List<Ad> getMyAds([String? userId]) {
    final uid = userId ?? AuthService.instance.currentUser?.id;
    if (uid == null) return List.unmodifiable(_myAds);
    return _myAds;
  }

  List<Ad> getMyActiveAds() =>
      _myAds.where((ad) => ad.status == 'active').toList();

  List<Ad> getMySoldAds() =>
      _myAds.where((ad) => ad.status == 'sold').toList();

  List<Ad> getMyPendingAds() =>
      _myAds.where((ad) => ad.status == 'pending').toList();

  // ── Load home feed ─────────────────────────────────────────────────

  /// Load home screen data: categories + recent/featured ads.
  /// Call this on HomeScreen.initState().
  Future<void> loadHomeData({bool forceReload = false}) async {
    if (_isLoaded && !forceReload) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiClient.instance.get('/home');
      if (data is Map<String, dynamic>) {
        final recentAds = data['recentAds'] as List? ?? [];
        final featuredAds = data['featuredAds'] as List? ?? [];

        _ads.clear();
        // Merge featured + recent, deduplicating by id
        final seen = <String>{};
        for (final json in [...featuredAds, ...recentAds]) {
          final ad = Ad.fromJson(json as Map<String, dynamic>);
          if (seen.add(ad.id)) _ads.add(ad);
        }
        _isLoaded = true;
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('AdRepository.loadHomeData error: $e');
      // Fall back to loading from /api/ads
      await _fallbackLoadAds();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fallbackLoadAds() async {
    try {
      final data = await ApiClient.instance.get(
        '/ads',
        queryParams: {'page': '0', 'size': '50'},
      );
      if (data is Map<String, dynamic>) {
        final content = data['content'] as List? ?? [];
        _ads.clear();
        _ads.addAll(content.map((j) => Ad.fromJson(j as Map<String, dynamic>)));
        _isLoaded = true;
      }
    } catch (e) {
      debugPrint('AdRepository._fallbackLoadAds error: $e');
    }
  }

  // ── Load my ads ────────────────────────────────────────────────────

  Future<void> loadMyAds() async {
    if (!ApiClient.instance.hasToken) return;
    try {
      final data = await ApiClient.instance.get('/ads/my', auth: true);
      if (data is List) {
        _myAds.clear();
        _myAds.addAll(data.map((j) => Ad.fromJson(j as Map<String, dynamic>)));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('AdRepository.loadMyAds error: $e');
    }
  }

  // ── Search (synchronous — reads from in-memory cache) ────────────

  /// Fast local search across cached ads.
  List<Ad> searchAds(String query) {
    if (query.trim().isEmpty) return getActiveAds();
    final q = query.toLowerCase().trim();
    return _ads.where((ad) {
      if (ad.status != 'active') return false;
      return ad.title.toLowerCase().contains(q) ||
          ad.category.toLowerCase().contains(q) ||
          ad.description.toLowerCase().contains(q) ||
          (ad.brand?.toLowerCase().contains(q) ?? false) ||
          (ad.model?.toLowerCase().contains(q) ?? false) ||
          ad.location.toLowerCase().contains(q);
    }).toList();
  }

  /// Filter cached ads by category name (for home / listing screens).
  List<Ad> getAdsByCategory(String categoryName) {
    final cat = categoryName.split('-').first.trim().toLowerCase();
    return _ads.where((ad) {
      if (ad.status != 'active') return false;
      return ad.category.toLowerCase().contains(cat) ||
          ad.title.toLowerCase().contains(cat);
    }).toList();
  }

  /// Full backend search with filters — used by SearchScreen / ListingScreen
  /// when the user types a query.
  Future<List<Ad>> fetchSearch(String query, {
    double? minPrice,
    double? maxPrice,
    String? location,
  }) async {
    if (query.trim().isEmpty) return getActiveAds();
    try {
      final params = <String, String>{
        'page': '0',
        'size': '50',
        'keyword': query.trim(),
        if (minPrice != null) 'minPrice': minPrice.toString(),
        if (maxPrice != null) 'maxPrice': maxPrice.toString(),
      };
      final data = await ApiClient.instance.get('/ads/search', queryParams: params);
      if (data is Map<String, dynamic>) {
        final content = data['content'] as List? ?? [];
        return content.map((j) => Ad.fromJson(j as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('AdRepository.fetchSearch error: $e');
    }
    return searchAds(query); // fallback to cache
  }

  // ── Create ad ──────────────────────────────────────────────────────

  /// Post a new ad to the backend. Returns the created Ad on success.
  Future<Ad?> createAd({
    required String title,
    required String description,
    required double price,
    required String condition,
    required String categoryName,
    int? categoryId,
    String? subcategoryName,
    int? subcategoryId,
    String? brand,
    String? model,
    String? reasonForSelling,
    String? additionalDetails,
    required String location,
    double? latitude,
    double? longitude,
    List<String> imageUrls = const [],
  }) async {
    if (!ApiClient.instance.hasToken) return null;

    // Map condition string → backend AdCondition enum
    final conditionEnum = switch (condition.toLowerCase()) {
      'new' => 'NEW',
      'like new' => 'LIKE_NEW',
      'good' => 'GOOD',
      'fair' => 'FAIR',
      'poor' => 'POOR',
      _ => 'GOOD',
    };

    final body = {
      'title': title,
      'description': description,
      'price': price,
      'condition': conditionEnum,
      'categoryId': categoryId ?? 1,
      'location': location,
      if (subcategoryId != null) 'subcategoryId': subcategoryId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (brand != null && brand.isNotEmpty) 'brand': brand,
      if (model != null && model.isNotEmpty) 'model': model,
      if (reasonForSelling != null) 'reasonForSelling': reasonForSelling,
      if (additionalDetails != null && additionalDetails.isNotEmpty) 'additionalDetails': additionalDetails,
      'imageUrls': imageUrls,
    };

    try {
      final data = await ApiClient.instance.post('/ads', body: body, auth: true);
      if (data is Map<String, dynamic>) {
        final newAd = Ad.fromJson(data);
        _ads.insert(0, newAd);
        _myAds.insert(0, newAd);
        notifyListeners();
        return newAd;
      }
    } catch (e) {
      debugPrint('AdRepository.createAd error: $e');
    }
    return null;
  }

  // ── Update ad ──────────────────────────────────────────────────────

  Future<bool> updateAd(Ad updatedAd) async {
    if (!ApiClient.instance.hasToken) return false;

    final conditionEnum = switch (updatedAd.condition.toLowerCase()) {
      'new' => 'NEW',
      'like new' => 'LIKE_NEW',
      'good' => 'GOOD',
      'fair' => 'FAIR',
      'poor' => 'POOR',
      _ => 'GOOD',
    };

    final body = {
      'title': updatedAd.title,
      'description': updatedAd.description,
      'price': updatedAd.price,
      'condition': conditionEnum,
      'categoryId': updatedAd.categoryId ?? 1,
      'location': updatedAd.location,
      if (updatedAd.subcategoryId != null) 'subcategoryId': updatedAd.subcategoryId,
      if (updatedAd.latitude != null) 'latitude': updatedAd.latitude,
      if (updatedAd.longitude != null) 'longitude': updatedAd.longitude,
      if (updatedAd.brand != null) 'brand': updatedAd.brand,
      if (updatedAd.model != null) 'model': updatedAd.model,
      if (updatedAd.reasonForSelling != null) 'reasonForSelling': updatedAd.reasonForSelling,
      if (updatedAd.additionalDetails != null) 'additionalDetails': updatedAd.additionalDetails,
      'imageUrls': updatedAd.images,
    };

    try {
      final data = await ApiClient.instance.put('/ads/${updatedAd.id}', body: body);
      if (data is Map<String, dynamic>) {
        final refreshed = Ad.fromJson(data);
        _updateInList(_ads, refreshed);
        _updateInList(_myAds, refreshed);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('AdRepository.updateAd error: $e');
    }
    return false;
  }

  // ── Delete ad ──────────────────────────────────────────────────────

  Future<bool> deleteAd(String adId) async {
    if (!ApiClient.instance.hasToken) return false;
    try {
      await ApiClient.instance.delete('/ads/$adId');
      _ads.removeWhere((a) => a.id == adId);
      _myAds.removeWhere((a) => a.id == adId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('AdRepository.deleteAd error: $e');
      return false;
    }
  }

  // ── Mark as sold ───────────────────────────────────────────────────

  Future<bool> markAsSold(String adId) async {
    if (!ApiClient.instance.hasToken) return false;
    try {
      await ApiClient.instance.patch('/ads/$adId/sold');
      _updateStatus(_ads, adId, 'sold');
      _updateStatus(_myAds, adId, 'sold');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('AdRepository.markAsSold error: $e');
      return false;
    }
  }

  // ── Favorites (local toggle for UI only) ──────────────────────────

  /// Toggles the local isFavorite flag in the cache.
  /// The actual API call is handled by FavoriteService.
  void toggleFavorite(String adId) {
    final idx = _ads.indexWhere((a) => a.id == adId);
    if (idx != -1) {
      _ads[idx] = _ads[idx].copyWith(isFavorite: !_ads[idx].isFavorite);
      notifyListeners();
    }
  }

  // ── Backward-compat local add (used by PostAdScreen on API failure) ─

  void addAd(Ad ad) {
    _ads.insert(0, ad);
    _myAds.insert(0, ad);
    notifyListeners();
  }

  // ── Private helpers ────────────────────────────────────────────────

  void _updateInList(List<Ad> list, Ad updated) {
    final idx = list.indexWhere((a) => a.id == updated.id);
    if (idx != -1) list[idx] = updated;
  }

  void _updateStatus(List<Ad> list, String adId, String status) {
    final idx = list.indexWhere((a) => a.id == adId);
    if (idx != -1) list[idx] = list[idx].copyWith(status: status);
  }

  /// Clear all caches on logout
  void clear() {
    _ads.clear();
    _myAds.clear();
    _isLoaded = false;
    notifyListeners();
  }
}
