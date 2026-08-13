import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../core/theme.dart';
import '../models/location_data.dart';
import '../services/geocoding_service.dart';
import '../services/location_service.dart';
import 'map_picker_screen.dart';

// ─────────────────────────────────────────────
//  LOCATION SELECTION SCREEN
//  Allows user to search locations, use device GPS,
//  pick location on OpenStreetMap, or select region.
// ─────────────────────────────────────────────

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  bool _isSearching = false;
  List<LocationData> _searchResults = [];

  final List<String> _recentLocations = [
    'Gulberg Phase 4, Lahore',
    'Model Town, Lahore',
  ];

  final List<String> _regions = [
    'Punjab',
    'Sindh',
    'Khyber Pakhtunkhwa',
    'Balochistan',
    'Azad Kashmir',
    'Federal Capital',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      setState(() {
        _isSearching = true;
      });

      final results = await GeocodingService.searchLocations(query);

      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = results;
        });
      }
    });
  }

  void _selectAndReturnLocation(LocationData location) {
    LocationService.instance.setSelectedLocation(location);
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context, location);
    }
  }

  Future<void> _handleUseCurrentLocation() async {
    final location = await LocationService.instance.getCurrentDeviceLocation(
      onErrorState: (state, message) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.black87,
            action: state == LocationPermissionState.deniedForever
                ? SnackBarAction(
                    label: 'Settings',
                    textColor: AppColors.primary,
                    onPressed: () {
                      Geolocator.openAppSettings();
                    },
                  )
                : null,
          ),
        );
      },
    );

    if (location != null && mounted) {
      _selectAndReturnLocation(location);
    }
  }

  Future<void> _openMapPicker() async {
    final currentLocation = LocationService.instance.selectedLocation;
    final selected = await Navigator.push<LocationData>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(initialLocation: currentLocation),
      ),
    );

    if (selected != null && mounted) {
      _selectAndReturnLocation(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = LocationService.instance.selectedLocation;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Locations',
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.searchBarBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search,
                      color: AppColors.textMuted, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Search area, city or country',
                        hintStyle: TextStyle(
                            color: AppColors.textMuted, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear,
                          size: 18, color: AppColors.textMuted),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 1, color: AppColors.divider),

            // Use current location button
            ListTile(
              leading: const Icon(Icons.my_location,
                  color: AppColors.primary, size: 20),
              title: Text(
                'Use current location',
                style: AppTextStyles.productTitle.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'Get location using GPS',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              onTap: _handleUseCurrentLocation,
            ),
            const Divider(height: 1, color: AppColors.divider),

            // Select on Map button
            ListTile(
              leading:
                  const Icon(Icons.map, color: AppColors.primary, size: 20),
              title: Text(
                'Choose location on Map',
                style: AppTextStyles.productTitle.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'Drag pin on OpenStreetMap',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              trailing: const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.textMuted),
              onTap: _openMapPicker,
            ),
            const Divider(height: 1, color: AppColors.divider),

            // Search Results List
            if (_searchController.text.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Search Results',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 14),
                ),
              ),
              if (_isSearching)
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (_searchResults.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      'No matching locations found',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final item = _searchResults[index];
                    return ListTile(
                      leading: const Icon(Icons.place,
                          color: AppColors.primary, size: 20),
                      title: Text(
                        item.shortName,
                        style: AppTextStyles.productTitle
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        item.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                      ),
                      onTap: () => _selectAndReturnLocation(item),
                    );
                  },
                ),
            ] else ...[
              // Currently Selected Location Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Current Location',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 14),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.check_circle,
                    color: Colors.green, size: 20),
                title: Text(
                  currentLocation.shortName,
                  style: AppTextStyles.productTitle
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  currentLocation.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                ),
                onTap: () => _selectAndReturnLocation(currentLocation),
              ),
              const Divider(height: 1, color: AppColors.divider),

              // Recent Locations
              if (_recentLocations.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Locations',
                        style:
                            AppTextStyles.sectionTitle.copyWith(fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _recentLocations.clear();
                          });
                        },
                        child: Text(
                          'Clear all',
                          style: AppTextStyles.seeMore.copyWith(
                              fontSize: 12, color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentLocations.length,
                  itemBuilder: (context, index) {
                    final loc = _recentLocations[index];
                    return ListTile(
                      leading: const Icon(Icons.history,
                          color: AppColors.textMuted, size: 20),
                      title: Text(loc, style: AppTextStyles.productTitle),
                      onTap: () async {
                        final results =
                            await GeocodingService.searchLocations(loc);
                        if (results.isNotEmpty) {
                          _selectAndReturnLocation(results.first);
                        } else {
                          _selectAndReturnLocation(LocationData(
                            latitude: 31.5204,
                            longitude: 74.3587,
                            displayName: loc,
                          ));
                        }
                      },
                    );
                  },
                ),
              ],

              // Choose Region Section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  'Choose Region',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 14),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _regions.length,
                itemBuilder: (context, index) {
                  final region = _regions[index];
                  return ListTile(
                    title: Text(region, style: AppTextStyles.productTitle),
                    trailing: const Icon(Icons.chevron_right,
                        size: 18, color: AppColors.textMuted),
                    onTap: () async {
                      final results =
                          await GeocodingService.searchLocations(region);
                      if (results.isNotEmpty) {
                        _selectAndReturnLocation(results.first);
                      } else {
                        _selectAndReturnLocation(LocationData(
                          latitude: 31.5204,
                          longitude: 74.3587,
                          displayName: '$region, Pakistan',
                        ));
                      }
                    },
                  );
                },
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
