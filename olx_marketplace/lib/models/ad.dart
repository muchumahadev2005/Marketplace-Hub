// ─────────────────────────────────────────────
//  AD DATA MODEL
// ─────────────────────────────────────────────

class Ad {
  final String id;
  final String title;
  final double price;
  final String currency;
  final String imageUrl;
  final List<String> images;
  final String condition;
  final String rating;
  final String location;
  final double? latitude;
  final double? longitude;
  final String date;
  final bool isFeatured;
  final String category;
  final String? subcategory;
  final String description;
  final String? brand;
  final String? model;
  final String? reasonForSelling;
  final String? additionalDetails;
  final String sellerName;
  final String sellerPhone;
  final String sellerImage;
  final DateTime createdAt;
  final String status; // 'active', 'sold', 'pending'
  final bool isFavorite;
  final String userId;

  const Ad({
    required this.id,
    required this.title,
    required this.price,
    this.currency = '₹',
    required this.imageUrl,
    this.images = const [],
    required this.condition,
    this.rating = '10/10',
    required this.location,
    this.latitude = 31.5204,
    this.longitude = 74.3587,
    required this.date,
    this.isFeatured = false,
    required this.category,
    this.subcategory,
    required this.description,
    this.brand,
    this.model,
    this.reasonForSelling,
    this.additionalDetails,
    this.sellerName = 'Verified Seller',
    this.sellerPhone = '+91 9876543210',
    this.sellerImage =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
    required this.createdAt,
    this.status = 'active',
    this.isFavorite = false,
    this.userId = 'current_user',
  });

  /// Create an Ad from the backend AdResponse JSON.
  factory Ad.fromJson(Map<String, dynamic> json) {
    final seller = json['seller'] as Map<String, dynamic>? ?? {};
    final imagesList = json['images'] is List
        ? List<String>.from(json['images'] as List)
        : <String>[];
    final imageUrl = (json['imageUrl'] as String?) ??
        (imagesList.isNotEmpty ? imagesList.first : '');

    // Map backend AdStatus enum → Flutter status string
    final rawStatus = (json['status'] as String? ?? 'ACTIVE').toUpperCase();
    final status = switch (rawStatus) {
      'ACTIVE' => 'active',
      'SOLD' => 'sold',
      'PENDING' => 'pending',
      _ => 'active',
    };

    // Map backend AdCondition enum → display string
    final rawCondition = (json['condition'] as String? ?? 'USED').toUpperCase();
    final condition = switch (rawCondition) {
      'NEW' => 'New',
      'LIKE_NEW' => 'Like New',
      'GOOD' => 'Good',
      'FAIR' => 'Fair',
      'POOR' => 'Poor',
      _ => 'Used',
    };

    final createdAt = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
        : DateTime.now();

    return Ad(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: '₹',
      imageUrl: imageUrl,
      images: imagesList,
      condition: condition,
      location: json['location'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      date: _formatDate(createdAt),
      isFeatured: json['isFeatured'] == true || json['featured'] == true,
      category: json['categoryName'] ?? '',
      subcategory: json['subcategoryName'] as String?,
      description: json['description'] ?? '',
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      reasonForSelling: json['reasonForSelling'] as String?,
      additionalDetails: json['additionalDetails'] as String?,
      sellerName: seller['name'] ?? 'Verified Seller',
      sellerPhone: seller['phone'] ?? '+91 9876543210',
      sellerImage: seller['profileImage'] ??
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
      createdAt: createdAt,
      status: status,
      isFavorite: json['isFavorite'] == true || json['favorite'] == true,
      userId: seller['id']?.toString() ?? 'current_user',
    );
  }

  static String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  /// Alias getter for requirement compliance
  String get locationName => location;

  /// Returns price formatted with commas, e.g. "₹ 75,000"
  String get formattedPrice {
    final n = price.toInt();
    final raw = n.toString();

    final chars = raw.split('').reversed.toList();
    final buffer = StringBuffer();
    for (int i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) buffer.write(',');
      buffer.write(chars[i]);
    }

    final formatted = buffer.toString().split('').reversed.join();
    return '$currency $formatted';
  }

  Ad copyWith({
    String? id,
    String? title,
    double? price,
    String? currency,
    String? imageUrl,
    List<String>? images,
    String? condition,
    String? rating,
    String? location,
    double? latitude,
    double? longitude,
    String? date,
    bool? isFeatured,
    String? category,
    String? subcategory,
    String? description,
    String? brand,
    String? model,
    String? reasonForSelling,
    String? additionalDetails,
    String? sellerName,
    String? sellerPhone,
    String? sellerImage,
    DateTime? createdAt,
    String? status,
    bool? isFavorite,
    String? userId,
  }) {
    return Ad(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      condition: condition ?? this.condition,
      rating: rating ?? this.rating,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      date: date ?? this.date,
      isFeatured: isFeatured ?? this.isFeatured,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      reasonForSelling: reasonForSelling ?? this.reasonForSelling,
      additionalDetails: additionalDetails ?? this.additionalDetails,
      sellerName: sellerName ?? this.sellerName,
      sellerPhone: sellerPhone ?? this.sellerPhone,
      sellerImage: sellerImage ?? this.sellerImage,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
      userId: userId ?? this.userId,
    );
  }
}

/// Backward compatibility alias for existing widgets
typedef Product = Ad;

/// Represents a browse category shown as a circular avatar + label.
class Category {
  final String id;
  final String name;
  final String imageUrl;

  const Category({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}
