import 'notification_type.dart';

/// RiderMate 2.0 — User Notification Preferences & Quiet Settings
class NotificationPreferences {
  final String userId;
  final bool emergencyEnabled; // Always true/locked for safety
  final bool safetyEnabled;
  final bool rideEnabled;
  final bool socialEnabled;
  final bool aiEnabled;
  final bool maintenanceEnabled;
  final bool achievementEnabled;
  final bool systemEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;

  /// Quiet hours — 24h "HH:mm" format. Default: 22:00 → 07:00.
  /// Emergency notifications always bypass quiet hours.
  final String quietHoursStart;
  final String quietHoursEnd;

  const NotificationPreferences({
    required this.userId,
    this.emergencyEnabled = true,
    this.safetyEnabled = true,
    this.rideEnabled = true,
    this.socialEnabled = true,
    this.aiEnabled = true,
    this.maintenanceEnabled = true,
    this.achievementEnabled = true,
    this.systemEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '07:00',
  });

  bool isCategoryEnabled(NotificationType type) {
    switch (type) {
      case NotificationType.emergency:
        return true; // Cannot disable emergency notifications
      case NotificationType.safety:
        return safetyEnabled;
      case NotificationType.ride:
        return rideEnabled;
      case NotificationType.social:
        return socialEnabled;
      case NotificationType.ai:
        return aiEnabled;
      case NotificationType.maintenance:
        return maintenanceEnabled;
      case NotificationType.achievement:
        return achievementEnabled;
      case NotificationType.system:
        return systemEnabled;
    }
  }

  /// Returns true if [now] falls within the quiet hours window.
  /// Handles overnight windows (e.g. 22:00 → 07:00).
  /// Emergency notifications always bypass this check.
  bool isInQuietHours([DateTime? now]) {
    try {
      final current = now ?? DateTime.now();
      final startParts = quietHoursStart.split(':');
      final endParts = quietHoursEnd.split(':');
      if (startParts.length < 2 || endParts.length < 2) return false;

      final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
      final nowMinutes = current.hour * 60 + current.minute;

      if (startMinutes <= endMinutes) {
        // Same-day window (e.g. 09:00 → 17:00)
        return nowMinutes >= startMinutes && nowMinutes < endMinutes;
      } else {
        // Overnight window (e.g. 22:00 → 07:00)
        return nowMinutes >= startMinutes || nowMinutes < endMinutes;
      }
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'emergency_enabled': 1,
      'safety_enabled': safetyEnabled ? 1 : 0,
      'ride_enabled': rideEnabled ? 1 : 0,
      'social_enabled': socialEnabled ? 1 : 0,
      'ai_enabled': aiEnabled ? 1 : 0,
      'maintenance_enabled': maintenanceEnabled ? 1 : 0,
      'achievement_enabled': achievementEnabled ? 1 : 0,
      'system_enabled': systemEnabled ? 1 : 0,
      'sound_enabled': soundEnabled ? 1 : 0,
      'vibration_enabled': vibrationEnabled ? 1 : 0,
      'quiet_hours_start': quietHoursStart,
      'quiet_hours_end': quietHoursEnd,
    };
  }

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      userId: map['user_id'] as String? ?? 'user_guest',
      emergencyEnabled: true,
      safetyEnabled: (map['safety_enabled'] as int? ?? 1) == 1,
      rideEnabled: (map['ride_enabled'] as int? ?? 1) == 1,
      socialEnabled: (map['social_enabled'] as int? ?? 1) == 1,
      aiEnabled: (map['ai_enabled'] as int? ?? 1) == 1,
      maintenanceEnabled: (map['maintenance_enabled'] as int? ?? 1) == 1,
      achievementEnabled: (map['achievement_enabled'] as int? ?? 1) == 1,
      systemEnabled: (map['system_enabled'] as int? ?? 1) == 1,
      soundEnabled: (map['sound_enabled'] as int? ?? 1) == 1,
      vibrationEnabled: (map['vibration_enabled'] as int? ?? 1) == 1,
      quietHoursStart: map['quiet_hours_start'] as String? ?? '22:00',
      quietHoursEnd: map['quiet_hours_end'] as String? ?? '07:00',
    );
  }

  NotificationPreferences copyWith({
    String? userId,
    bool? safetyEnabled,
    bool? rideEnabled,
    bool? socialEnabled,
    bool? aiEnabled,
    bool? maintenanceEnabled,
    bool? achievementEnabled,
    bool? systemEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) {
    return NotificationPreferences(
      userId: userId ?? this.userId,
      emergencyEnabled: true,
      safetyEnabled: safetyEnabled ?? this.safetyEnabled,
      rideEnabled: rideEnabled ?? this.rideEnabled,
      socialEnabled: socialEnabled ?? this.socialEnabled,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      maintenanceEnabled: maintenanceEnabled ?? this.maintenanceEnabled,
      achievementEnabled: achievementEnabled ?? this.achievementEnabled,
      systemEnabled: systemEnabled ?? this.systemEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}
