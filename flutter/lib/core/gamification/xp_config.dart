class XpConfig {
  static const int rideCompletedBase = 50;
  static const int safeRide = 75;
  static const int memoryCreated = 25;
  static const int communityPost = 20;
  static const int helpfulComment = 10;
  static const int groupRideCompleted = 100;
  static const int maintenanceCompleted = 50;
  static const int friendAdded = 30;

  static const int milestone100km = 200;
  static const int milestone500km = 200;
  static const int milestone1000km = 200;

  // Level Thresholds
  static const Map<String, int> levelThresholds = {
    'Novice': 0,
    'Explorer': 500,
    'Commuter': 1500,
    'Tourer': 3500,
    'Adventurer': 7000,
    'Expert': 12000,
    'Master': 20000,
    'Legend': 35000,
  };

  static String getLevelForXp(int xp) {
    String currentLevel = 'Novice';
    for (final entry in levelThresholds.entries) {
      if (xp >= entry.value) {
        currentLevel = entry.key;
      } else {
        break;
      }
    }
    return currentLevel;
  }
}
