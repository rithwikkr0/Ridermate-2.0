/// RiderMate 2.0 — Canonical Story / Moment Model
class StoryModel {
  final String id;
  final String userId;
  final String authorName;
  final String authorAvatar;
  final String mediaUrl;
  final String caption;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String privacy; // 'friends', 'public'
  final bool isViewed;

  const StoryModel({
    required this.id,
    required this.userId,
    required this.authorName,
    this.authorAvatar = '',
    required this.mediaUrl,
    this.caption = '',
    required this.createdAt,
    required this.expiresAt,
    this.privacy = 'friends',
    this.isViewed = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'media_url': mediaUrl,
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'privacy': privacy,
    };
  }

  factory StoryModel.fromMap(Map<String, dynamic> map, {bool isViewed = false}) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return StoryModel(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      authorName: map['author_name'] as String? ?? 'Rider',
      authorAvatar: map['author_avatar'] as String? ?? '',
      mediaUrl: map['media_url'] as String? ?? '',
      caption: map['caption'] as String? ?? '',
      createdAt: parseDate(map['created_at']),
      expiresAt: parseDate(map['expires_at']),
      privacy: map['privacy'] as String? ?? 'friends',
      isViewed: isViewed,
    );
  }
}
