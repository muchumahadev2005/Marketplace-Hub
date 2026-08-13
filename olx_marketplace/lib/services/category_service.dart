import 'package:flutter/foundation.dart' hide Category;
import '../models/ad.dart';
import 'api_client.dart';

// ─────────────────────────────────────────────
//  CATEGORY SERVICE
//  Loads categories from backend and caches them.
//  Provides the same Category model used throughout the app.
// ─────────────────────────────────────────────

class CategoryService extends ChangeNotifier {
  static final CategoryService _instance = CategoryService._internal();
  static CategoryService get instance => _instance;
  CategoryService._internal();

  List<Category> _categories = [];
  bool _isLoading = false;
  bool _loaded = false;

  List<Category> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  bool get isLoaded => _loaded;

  /// Load all root categories from the backend.
  /// Uses cache — call [forceReload] to bypass.
  Future<void> loadCategories({bool forceReload = false}) async {
    if (_loaded && !forceReload) return;
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiClient.instance.get('/categories');
      if (data is List) {
        _categories = data
            .map((json) => _categoryFromJson(json as Map<String, dynamic>))
            .toList();
        _loaded = true;
      }
    } catch (e) {
      debugPrint('CategoryService.loadCategories error: $e');
      // Keep any previously cached categories on error
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Returns subcategories for a given parent category ID.
  Future<List<Category>> getSubcategories(String parentId) async {
    try {
      final data = await ApiClient.instance.get('/categories/$parentId/subcategories');
      if (data is List) {
        return data
            .map((json) => _categoryFromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('CategoryService.getSubcategories error: $e');
    }
    return [];
  }

  Category _categoryFromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ??
          'https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=200&q=80',
    );
  }
}
