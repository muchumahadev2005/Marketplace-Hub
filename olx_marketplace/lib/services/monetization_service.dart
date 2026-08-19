import 'package:flutter/foundation.dart';
import '../models/ad_promotion.dart';
import '../models/promotion_banner.dart';
import '../models/promotion_plan.dart';
import '../models/seller_subscription.dart';
import 'api_client.dart';

// ─────────────────────────────────────────────
//  MONETIZATION SERVICE
//  Single source of truth for monetization logic:
//  • Promotion plans & order creation
//  • Payment verification & activation
//  • Seller subscriptions & dashboard analytics
//  • Promotional banners
// ─────────────────────────────────────────────

class MonetizationService extends ChangeNotifier {
  static final MonetizationService _instance = MonetizationService._internal();
  static MonetizationService get instance => _instance;
  MonetizationService._internal();

  List<PromotionPlan> _promotionPlans = [];
  List<AdPromotion> _myPromotions = [];
  List<PromotionBanner> _banners = [];
  SellerDashboardData? _dashboardData;
  bool _isLoadingPlans = false;
  bool _isLoadingPromotions = false;
  bool _isLoadingBanners = false;

  List<PromotionPlan> get promotionPlans => List.unmodifiable(_promotionPlans);
  List<AdPromotion> get myPromotions => List.unmodifiable(_myPromotions);
  List<PromotionBanner> get banners => List.unmodifiable(_banners);
  SellerDashboardData? get dashboardData => _dashboardData;
  bool get isLoadingPlans => _isLoadingPlans;
  bool get isLoadingPromotions => _isLoadingPromotions;
  bool get isLoadingBanners => _isLoadingBanners;

  /// Fetch dynamic promotion plans configured on Spring Boot backend
  Future<List<PromotionPlan>> fetchPromotionPlans() async {
    _isLoadingPlans = true;
    notifyListeners();

    try {
      final data = await ApiClient.instance.get('/promotions/plans');
      if (data is List) {
        _promotionPlans = data
            .map((j) => PromotionPlan.fromJson(j as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('MonetizationService.fetchPromotionPlans error: $e');
    }

    _isLoadingPlans = false;
    notifyListeners();
    return _promotionPlans;
  }

  /// Create a pending promotion order on backend
  Future<AdPromotion?> createPromotionOrder({
    required String adId,
    required String planId,
  }) async {
    if (!ApiClient.instance.hasToken) return null;

    try {
      final body = {
        'adId': int.parse(adId),
        'planId': int.parse(planId),
      };

      final data = await ApiClient.instance.post('/promotions', body: body, auth: true);
      if (data is Map<String, dynamic>) {
        return AdPromotion.fromJson(data);
      }
    } catch (e) {
      debugPrint('MonetizationService.createPromotionOrder error: $e');
    }
    return null;
  }

  /// Verify payment with backend & activate promotion
  Future<AdPromotion?> verifyAndActivatePromotion({
    required String promotionId,
    String? providerPaymentId,
    String? signature,
    bool devModeSimulatedSuccess = true,
  }) async {
    if (!ApiClient.instance.hasToken) return null;

    try {
      final body = {
        'promotionId': int.parse(promotionId),
        'providerPaymentId': providerPaymentId ?? 'dev_payment_${DateTime.now().millisecondsSinceEpoch}',
        'signature': signature ?? 'dev_sig',
        'devModeSimulatedSuccess': devModeSimulatedSuccess,
      };

      final data = await ApiClient.instance.post(
        '/promotions/$promotionId/verify',
        body: body,
        auth: true,
      );

      if (data is Map<String, dynamic>) {
        final updatedPromo = AdPromotion.fromJson(data);
        await fetchMyPromotions();
        return updatedPromo;
      }
    } catch (e) {
      debugPrint('MonetizationService.verifyAndActivatePromotion error: $e');
    }
    return null;
  }

  /// Load current seller's promotions history
  Future<List<AdPromotion>> fetchMyPromotions() async {
    if (!ApiClient.instance.hasToken) return [];
    _isLoadingPromotions = true;
    notifyListeners();

    try {
      final data = await ApiClient.instance.get('/promotions/my', auth: true);
      if (data is List) {
        _myPromotions = data
            .map((j) => AdPromotion.fromJson(j as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('MonetizationService.fetchMyPromotions error: $e');
    }

    _isLoadingPromotions = false;
    notifyListeners();
    return _myPromotions;
  }

  /// Load seller dashboard analytics & subscription status
  Future<SellerDashboardData?> fetchSellerDashboard() async {
    if (!ApiClient.instance.hasToken) return null;

    try {
      final data = await ApiClient.instance.get('/seller/dashboard', auth: true);
      if (data is Map<String, dynamic>) {
        _dashboardData = SellerDashboardData.fromJson(data);
        notifyListeners();
        return _dashboardData;
      }
    } on UnauthorizedException {
      _dashboardData = null;
      notifyListeners();
    } catch (e) {
      debugPrint('MonetizationService.fetchSellerDashboard error: $e');
    }
    return null;
  }

  /// Create Razorpay Order for Subscription Upgrade
  Future<Map<String, dynamic>?> createSubscriptionOrder(String planName) async {
    if (!ApiClient.instance.hasToken) return null;

    try {
      final data = await ApiClient.instance.post(
        '/subscriptions/order',
        body: {'planName': planName},
        auth: true,
      );
      if (data is Map<String, dynamic>) {
        return data;
      }
    } catch (e) {
      debugPrint('MonetizationService.createSubscriptionOrder error: $e');
    }
    return null;
  }

  /// Verify Razorpay Payment Signature and activate Subscription
  Future<bool> verifySubscriptionPayment({
    required String orderId,
    required String paymentId,
    required String signature,
    required String planName,
  }) async {
    if (!ApiClient.instance.hasToken) return false;

    try {
      final data = await ApiClient.instance.post(
        '/subscriptions/verify',
        body: {
          'razorpayOrderId': orderId,
          'razorpayPaymentId': paymentId,
          'razorpaySignature': signature,
          'type': 'SUBSCRIPTION',
          'planName': planName,
        },
        auth: true,
      );
      if (data is Map<String, dynamic> && data['success'] == true) {
        await fetchSellerDashboard();
        return true;
      }
    } catch (e) {
      debugPrint('MonetizationService.verifySubscriptionPayment error: $e');
    }
    return false;
  }

  /// Load active promotional banners for Home feed
  Future<List<PromotionBanner>> fetchBanners() async {
    _isLoadingBanners = true;
    notifyListeners();

    try {
      final data = await ApiClient.instance.get('/banners');
      if (data is List) {
        _banners = data
            .map((j) => PromotionBanner.fromJson(j as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('MonetizationService.fetchBanners error: $e');
    }

    _isLoadingBanners = false;
    notifyListeners();
    return _banners;
  }
}
