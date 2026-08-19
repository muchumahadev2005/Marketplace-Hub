class SellerSubscription {
  final String id;
  final String planName; // FREE, PREMIUM, BUSINESS
  final String status;
  final int adLimit;
  final int activeAdsCount;
  final double price;
  final String formattedPrice;
  final DateTime? startedAt;
  final DateTime? expiresAt;

  const SellerSubscription({
    required this.id,
    required this.planName,
    required this.status,
    required this.adLimit,
    required this.activeAdsCount,
    required this.price,
    required this.formattedPrice,
    this.startedAt,
    this.expiresAt,
  });

  factory SellerSubscription.fromJson(Map<String, dynamic> json) {
    return SellerSubscription(
      id: json['id']?.toString() ?? '',
      planName: json['planName'] ?? 'FREE',
      status: json['status'] ?? 'ACTIVE',
      adLimit: (json['adLimit'] as num?)?.toInt() ?? 5,
      activeAdsCount: (json['activeAdsCount'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      formattedPrice: json['formattedPrice'] ?? '₹0',
      startedAt: json['startedAt'] != null ? DateTime.tryParse(json['startedAt']) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt']) : null,
    );
  }
}

class SellerDashboardData {
  final String sellerType;
  final bool businessVerified;
  final int activeAdsCount;
  final int adLimit;
  final int featuredAdsCount;
  final int totalPromotionsCount;
  final int totalViews;
  final SellerSubscription? currentSubscription;

  const SellerDashboardData({
    required this.sellerType,
    required this.businessVerified,
    required this.activeAdsCount,
    required this.adLimit,
    required this.featuredAdsCount,
    required this.totalPromotionsCount,
    required this.totalViews,
    this.currentSubscription,
  });

  factory SellerDashboardData.fromJson(Map<String, dynamic> json) {
    return SellerDashboardData(
      sellerType: json['sellerType'] ?? 'FREE',
      businessVerified: json['businessVerified'] == true,
      activeAdsCount: (json['activeAdsCount'] as num?)?.toInt() ?? 0,
      adLimit: (json['adLimit'] as num?)?.toInt() ?? 5,
      featuredAdsCount: (json['featuredAdsCount'] as num?)?.toInt() ?? 0,
      totalPromotionsCount: (json['totalPromotionsCount'] as num?)?.toInt() ?? 0,
      totalViews: (json['totalViews'] as num?)?.toInt() ?? 0,
      currentSubscription: json['currentSubscription'] != null
          ? SellerSubscription.fromJson(json['currentSubscription'] as Map<String, dynamic>)
          : null,
    );
  }
}
