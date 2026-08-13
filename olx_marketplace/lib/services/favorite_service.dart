import 'package:flutter/foundation.dart';
import '../models/ad.dart';
import 'api_client.dart';

// ─────────────────────────────────────────────
//  FAVORITE SERVICE
//  Manages the user's favorite ads.
//  • Loads favorites from backend
//  • Provides fast isFavorite() check via local Set
//  • Notifies listeners on toggle for live heart-icon updates
// ─────────────────────────────────────────────

class FavoriteService extends ChangeNotifier {
  static final FavoriteService _instance = FavoriteService._internal();
  static FavoriteService get instance => _instance;
  FavoriteService._internal();

  final Set<String> _favoriteIds = {};
  List<Ad> _favoriteAds = [];
  bool _isLoading = false;

  List<Ad> get favoriteAds => List.unmodifiable(_favoriteAds);
  bool get isLoading => _isLoading;

  /// Returns true if the ad with [adId] is currently favorited.
  bool isFavorite(String adId) => _favoriteIds.contains(adId);

  /// Load the user's favorites from the backend.
  Future<void> loadFavorites() async {
    if (!ApiClient.instance.hasToken) return;
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiClient.instance.get('/favorites', auth: true);
      if (data is List) {
        _favoriteAds = data
            .map((json) => Ad.fromJson(json as Map<String, dynamic>))
            .toList();
        _favoriteIds
          ..clear()
          ..addAll(_favoriteAds.map((ad) => ad.id));
      }
    } catch (e) {
      debugPrint('FavoriteService.loadFavorites error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Toggle favorite state for the given ad.
  /// Returns the new favorite state (true = added, false = removed).
  Future<bool> toggleFavorite(String adId) async {
    if (!ApiClient.instance.hasToken) return false;

    final wasFavorite = _favoriteIds.contains(adId);

    // Optimistic update
    if (wasFavorite) {
      _favoriteIds.remove(adId);
      _favoriteAds.removeWhere((ad) => ad.id == adId);
    } else {
      _favoriteIds.add(adId);
    }
    notifyListeners();

    try {
      if (wasFavorite) {
        await ApiClient.instance.delete('/favorites/$adId');
      } else {
        await ApiClient.instance.post('/favorites/$adId', auth: true);
      }
      return !wasFavorite;
    } catch (e) {
      // Revert optimistic update on error
      if (wasFavorite) {
        _favoriteIds.add(adId);
      } else {
        _favoriteIds.remove(adId);
      }
      notifyListeners();
      debugPrint('FavoriteService.toggleFavorite error: $e');
      return wasFavorite;
    }
  }

  /// Clear favorites on logout
  void clear() {
    _favoriteIds.clear();
    _favoriteAds.clear();
    notifyListeners();
  }
}
