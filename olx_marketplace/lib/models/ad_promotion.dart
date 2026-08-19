class AdPromotion {
  final String id;
  final String adId;
  final String adTitle;
  final String adImageUrl;
  final String promotionType;
  final String status; // PENDING, ACTIVE, EXPIRED, CANCELLED, FAILED
  final double price;
  final String formattedPrice;
  final int durationDays;
  final DateTime? startedAt;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final String? orderId;

  const AdPromotion({
    required this.id,
    required this.adId,
    required this.adTitle,
    required this.adImageUrl,
    required this.promotionType,
    required this.status,
    required this.price,
    required this.formattedPrice,
    required this.durationDays,
    this.startedAt,
    this.expiresAt,
    this.createdAt,
    this.orderId,
  });

  factory AdPromotion.fromJson(Map<String, dynamic> json) {
    return AdPromotion(
      id: json['id']?.toString() ?? '',
      adId: json['adId']?.toString() ?? '',
      adTitle: json['adTitle'] ?? 'Ad Listing',
      adImageUrl: json['adImageUrl'] ??
          'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&q=80',
      promotionType: json['promotionType'] ?? 'FEATURED',
      status: json['status'] ?? 'PENDING',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      formattedPrice: json['formattedPrice'] ?? '₹0',
      durationDays: (json['durationDays'] as num?)?.toInt() ?? 3,
      startedAt: json['startedAt'] != null ? DateTime.tryParse(json['startedAt']) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      orderId: json['orderId'] as String?,
    );
  }
}
