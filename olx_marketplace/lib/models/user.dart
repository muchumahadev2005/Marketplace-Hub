// ─────────────────────────────────────────────
//  USER DATA MODEL
// ─────────────────────────────────────────────

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl =
        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&q=80',
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
