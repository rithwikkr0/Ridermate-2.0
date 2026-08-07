/// RiderMate 2.0 — Mock Data
/// All dummy data for UI-only phase. Replace with API responses later.
library;

// ── Models ──────────────────────────────────────────────────────────────────

class RideModel {
  final String id;
  final String title;
  final String distance;
  final String duration;
  final String avgSpeed;
  final String maxSpeed;
  final String elevation;
  final String calories;
  final String date;
  final String timeAgo;
  final String routeType;

  const RideModel({
    required this.id,
    required this.title,
    required this.distance,
    required this.duration,
    required this.avgSpeed,
    required this.maxSpeed,
    required this.elevation,
    required this.calories,
    required this.date,
    required this.timeAgo,
    required this.routeType,
  });
}

class UserModel {
  final String id;
  final String name;
  final String username;
  final String avatarUrl;
  final String bio;
  final String location;
  final String totalDistance;
  final String totalRides;
  final String totalTime;
  final String level;
  final int xp;
  final int xpToNext;
  final String memberSince;

  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarUrl,
    required this.bio,
    required this.location,
    required this.totalDistance,
    required this.totalRides,
    required this.totalTime,
    required this.level,
    required this.xp,
    required this.xpToNext,
    required this.memberSince,
  });
}

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;
  final String progress;
  final String category;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    required this.progress,
    required this.category,
  });
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String time;
  final String type;
  final bool read;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    required this.read,
  });
}

class SquadModel {
  final String id;
  final String name;
  final String description;
  final int memberCount;
  final String totalDistance;
  final String location;
  final String coverEmoji;

  const SquadModel({
    required this.id,
    required this.name,
    required this.description,
    required this.memberCount,
    required this.totalDistance,
    required this.location,
    required this.coverEmoji,
  });
}

class ChatMessageModel {
  final String id;
  final String sender;
  final String message;
  final String time;
  final bool isMe;

  const ChatMessageModel({
    required this.id,
    required this.sender,
    required this.message,
    required this.time,
    required this.isMe,
  });
}

class AiMessageModel {
  final String id;
  final String content;
  final bool isUser;
  final String time;

  const AiMessageModel({
    required this.id,
    required this.content,
    required this.isUser,
    required this.time,
  });
}

// ── Mock Data ───────────────────────────────────────────────────────────────

class MockData {
  MockData._();

  // Current User
  static const UserModel currentUser = UserModel(
    id: 'user_001',
    name: 'John Rider',
    username: '@johnrider',
    avatarUrl: 'https://i.pravatar.cc/150?img=33',
    bio: 'Mountain biker & road cyclist. KTM Duke 390 🏍️ Exploring every road.',
    location: 'Mumbai, India',
    totalDistance: '1,248 km',
    totalRides: '42',
    totalTime: '68h 30m',
    level: 'Elite Rider',
    xp: 8450,
    xpToNext: 10000,
    memberSince: 'Jan 2024',
  );

  // Recent Rides
  static const List<RideModel> recentRides = [
    RideModel(
      id: 'ride_001',
      title: 'Morning Ascent',
      distance: '42.5 km',
      duration: '1h 45m',
      avgSpeed: '28.2 km/h',
      maxSpeed: '56 km/h',
      elevation: '420 m',
      calories: '840 kcal',
      date: 'Today, 6:30 AM',
      timeAgo: 'Yesterday',
      routeType: 'Mountain',
    ),
    RideModel(
      id: 'ride_002',
      title: 'City Loop',
      distance: '15.0 km',
      duration: '42m',
      avgSpeed: '22.4 km/h',
      maxSpeed: '38 km/h',
      elevation: '45 m',
      calories: '320 kcal',
      date: 'Wed, 7:00 AM',
      timeAgo: 'Wednesday',
      routeType: 'Urban',
    ),
    RideModel(
      id: 'ride_003',
      title: 'Coastal Express',
      distance: '67.8 km',
      duration: '2h 20m',
      avgSpeed: '31.4 km/h',
      maxSpeed: '62 km/h',
      elevation: '180 m',
      calories: '1,240 kcal',
      date: 'Mon, 5:45 AM',
      timeAgo: 'Monday',
      routeType: 'Coastal',
    ),
    RideModel(
      id: 'ride_004',
      title: 'Weekend Grind',
      distance: '89.2 km',
      duration: '3h 10m',
      avgSpeed: '29.8 km/h',
      maxSpeed: '58 km/h',
      elevation: '820 m',
      calories: '1,760 kcal',
      date: 'Sat, 5:15 AM',
      timeAgo: 'Last Saturday',
      routeType: 'Mixed',
    ),
  ];

  // Dashboard stats
  static const Map<String, String> weeklyStats = {
    'distance': '120 km',
    'rides': '5',
    'time': '4h 20m',
    'calories': '3,200',
    'elevation': '1,240 m',
    'avgSpeed': '27.6 km/h',
  };

  static const Map<String, String> aiInsights = {
    'readiness': '92',
    'readinessLabel': 'Optimal recovery detected. Push for a PR today.',
    'conditions': 'Tailwind E 15km/h',
    'conditionsLabel': 'Favorable for coastal routes.',
    'weatherIcon': 'light_mode',
    'temperature': '24°',
    'battery': '88%',
  };

  // Achievements
  static const List<AchievementModel> achievements = [
    AchievementModel(
      id: 'ach_001',
      title: 'Century Rider',
      description: 'Complete a 100km ride',
      icon: '🏅',
      unlocked: true,
      progress: '100%',
      category: 'Distance',
    ),
    AchievementModel(
      id: 'ach_002',
      title: 'Dawn Patrol',
      description: '10 rides before 6 AM',
      icon: '🌅',
      unlocked: true,
      progress: '100%',
      category: 'Habit',
    ),
    AchievementModel(
      id: 'ach_003',
      title: 'Mountain Goat',
      description: 'Climb 5,000m total elevation',
      icon: '⛰️',
      unlocked: false,
      progress: '68%',
      category: 'Elevation',
    ),
    AchievementModel(
      id: 'ach_004',
      title: 'Speed Demon',
      description: 'Reach 70 km/h top speed',
      icon: '⚡',
      unlocked: false,
      progress: '82%',
      category: 'Speed',
    ),
    AchievementModel(
      id: 'ach_005',
      title: 'Iron Week',
      description: 'Ride every day for 7 days',
      icon: '🔥',
      unlocked: true,
      progress: '100%',
      category: 'Consistency',
    ),
    AchievementModel(
      id: 'ach_006',
      title: 'Social Butterfly',
      description: 'Join 3 group rides',
      icon: '🦋',
      unlocked: false,
      progress: '33%',
      category: 'Social',
    ),
  ];

  // Notifications
  static const List<NotificationModel> notifications = [
    NotificationModel(
      id: 'notif_001',
      title: 'New Personal Record! 🎉',
      body: 'You set a new best on Morning Ascent — 28.2 km/h avg',
      time: '2 min ago',
      type: 'achievement',
      read: false,
    ),
    NotificationModel(
      id: 'notif_002',
      title: 'AI Coach Insight',
      body: 'Your recovery score is 92 — great day to push hard.',
      time: '1 hour ago',
      type: 'ai',
      read: false,
    ),
    NotificationModel(
      id: 'notif_003',
      title: 'Squad Update',
      body: 'Mumbai Riders just completed a group ride — 15 members.',
      time: '3 hours ago',
      type: 'social',
      read: true,
    ),
    NotificationModel(
      id: 'notif_004',
      title: 'Weekly Summary Ready',
      body: 'You rode 120 km this week. Top 8% of all riders.',
      time: 'Yesterday',
      type: 'summary',
      read: true,
    ),
    NotificationModel(
      id: 'notif_005',
      title: 'Route Suggestion',
      body: 'New scenic route added near you: Coastal Cliffs — 48 km.',
      time: '2 days ago',
      type: 'route',
      read: true,
    ),
  ];

  // Squads
  static const List<SquadModel> squads = [
    SquadModel(
      id: 'squad_001',
      name: 'Mumbai Riders',
      description: 'Coastal city explorers. Weekend rides every Saturday.',
      memberCount: 128,
      totalDistance: '24,500 km',
      location: 'Mumbai, India',
      coverEmoji: '🏙️',
    ),
    SquadModel(
      id: 'squad_002',
      name: 'Western Ghats Crew',
      description: 'Mountain climbers chasing elevation. KTM & Royal Enfield riders.',
      memberCount: 56,
      totalDistance: '18,200 km',
      location: 'Pune, India',
      coverEmoji: '⛰️',
    ),
    SquadModel(
      id: 'squad_003',
      name: 'Dawn Patrol Squad',
      description: 'Early birds only. 5 AM start, no exceptions.',
      memberCount: 34,
      totalDistance: '9,800 km',
      location: 'Bangalore, India',
      coverEmoji: '🌅',
    ),
  ];

  // AI chat messages
  static const List<AiMessageModel> aiMessages = [
    AiMessageModel(
      id: 'ai_001',
      content: 'Good morning, John! Your recovery score is 92 today — optimal for a hard effort. The tailwind from the east will give you a 3-5% speed boost on coastal routes.',
      isUser: false,
      time: '6:30 AM',
    ),
    AiMessageModel(
      id: 'ai_002',
      content: 'What route would you suggest for 45 km today?',
      isUser: true,
      time: '6:31 AM',
    ),
    AiMessageModel(
      id: 'ai_003',
      content: 'Based on your fitness, weather, and traffic data, I recommend the Coastal Cliffs route (48 km). You\'ll have tailwind for the first 30 km and the temperature peaks at 11 AM — perfect for your pace.',
      isUser: false,
      time: '6:31 AM',
    ),
  ];

  // Vehicle (Bike)
  static const Map<String, String> vehicle = {
    'name': 'KTM Duke 390',
    'fuel': '80%',
    'odometer': '12,450 km',
    'lastService': '11,200 km',
    'nextService': '13,200 km',
    'tirePresure': '32 PSI',
    'status': 'Ready',
  };

  // Leaderboard
  static const List<Map<String, String>> leaderboard = [
    {'rank': '1', 'name': 'Arjun K.', 'distance': '284 km', 'avatar': 'https://i.pravatar.cc/40?img=1'},
    {'rank': '2', 'name': 'Priya S.', 'distance': '256 km', 'avatar': 'https://i.pravatar.cc/40?img=5'},
    {'rank': '3', 'name': 'John Rider', 'distance': '248 km', 'avatar': 'https://i.pravatar.cc/40?img=33'},
    {'rank': '4', 'name': 'Rahul M.', 'distance': '221 km', 'avatar': 'https://i.pravatar.cc/40?img=12'},
    {'rank': '5', 'name': 'Divya R.', 'distance': '198 km', 'avatar': 'https://i.pravatar.cc/40?img=9'},
    {'rank': '6', 'name': 'Kiran P.', 'distance': '187 km', 'avatar': 'https://i.pravatar.cc/40?img=15'},
  ];

  // Emergency contacts
  static const List<Map<String, String>> emergencyContacts = [
    {'name': 'Ramesh Rider', 'relation': 'Father', 'phone': '+91 98765 43210', 'avatar': 'https://i.pravatar.cc/40?img=60'},
    {'name': 'Meera Rider', 'relation': 'Mother', 'phone': '+91 98765 43211', 'avatar': 'https://i.pravatar.cc/40?img=47'},
    {'name': 'Amit Kumar', 'relation': 'Friend', 'phone': '+91 98765 43212', 'avatar': 'https://i.pravatar.cc/40?img=7'},
  ];
}
