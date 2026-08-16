enum FriendshipStatus {
  none,
  requestSent,
  requestReceived,
  friends,
  blocked;

  static FriendshipStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'accepted':
      case 'friends':
        return FriendshipStatus.friends;
      case 'request_sent':
      case 'sent':
        return FriendshipStatus.requestSent;
      case 'request_received':
      case 'received':
      case 'pending':
        return FriendshipStatus.requestReceived;
      case 'blocked':
        return FriendshipStatus.blocked;
      default:
        return FriendshipStatus.none;
    }
  }
}

/// RiderMate 2.0 — Friend Relationship Data Model
class FriendModel {
  final String id;
  final String userId;
  final String friendId;
  final String username;
  final String fullName;
  final String photoUrl;
  final String bio;
  final String riderLevel;
  final int totalRides;
  final double distanceKm;
  final String status; // 'accepted', 'pending', 'blocked'
  final DateTime createdAt;

  const FriendModel({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.username,
    required this.fullName,
    this.photoUrl = '',
    this.bio = '',
    this.riderLevel = 'Rider',
    this.totalRides = 0,
    this.distanceKm = 0.0,
    this.status = 'accepted',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'friend_id': friendId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory FriendModel.fromMap(Map<String, dynamic> map, {Map<String, dynamic>? userMap}) {
    return FriendModel(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      friendId: map['friend_id'] as String? ?? '',
      username: userMap?['username'] as String? ?? 'Rider',
      fullName: userMap?['full_name'] as String? ?? 'RiderMate Friend',
      photoUrl: userMap?['photo_url'] as String? ?? '',
      bio: userMap?['bio'] as String? ?? '',
      riderLevel: userMap?['rider_level'] as String? ?? 'Rider',
      totalRides: (userMap?['total_rides'] as num? ?? 0).toInt(),
      distanceKm: (userMap?['distance_km'] as num? ?? 0.0).toDouble(),
      status: map['status'] as String? ?? 'accepted',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// RiderMate 2.0 — Friend Request Model
class FriendRequestModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String senderName;
  final String senderPhotoUrl;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;

  const FriendRequestModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    this.senderPhotoUrl = '',
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FriendRequestModel.fromMap(Map<String, dynamic> map, {Map<String, dynamic>? senderUserMap, Map<String, dynamic>? receiverUserMap}) {
    final userMap = senderUserMap ?? receiverUserMap;
    return FriendRequestModel(
      id: map['id'] as String,
      senderId: map['sender_id'] as String? ?? '',
      receiverId: map['receiver_id'] as String? ?? '',
      senderName: userMap?['full_name'] as String? ?? userMap?['username'] as String? ?? 'Rider',
      senderPhotoUrl: userMap?['photo_url'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
