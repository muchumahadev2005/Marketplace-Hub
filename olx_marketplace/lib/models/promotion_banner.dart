class PromotionBanner {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String targetUrl;

  const PromotionBanner({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.targetUrl,
  });

  factory PromotionBanner.fromJson(Map<String, dynamic> json) {
    return PromotionBanner(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      targetUrl: json['targetUrl'] ?? '',
    );
  }
}
