enum CrashSeverity { none, minorFall, mediumCrash, majorCrash }

enum AlertLevel { info, warning, critical }

class CrashEvent {
  final String id;
  final DateTime timestamp;
  final CrashSeverity severity;
  final double gForce;
  final double latitude;
  final double longitude;

  const CrashEvent({
    required this.id,
    required this.timestamp,
    required this.severity,
    required this.gForce,
    required this.latitude,
    required this.longitude,
  });
}

class SafetyAlert {
  final String id;
  final String title;
  final String description;
  final AlertLevel level;
  final DateTime timestamp;

  const SafetyAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.timestamp,
  });
}

class LiveTrackingSession {
  final String sessionId;
  final String riderId;
  final DateTime startTime;
  final bool isActive;
  final List<String> sharedWithContactIds;

  const LiveTrackingSession({
    required this.sessionId,
    required this.riderId,
    required this.startTime,
    required this.isActive,
    required this.sharedWithContactIds,
  });
}
