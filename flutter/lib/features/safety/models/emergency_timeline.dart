class TimelineEvent {
  final String title;
  final String description;
  final DateTime timestamp;
  final String iconName;

  const TimelineEvent({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.iconName,
  });
}

class EmergencyTimeline {
  final List<TimelineEvent> _events = [];

  List<TimelineEvent> get events => List.unmodifiable(_events);

  void logEvent(String title, String description, String iconName) {
    _events.add(TimelineEvent(
      title: title,
      description: description,
      timestamp: DateTime.now(),
      iconName: iconName,
    ));
  }

  void clear() => _events.clear();
}
