import 'dart:math';

/// RiderMate 2.0 — Geo & Trajectory Math Utilities
/// Ported and enhanced from Project B geoUtils.ts
class GeoUtils {
  /// Calculates Haversine distance between two coordinates in kilometers.
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371.0; // Earth radius in km
    final double dLat = _degToRad(lat2 - lat1);
    final double dLon = _degToRad(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  static double _degToRad(double deg) => deg * (pi / 180.0);

  /// Converts speed in meters per second to kilometers per hour.
  static int formatSpeed(double? speedInMs) {
    if (speedInMs == null) return 0;
    return (speedInMs * 3.6).round();
  }

  /// Formats distance in kilometers into readable string (e.g. "850 m" or "12.50 km").
  static String formatDistance(double km) {
    if (km < 1.0) {
      return '${(km * 1000).round()} m';
    }
    return '${km.toStringAsFixed(2)} km';
  }

  /// Formats duration in milliseconds into a readable HH:MM:SS string.
  static String formatDuration(int ms) {
    final int totalSeconds = (ms / 1000).floor();
    final int hours = (totalSeconds / 3600).floor();
    final int minutes = ((totalSeconds % 3600) / 60).floor();
    final int seconds = totalSeconds % 60;

    final List<String> parts = [];
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0) parts.add('${minutes}m');
    parts.add('${seconds}s');

    return parts.join(' ');
  }
}
