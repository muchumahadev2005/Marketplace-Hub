import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/location_service.dart';

// ─────────────────────────────────────────────
//  LOCATION BAR
//  Full-width white strip shown below the AppBar:
//    📍  Gulberg Phase 4, Lahore       >
//  Listens to LocationService to automatically display
//  the currently selected location.
// ─────────────────────────────────────────────

class LocationBar extends StatelessWidget {
  final String? location;
  final VoidCallback? onTap;

  const LocationBar({
    super.key,
    this.location,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocationService.instance,
      builder: (context, _) {
        final displayLocation = location ??
            LocationService.instance.selectedLocation.shortName;

        return GestureDetector(
          onTap: onTap ?? () {},
          child: Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Pin icon in OLX blue
                const Icon(Icons.location_on,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 6),
                // Location text — expands to fill available space
                Expanded(
                  child: Text(
                    displayLocation,
                    style: AppTextStyles.locationText,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Chevron indicating this is tappable
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                  size: 18,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
