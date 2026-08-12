import 'package:flutter/material.dart';

/// RiderMate 2.0 — Canonical Notification Categories
enum NotificationType {
  emergency,
  safety,
  ride,
  social,
  ai,
  maintenance,
  achievement,
  system;

  static NotificationType fromString(String val) {
    return NotificationType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => NotificationType.system,
    );
  }

  String get displayName {
    switch (this) {
      case NotificationType.emergency:
        return 'Emergency';
      case NotificationType.safety:
        return 'Safety Alert';
      case NotificationType.ride:
        return 'Ride Telemetry';
      case NotificationType.social:
        return 'Social & Squad';
      case NotificationType.ai:
        return 'AI Co-Pilot';
      case NotificationType.maintenance:
        return 'Maintenance';
      case NotificationType.achievement:
        return 'Achievement';
      case NotificationType.system:
        return 'System Alert';
    }
  }

  String get channelId => 'ridermate_$name';
  String get channelName => 'RiderMate $displayName';

  IconData get icon {
    switch (this) {
      case NotificationType.emergency:
        return Icons.emergency_rounded;
      case NotificationType.safety:
        return Icons.security_rounded;
      case NotificationType.ride:
        return Icons.directions_bike_rounded;
      case NotificationType.social:
        return Icons.people_rounded;
      case NotificationType.ai:
        return Icons.psychology_rounded;
      case NotificationType.maintenance:
        return Icons.build_rounded;
      case NotificationType.achievement:
        return Icons.emoji_events_rounded;
      case NotificationType.system:
        return Icons.notifications_rounded;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.emergency:
        return const Color(0xFFFF3B30); // Vibrant Emergency Red
      case NotificationType.safety:
        return const Color(0xFFFF9500); // Safety Orange
      case NotificationType.ride:
        return const Color(0xFFFF6B00); // RiderMate Circuit Orange
      case NotificationType.social:
        return const Color(0xFF34C759); // Social Green
      case NotificationType.ai:
        return const Color(0xFFAF52DE); // AI Purple
      case NotificationType.maintenance:
        return const Color(0xFF5AC8FA); // Blue
      case NotificationType.achievement:
        return const Color(0xFFFFCC00); // Gold
      case NotificationType.system:
        return const Color(0xFF8E8E93); // Neutral Grey
    }
  }
}

/// Notification Urgency / Importance
enum NotificationPriority {
  low,
  normal,
  high,
  emergency;

  static NotificationPriority fromString(String val) {
    return NotificationPriority.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => NotificationPriority.normal,
    );
  }
}
