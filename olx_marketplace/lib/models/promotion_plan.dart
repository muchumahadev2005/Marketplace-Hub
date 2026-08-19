class PromotionPlan {
  final String id;
  final String name;
  final String type; // FEATURED, BOOST, TOP_PLACEMENT
  final int durationDays;
  final double price;
  final String formattedPrice;
  final String description;

  const PromotionPlan({
    required this.id,
    required this.name,
    required this.type,
    required this.durationDays,
    required this.price,
    required this.formattedPrice,
    required this.description,
  });

  factory PromotionPlan.fromJson(Map<String, dynamic> json) {
    return PromotionPlan(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'FEATURED',
      durationDays: (json['durationDays'] as num?)?.toInt() ?? 3,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      formattedPrice: json['formattedPrice'] ?? '₹0',
      description: json['description'] ?? '',
    );
  }
}
