/// RiderMate 2.0 — Canonical Squad & Group Ride Models

class SquadModel {
  final String id;
  final String creatorId;
  final String name;
  final String description;
  final String avatarUrl;
  final int memberCount;
  final bool isPrivate;
  final String inviteCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isMember;
  final String role; // 'owner', 'admin', 'member', 'none'

  const SquadModel({
    required this.id,
    required this.creatorId,
    required this.name,
    this.description = '',
    this.avatarUrl = '',
    this.memberCount = 1,
    this.isPrivate = false,
    required this.inviteCode,
    required this.createdAt,
    required this.updatedAt,
    this.isMember = false,
    this.role = 'none',
  });

  SquadModel copyWith({
    String? id,
    String? creatorId,
    String? name,
    String? description,
    String? avatarUrl,
    int? memberCount,
    bool? isPrivate,
    String? inviteCode,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isMember,
    String? role,
  }) {
    return SquadModel(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      memberCount: memberCount ?? this.memberCount,
      isPrivate: isPrivate ?? this.isPrivate,
      inviteCode: inviteCode ?? this.inviteCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isMember: isMember ?? this.isMember,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creator_id': creatorId,
      'name': name,
      'description': description,
      'avatar_url': avatarUrl,
      'member_count': memberCount,
      'is_private': isPrivate ? 1 : 0,
      'invite_code': inviteCode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SquadModel.fromMap(Map<String, dynamic> map, {bool isMember = false, String role = 'none'}) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return SquadModel(
      id: map['id'] as String,
      creatorId: map['creator_id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      avatarUrl: map['avatar_url'] as String? ?? '',
      memberCount: (map['member_count'] as num? ?? 1).toInt(),
      isPrivate: (map['is_private'] == 1 || map['is_private'] == true),
      inviteCode: map['invite_code'] as String? ?? '',
      createdAt: parseDate(map['created_at']),
      updatedAt: parseDate(map['updated_at']),
      isMember: isMember,
      role: role,
    );
  }
}

class SquadMemberModel {
  final String id;
  final String squadId;
  final String userId;
  final String username;
  final String fullName;
  final String photoUrl;
  final String role; // 'owner', 'admin', 'member'
  final DateTime joinedAt;

  const SquadMemberModel({
    required this.id,
    required this.squadId,
    required this.userId,
    required this.username,
    required this.fullName,
    this.photoUrl = '',
    this.role = 'member',
    required this.joinedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'squad_id': squadId,
      'user_id': userId,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  factory SquadMemberModel.fromMap(Map<String, dynamic> map, {Map<String, dynamic>? userMap}) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return SquadMemberModel(
      id: map['id'] as String,
      squadId: map['squad_id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      username: userMap?['username'] as String? ?? 'Rider',
      fullName: userMap?['full_name'] as String? ?? 'Squad Member',
      photoUrl: userMap?['photo_url'] as String? ?? '',
      role: map['role'] as String? ?? 'member',
      joinedAt: parseDate(map['joined_at']),
    );
  }
}

class GroupRideModel {
  final String id;
  final String? squadId;
  final String creatorId;
  final String creatorName;
  final String title;
  final String description;
  final DateTime startTime;
  final String startLocation;
  final String destination;
  final String status; // 'upcoming', 'active', 'completed', 'cancelled'
  final String privacy;
  final int memberCount;
  final bool isJoined;
  final bool isSharingLocation;
  final DateTime createdAt;

  const GroupRideModel({
    required this.id,
    this.squadId,
    required this.creatorId,
    required this.creatorName,
    required this.title,
    this.description = '',
    required this.startTime,
    this.startLocation = '',
    this.destination = '',
    this.status = 'upcoming',
    this.privacy = 'squad',
    this.memberCount = 1,
    this.isJoined = false,
    this.isSharingLocation = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'squad_id': squadId,
      'creator_id': creatorId,
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'start_location': startLocation,
      'destination': destination,
      'status': status,
      'privacy': privacy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory GroupRideModel.fromMap(
    Map<String, dynamic> map, {
    String creatorName = 'Leader',
    int memberCount = 1,
    bool isJoined = false,
    bool isSharingLocation = false,
  }) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return GroupRideModel(
      id: map['id'] as String,
      squadId: map['squad_id'] as String?,
      creatorId: map['creator_id'] as String? ?? '',
      creatorName: creatorName,
      title: map['title'] as String? ?? 'Group Ride',
      description: map['description'] as String? ?? '',
      startTime: parseDate(map['start_time']),
      startLocation: map['start_location'] as String? ?? '',
      destination: map['destination'] as String? ?? '',
      status: map['status'] as String? ?? 'upcoming',
      privacy: map['privacy'] as String? ?? 'squad',
      memberCount: memberCount,
      isJoined: isJoined,
      isSharingLocation: isSharingLocation,
      createdAt: parseDate(map['created_at']),
    );
  }
}
