import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';

/// Embedded interactive Google Map preview displaying a single customer marker.
class CustomerMapPreview extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String customerName;
  final String address;

  const CustomerMapPreview({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.customerName,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    final position = LatLng(latitude, longitude);

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      clipBehavior: Clip.antiAlias,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: position,
          zoom: 15.0,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('customer_location'),
            position: position,
            infoWindow: InfoWindow(
              title: customerName,
              snippet: address,
            ),
          ),
        },
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: false,
        tiltGesturesEnabled: false,
        rotateGesturesEnabled: false,
        gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
      ),
    );
  }
}
