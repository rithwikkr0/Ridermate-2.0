abstract class MonitoringService {
  void recordMetric(String name, double value);
  void logEvent(String name, Map<String, dynamic> properties);
  bool isFeatureEnabled(String flagName);
}

class MockMonitoringService implements MonitoringService {
  final Map<String, bool> _featureFlags = {
    'dark_mode': true,
    'ai_copilot': true,
    'live_tracking': true,
    'telemetry_v2': false,
  };

  @override
  void recordMetric(String name, double value) {}

  @override
  void logEvent(String name, Map<String, dynamic> properties) {}

  @override
  bool isFeatureEnabled(String flagName) {
    return _featureFlags[flagName] ?? false;
  }
}
