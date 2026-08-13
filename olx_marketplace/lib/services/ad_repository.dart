import 'package:flutter/foundation.dart';
import '../models/ad.dart';
import '../data/mock_data.dart';

// ─────────────────────────────────────────────
//  SINGLE SHARED SOURCE OF TRUTH FOR ADS
// ─────────────────────────────────────────────

class AdRepository extends ChangeNotifier {
  static final AdRepository _instance = AdRepository._internal();
  static AdRepository get instance => _instance;

  final List<Ad> _ads = [];

  AdRepository._internal() {
    _ads.addAll(MockData.initialAds);
  }

  /// Get all ads in repository
  List<Ad> getAllAds() {
    return List.unmodifiable(_ads);
  }

  /// Get active marketplace listings
  List<Ad> getActiveAds() {
    return _ads.where((ad) => ad.status == 'active').toList();
  }

  /// Get active featured marketplace listings
  List<Ad> getFeaturedAds() {
    return _ads.where((ad) => ad.status == 'active' && ad.isFeatured).toList();
  }

  /// Get user's ads by userId (defaults to 'current_user')
  List<Ad> getMyAds([String userId = 'current_user']) {
    return _ads.where((ad) => ad.userId == userId).toList();
  }

  /// Get user's active ads
  List<Ad> getMyActiveAds([String userId = 'current_user']) {
    return _ads.where((ad) => ad.userId == userId && ad.status == 'active').toList();
  }

  /// Get user's sold ads
  List<Ad> getMySoldAds([String userId = 'current_user']) {
    return _ads.where((ad) => ad.userId == userId && ad.status == 'sold').toList();
  }

  /// Get user's pending ads
  List<Ad> getMyPendingAds([String userId = 'current_user']) {
    return _ads.where((ad) => ad.userId == userId && ad.status == 'pending').toList();
  }

  /// Add a new ad to the repository
  void addAd(Ad ad) {
    _ads.insert(0, ad);
    notifyListeners();
  }

  /// Update an existing ad
  void updateAd(Ad updatedAd) {
    final index = _ads.indexWhere((a) => a.id == updatedAd.id);
    if (index != -1) {
      _ads[index] = updatedAd;
      notifyListeners();
    }
  }

  /// Delete an ad by id
  void deleteAd(String adId) {
    _ads.removeWhere((a) => a.id == adId);
    notifyListeners();
  }

  /// Mark an ad status as sold
  void markAsSold(String adId) {
    final index = _ads.indexWhere((a) => a.id == adId);
    if (index != -1) {
      final oldAd = _ads[index];
      _ads[index] = oldAd.copyWith(status: 'sold');
      notifyListeners();
    }
  }

  /// Search active ads by query
  List<Ad> searchAds(String query) {
    if (query.trim().isEmpty) return getActiveAds();
    final q = query.toLowerCase().trim();
    return _ads.where((ad) {
      if (ad.status != 'active') return false;
      return ad.title.toLowerCase().contains(q) ||
          ad.category.toLowerCase().contains(q) ||
          ad.description.toLowerCase().contains(q) ||
          (ad.brand != null && ad.brand!.toLowerCase().contains(q)) ||
          (ad.model != null && ad.model!.toLowerCase().contains(q)) ||
          ad.location.toLowerCase().contains(q);
    }).toList();
  }

  /// Filter active ads by category
  List<Ad> getAdsByCategory(String category) {
    final cat = category.split('-').first.trim().toLowerCase();
    return _ads.where((ad) {
      if (ad.status != 'active') return false;
      return ad.category.toLowerCase().contains(cat);
    }).toList();
  }

  /// Toggle favorite state of an ad
  void toggleFavorite(String adId) {
    final index = _ads.indexWhere((a) => a.id == adId);
    if (index != -1) {
      final oldAd = _ads[index];
      _ads[index] = oldAd.copyWith(isFavorite: !oldAd.isFavorite);
      notifyListeners();
    }
  }
}
