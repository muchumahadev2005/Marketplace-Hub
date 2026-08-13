import 'dart:convert';

class LocationData {
  final double latitude;
  final double longitude;
  final String displayName;
  final String? city;
  final String? region;
  final String? country;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.displayName,
    this.city,
    this.region,
    this.country,
  });

  /// Default fallback location (Gulberg Phase 4, Lahore)
  static const LocationData defaultLocation = LocationData(
    latitude: 31.5204,
    longitude: 74.3587,
    displayName: 'Gulberg Phase 4, Lahore',
    city: 'Lahore',
    region: 'Punjab',
    country: 'Pakistan',
  );

  /// Returns a clean short label suitable for location bars & chips
  String get shortName {
    if (city != null && city!.isNotEmpty) {
      if (displayName.contains(city!)) {
        final parts = displayName.split(',');
        if (parts.length >= 2) {
          return '${parts[0].trim()}, ${city!}';
        }
      }
      return city!;
    }
    final parts = displayName.split(',');
    if (parts.length >= 2) {
      return '${parts[0].trim()}, ${parts[1].trim()}';
    }
    return displayName;
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'displayName': displayName,
      'city': city,
      'region': region,
      'country': country,
    };
  }

  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      displayName: map['displayName'] as String? ?? 'Unknown Location',
      city: map['city'] as String?,
      region: map['region'] as String?,
      country: map['country'] as String?,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory LocationData.fromJson(String source) =>
      LocationData.fromMap(jsonDecode(source) as Map<String, dynamic>);

  LocationData copyWith({
    double? latitude,
    double? longitude,
    String? displayName,
    String? city,
    String? region,
    String? country,
  }) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      displayName: displayName ?? this.displayName,
      city: city ?? this.city,
      region: region ?? this.region,
      country: country ?? this.country,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationData &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.displayName == displayName;
  }

  @override
  int get hashCode =>
      latitude.hashCode ^ longitude.hashCode ^ displayName.hashCode;
}
