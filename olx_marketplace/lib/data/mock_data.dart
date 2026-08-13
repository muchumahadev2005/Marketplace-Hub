import '../models/ad.dart';

// ─────────────────────────────────────────────
//  STATIC MOCK DATA  (Initial marketplace seed)
// ─────────────────────────────────────────────

class MockData {
  MockData._();

  // ── Browse Categories ──────────────────────
  static const List<Category> categories = [
    Category(
      id: 'c1',
      name: 'Mobiles',
      imageUrl:
          'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=200&q=80',
    ),
    Category(
      id: 'c2',
      name: 'Property\nfor Sale',
      imageUrl:
          'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=200&q=80',
    ),
    Category(
      id: 'c3',
      name: 'Vehicles',
      imageUrl:
          'https://images.unsplash.com/photo-1583121274602-3e2820c69888?w=200&q=80',
    ),
    Category(
      id: 'c4',
      name: 'Bikes',
      imageUrl:
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=200&q=80',
    ),
    Category(
      id: 'c5',
      name: 'Business\nIndustrial',
      imageUrl:
          'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=200&q=80',
    ),
    Category(
      id: 'c6',
      name: 'Electronics',
      imageUrl:
          'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=200&q=80',
    ),
  ];

  // ── Initial Seed Ads for Shared AdRepository ──────────────────────
  static List<Ad> get initialAds => [
    Ad(
      id: 'f1',
      title: 'MacBook Pro 14 M1 Pro',
      price: 145000,
      currency: '₹',
      imageUrl:
          'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=600&q=80',
      images: [
        'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=600&q=80',
      ],
      condition: 'Like New',
      rating: '10/10',
      location: 'Gulberg Phase 4, Lahore',
      date: '22 Sep',
      isFeatured: true,
      category: 'Electronics',
      description: 'MacBook Pro 14 inch M1 Pro, 16GB RAM, 512GB SSD. Pristine condition with original charger and box.',
      brand: 'Apple',
      model: 'MacBook Pro 14',
      reasonForSelling: 'Upgrading',
      additionalDetails: 'Battery count is only 45 cycles.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      status: 'active',
      userId: 'current_user',
    ),
    Ad(
      id: 'f2',
      title: 'iPhone 14 Pro Max 256GB',
      price: 95000,
      currency: '₹',
      imageUrl:
          'https://images.unsplash.com/photo-1574755393849-623942496936?w=600&q=80',
      images: [
        'https://images.unsplash.com/photo-1574755393849-623942496936?w=600&q=80',
      ],
      condition: 'Used',
      rating: '08/10',
      location: 'Gulberg Phase 4, Lahore',
      date: '22 Sep',
      isFeatured: true,
      category: 'Mobiles',
      description: 'iPhone 14 Pro Max Deep Purple, 256GB storage, 88% battery health. Minor scratches on body.',
      brand: 'Apple',
      model: '14 Pro Max',
      reasonForSelling: 'Upgrading',
      additionalDetails: 'Includes screen protector and protective back cover.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      status: 'active',
      userId: 'other_user',
    ),
    Ad(
      id: 'm1',
      title: 'iPhone 13 Pro Max 128GB',
      price: 68000,
      currency: '₹',
      imageUrl:
          'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400&q=80',
      images: [
        'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400&q=80',
      ],
      condition: 'New',
      rating: '8/10',
      location: 'Gulberg Phase 4, Lahore',
      date: '31 Sep',
      category: 'Mobiles',
      description: 'Brand new box opened iPhone 13 Pro Max Sierra Blue. All accessories included.',
      brand: 'Apple',
      model: '13 Pro Max',
      reasonForSelling: 'Not using',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      status: 'active',
      userId: 'other_user',
    ),
    Ad(
      id: 'user1',
      title: 'Samsung Galaxy S22 Ultra 12/256GB',
      price: 54000,
      currency: '₹',
      imageUrl:
          'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=400&q=80',
      images: [
        'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=400&q=80',
      ],
      condition: 'Used',
      rating: '8/10',
      location: 'Samanabad, Lahore',
      date: '10 days ago',
      category: 'Mobiles',
      description: 'Samsung S22 Ultra Phantom Black in good condition. Complete box with S-Pen.',
      brand: 'Samsung',
      model: 'S22 Ultra',
      reasonForSelling: 'Need money',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      status: 'sold',
      userId: 'current_user',
    ),
    Ad(
      id: 'b1',
      title: 'Suzuki GIXER 150 SF',
      price: 110000,
      currency: '₹',
      imageUrl:
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80',
      images: [
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80',
      ],
      condition: 'New',
      rating: '10/10',
      location: 'Gulberg Phase 4, Lahore',
      date: '31 Sep',
      category: 'Bikes',
      description: 'Brand new Suzuki GIXER 150cc bike, 2024 model, zero meter.',
      brand: 'Suzuki',
      model: 'GIXER 150',
      reasonForSelling: 'Moving',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      status: 'active',
      userId: 'other_user',
    ),
    Ad(
      id: 'b2',
      title: 'Yamaha YBR 125G Black',
      price: 85000,
      currency: '₹',
      imageUrl:
          'https://images.unsplash.com/photo-1609630875171-b1321377ee65?w=400&q=80',
      images: [
        'https://images.unsplash.com/photo-1609630875171-b1321377ee65?w=400&q=80',
      ],
      condition: 'Like New',
      rating: '10/10',
      location: 'Clifton, Karachi',
      date: '2 hours ago',
      category: 'Bikes',
      description: 'Yamaha YBR 125G in immaculate condition. Total original paint, carefully driven.',
      brand: 'Yamaha',
      model: 'YBR 125G',
      reasonForSelling: 'Upgrading',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      status: 'pending',
      userId: 'current_user',
    ),
  ];

  // ── Ad Banner ─────────────────────────────
  static const String nikeAdImageUrl =
      'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&q=80';
}
