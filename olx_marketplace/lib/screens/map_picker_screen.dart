import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/theme.dart';
import '../models/location_data.dart';
import '../services/geocoding_service.dart';

// ─────────────────────────────────────────────
//  MAP PICKER SCREEN (OpenStreetMap)
//  Interactive map location selection screen using flutter_map
//  and OpenStreetMap tiles.
// ─────────────────────────────────────────────

class MapPickerScreen extends StatefulWidget {
  final LocationData initialLocation;

  const MapPickerScreen({
    super.key,
    required this.initialLocation,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late final MapController _mapController;
  late LatLng _currentCenter;
  late String _locationName;
  bool _isGeocoding = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentCenter = LatLng(
      widget.initialLocation.latitude,
      widget.initialLocation.longitude,
    );
    _locationName = widget.initialLocation.displayName;
  }

  Future<void> _updateLocationFromCenter(LatLng center) async {
    setState(() {
      _currentCenter = center;
      _isGeocoding = true;
    });

    final LocationData? geoData = await GeocodingService.reverseGeocode(
      center.latitude,
      center.longitude,
    );

    if (mounted) {
      setState(() {
        _isGeocoding = false;
        if (geoData != null) {
          _locationName = geoData.displayName;
        } else {
          _locationName =
              '${center.latitude.toStringAsFixed(4)}, ${center.longitude.toStringAsFixed(4)}';
        }
      });
    }
  }

  void _confirmLocation() {
    final selected = LocationData(
      latitude: _currentCenter.latitude,
      longitude: _currentCenter.longitude,
      displayName: _locationName,
    );
    Navigator.of(context).pop(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choose Location',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 15.0,
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture) {
                  _currentCenter = camera.center;
                }
              },
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  _updateLocationFromCenter(_currentCenter);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.olx.marketplace',
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    '© OpenStreetMap contributors',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
          // Centered Marker Pin
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 36),
              child: Icon(
                Icons.location_on,
                size: 48,
                color: AppColors.primary,
              ),
            ),
          ),
          // Bottom Card with Location Name and Confirm Button
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.place, color: AppColors.primary, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isGeocoding ? 'Fetching location...' : _locationName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: _confirmLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Confirm Location',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
