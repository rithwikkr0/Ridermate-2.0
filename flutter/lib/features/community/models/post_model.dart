import 'dart:convert';

enum PostType {
  text,
  photo,
  ride,
  memory,
  achievement,
  challenge,
  groupRide,
  safetyMilestone;

  static PostType fromString(String val) {
    return PostType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => PostType.text,
    );
  }
}

enum PostPrivacy {
  public,
  friends,
  private;

  static PostPrivacy fromString(String val) {
    return PostPrivacy.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => PostPrivacy.friends,
    );
  }
}

/// RiderMate 2.0 — Canonical Social Post Model
class PostModel {
  final String id;
  final String userId;
  final String authorName;
  final String authorAvatar;
  final PostType type;
  final String caption;
  final String mediaUrl;
  final String thumbnailUrl;
  final String? rideId;
  final String? memoryId;
  final PostPrivacy privacy;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int saveCount;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isLikedByMe;
  final bool isSavedByMe;
  final Map<String, dynamic>? rideStats;

  const PostModel({
    required this.id,
    required this.userId,
    required this.authorName,
    this.authorAvatar = '',
    this.type = PostType.text,
    this.caption = '',
    this.mediaUrl = '',
    this.thumbnailUrl = '',
    this.rideId,
    this.memoryId,
    this.privacy = PostPrivacy.friends,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.saveCount = 0,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
    this.isLikedByMe = false,
    this.isSavedByMe = false,
    this.rideStats,
  });

  PostModel copyWith({
    String? id,
    String? userId,
    String? authorName,
    String? authorAvatar,
    PostType? type,
    String? caption,
    String? mediaUrl,
    String? thumbnailUrl,
    String? rideId,
    String? memoryId,
    PostPrivacy? privacy,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    int? saveCount,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isLikedByMe,
    bool? isSavedByMe,
    Map<String, dynamic>? rideStats,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      type: type ?? this.type,
      caption: caption ?? this.caption,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      rideId: rideId ?? this.rideId,
      memoryId: memoryId ?? this.memoryId,
      privacy: privacy ?? this.privacy,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      saveCount: saveCount ?? this.saveCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      isSavedByMe: isSavedByMe ?? this.isSavedByMe,
      rideStats: rideStats ?? this.rideStats,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'type': type.name,
      'caption': caption,
      'media_url': mediaUrl,
      'thumbnail_url': thumbnailUrl,
      'ride_id': rideId,
      'memory_id': memoryId,
      'privacy': privacy.name,
      'like_count': likeCount,
      'comment_count': commentCount,
      'share_count': shareCount,
      'save_count': saveCount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PostModel.fromMap(
    Map<String, dynamic> map, {
    bool isLiked = false,
    bool isSaved = false,
    Map<String, dynamic>? rideStats,
  }) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return PostModel(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      authorName: map['author_name'] as String? ?? 'Rider',
      authorAvatar: map['author_avatar'] as String? ?? '',
      type: PostType.fromString(map['type'] as String? ?? 'text'),
      caption: map['caption'] as String? ?? '',
      mediaUrl: map['media_url'] as String? ?? '',
      thumbnailUrl: map['thumbnail_url'] as String? ?? '',
      rideId: map['ride_id'] as String?,
      memoryId: map['memory_id'] as String?,
      privacy: PostPrivacy.fromString(map['privacy'] as String? ?? 'friends'),
      likeCount: (map['like_count'] as num? ?? 0).toInt(),
      commentCount: (map['comment_count'] as num? ?? 0).toInt(),
      shareCount: (map['share_count'] as num? ?? 0).toInt(),
      saveCount: (map['save_count'] as num? ?? 0).toInt(),
      status: map['status'] as String? ?? 'active',
      createdAt: parseDate(map['created_at']),
      updatedAt: parseDate(map['updated_at']),
      isLikedByMe: isLiked,
      isSavedByMe: isSaved,
      rideStats: rideStats,
    );
  }
}
