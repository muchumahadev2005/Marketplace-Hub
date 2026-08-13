import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/location_data.dart';

// ─────────────────────────────────────────────
//  GEOCODING SERVICE (OpenStreetMap Nominatim)
//  Clean service abstraction for forward and reverse
//  geocoding using free OpenStreetMap services.
// ─────────────────────────────────────────────

class GeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  static const Map<String, String> _headers = {
    'User-Agent': 'OLXMarketplaceFlutterApp/1.0 (olx_marketplace_user_app)',
    'Accept-Language': 'en-US,en;q=0.9',
  };

  /// Reverse geocodes (lat, lng) to a LocationData object
  static Future<LocationData?> reverseGeocode(
      double latitude, double longitude) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1',
      );

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final address = data['address'] as Map<String, dynamic>? ?? {};

        final String displayName = data['display_name'] as String? ??
            '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

        final String? city = address['city'] as String? ??
            address['town'] as String? ??
            address['suburb'] as String? ??
            address['village'] as String? ??
            address['county'] as String?;

        final String? region =
            address['state'] as String? ?? address['region'] as String?;
        final String? country = address['country'] as String?;

        return LocationData(
          latitude: latitude,
          longitude: longitude,
          displayName: displayName,
          city: city,
          region: region,
          country: country,
        );
      }
    } catch (e) {
      debugPrint('Reverse geocoding exception: $e');
    }

    // Fallback if offline or API failure
    return LocationData(
      latitude: latitude,
      longitude: longitude,
      displayName:
          'Location (${latitude.toStringAsFixed(3)}, ${longitude.toStringAsFixed(3)})',
    );
  }

  /// Forward geocodes location search query to a list of LocationData objects
  static Future<List<LocationData>> searchLocations(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final url = Uri.parse(
        '$_baseUrl/search?format=json&q=${Uri.encodeComponent(query.trim())}&limit=8&addressdetails=1',
      );

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> results = jsonDecode(response.body);

        return results.map((item) {
          final Map<String, dynamic> address =
              item['address'] as Map<String, dynamic>? ?? {};

          final double lat = double.parse(item['lat'].toString());
          final double lon = double.parse(item['lon'].toString());
          final String displayName = item['display_name'] as String? ?? '';

          final String? city = address['city'] as String? ??
              address['town'] as String? ??
              address['suburb'] as String? ??
              address['village'] as String? ??
              address['county'] as String?;

          final String? region =
              address['state'] as String? ?? address['region'] as String?;
          final String? country = address['country'] as String?;

          return LocationData(
            latitude: lat,
            longitude: lon,
            displayName: displayName,
            city: city,
            region: region,
            country: country,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Geocoding search exception: $e');
    }

    return [];
  }
}
