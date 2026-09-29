import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Immutable coordinate pair representation.
@immutable
class LocationCoordinates {
  final double latitude;
  final double longitude;

  const LocationCoordinates({
    required this.latitude,
    required this.longitude,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationCoordinates &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}

/// Helper for resolving customer location coordinates and launching maps.
abstract final class CustomerLocationHelper {
  /// Default center coordinates (Kuwait City).
  static const defaultCoordinates = LocationCoordinates(
    latitude: 29.3759,
    longitude: 47.9774,
  );

  /// Resolves customer coordinates from explicit lat/lng or textual address.
  static LocationCoordinates getCoordinates({
    String? address,
    double? latitude,
    double? longitude,
  }) {
    if (latitude != null &&
        longitude != null &&
        (latitude != 0.0 || longitude != 0.0)) {
      return LocationCoordinates(latitude: latitude, longitude: longitude);
    }

    if (address == null || address.trim().isEmpty) {
      return defaultCoordinates;
    }

    final lower = address.toLowerCase();

    if (lower.contains('salmiya') || lower.contains('سالمية')) {
      return const LocationCoordinates(latitude: 29.3344, longitude: 48.0828);
    }
    if (lower.contains('hawally') || lower.contains('حولي')) {
      return const LocationCoordinates(latitude: 29.3364, longitude: 48.0266);
    }
    if (lower.contains('sharq') ||
        lower.contains('شرق') ||
        lower.contains('kuwait city') ||
        lower.contains('مدينة الكويت')) {
      return const LocationCoordinates(latitude: 29.3820, longitude: 47.9890);
    }
    if (lower.contains('farwaniya') || lower.contains('فروانية')) {
      return const LocationCoordinates(latitude: 29.2780, longitude: 47.9580);
    }
    if (lower.contains('ahmadi') || lower.contains('أحمدي')) {
      return const LocationCoordinates(latitude: 29.0769, longitude: 48.0839);
    }
    if (lower.contains('jahra') || lower.contains('جهراء')) {
      return const LocationCoordinates(latitude: 29.3375, longitude: 47.6581);
    }

    return defaultCoordinates;
  }

  /// Opens the coordinates in external Google Maps app or browser.
  static Future<bool> openInGoogleMaps({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching map url: $e');
    }
    return false;
  }
}
