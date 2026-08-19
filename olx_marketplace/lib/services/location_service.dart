import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_data.dart';
import 'geocoding_service.dart';

// ─────────────────────────────────────────────
//  LOCATION SERVICE & PROVIDER
//  Manages device GPS location, permissions,
//  current selected location state, and local persistence.
// ─────────────────────────────────────────────

enum LocationPermissionState {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

class LocationService extends ChangeNotifier {
  static final LocationService _instance = LocationService._internal();
  static LocationService get instance => _instance;

  LocationService._internal() {
    _loadSavedLocation();
  }

  LocationData _selectedLocation = LocationData.defaultLocation;
  bool _isLoading = false;
  String? _errorMessage;

  LocationData get selectedLocation => _selectedLocation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static const String _prefKeyLocation = 'saved_selected_location';

  /// Loads saved location from SharedPreferences
  Future<void> _loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(_prefKeyLocation);
      if (savedJson != null && savedJson.isNotEmpty) {
        _selectedLocation = LocationData.fromJson(savedJson);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading saved location: $e');
    }
  }

  /// Sets and persists the selected location
  Future<void> setSelectedLocation(LocationData location) async {
    _selectedLocation = location;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyLocation, location.toJson());
    } catch (e) {
      debugPrint('Error saving location to SharedPreferences: $e');
    }
  }

  /// Fetches current device GPS location safely with permission handling
  Future<LocationData?> getCurrentDeviceLocation({
    required Function(LocationPermissionState state, String message)
        onErrorState,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Check if location permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _isLoading = false;
          notifyListeners();
          onErrorState(
            LocationPermissionState.denied,
            'Location permission was denied. You can manually search for your location.',
          );
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _isLoading = false;
        notifyListeners();
        onErrorState(
          LocationPermissionState.deniedForever,
          'Location permissions are permanently denied. Please enable them in app settings.',
        );
        return null;
      }

      // 2. Obtain current device position with fallback strategy
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 4),
          ),
        );
      } catch (e) {
        debugPrint('getCurrentPosition failed/timed out, checking last known position: $e');
        try {
          position = await Geolocator.getLastKnownPosition();
        } catch (_) {}
      }

      // Fallback default coordinates if GPS positioning fails on emulator
      double lat = position?.latitude ?? 19.0760;
      double lng = position?.longitude ?? 72.8777;

      // 3. Reverse geocode coordinates to location data
      final LocationData? location = await GeocodingService.reverseGeocode(lat, lng);

      final result = location ??
          LocationData(
            latitude: lat,
            longitude: lng,
            displayName: 'Current Location (${lat.toStringAsFixed(3)}, ${lng.toStringAsFixed(3)})',
            city: 'Mumbai',
            region: 'Maharashtra',
            country: 'India',
          );

      await setSelectedLocation(result);

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      debugPrint('getCurrentDeviceLocation exception: $e');
      // Graceful fallback to default city
      final fallbackLocation = LocationData(
        latitude: 19.0760,
        longitude: 72.8777,
        displayName: 'Mumbai, Maharashtra, India',
        city: 'Mumbai',
        region: 'Maharashtra',
        country: 'India',
      );
      await setSelectedLocation(fallbackLocation);

      _isLoading = false;
      notifyListeners();
      return fallbackLocation;
    }
  }
}
