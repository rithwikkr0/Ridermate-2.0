import 'package:flutter/foundation.dart';

enum RideMode { solo, group }

enum GroupRideState { draft, inviting, waiting, active, completed }

enum MemberStatus { invited, accepted, joined, sharingLocation, left, declined }

enum InvitationStatus { pending, accepted, declined, cancelled }

/// RiderMate 2.0 — Group Ride Participant Data Model
class GroupRideMember {
  final String userId;
  final String name;
  final String avatarUrl;
  final MemberStatus status;
  final bool isSharingLocation;
  final double latitude;
  final double longitude;
  final double speedKmh;
  final double heading;
  final String destinationName;
  final DateTime updatedAt;

  const GroupRideMember({
    required this.userId,
    required this.name,
    this.avatarUrl = '',
    this.status = MemberStatus.invited,
    this.isSharingLocation = true,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.speedKmh = 0.0,
    this.heading = 0.0,
    this.destinationName = '',
    required this.updatedAt,
  });

  GroupRideMember copyWith({
    String? userId,
    String? name,
    String? avatarUrl,
    MemberStatus? status,
    bool? isSharingLocation,
    double? latitude,
    double? longitude,
    double? speedKmh,
    double? heading,
    String? destinationName,
    DateTime? updatedAt,
  }) {
    return GroupRideMember(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      isSharingLocation: isSharingLocation ?? this.isSharingLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speedKmh: speedKmh ?? this.speedKmh,
      heading: heading ?? this.heading,
      destinationName: destinationName ?? this.destinationName,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'avatarUrl': avatarUrl,
        'status': status.name,
        'isSharingLocation': isSharingLocation,
        'latitude': latitude,
        'longitude': longitude,
        'speedKmh': speedKmh,
        'heading': heading,
        'destinationName': destinationName,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory GroupRideMember.fromJson(Map<String, dynamic> json) => GroupRideMember(
        userId: json['userId'] ?? '',
        name: json['name'] ?? '',
        avatarUrl: json['avatarUrl'] ?? '',
        status: MemberStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => MemberStatus.invited,
        ),
        isSharingLocation: json['isSharingLocation'] ?? false,
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
        speedKmh: (json['speedKmh'] as num?)?.toDouble() ?? 0.0,
        heading: (json['heading'] as num?)?.toDouble() ?? 0.0,
        destinationName: json['destinationName'] ?? '',
        updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      );
}

/// RiderMate 2.0 — Group Ride Invitation Model
class GroupRideInvitation {
  final String id;
  final String groupRideId;
  final String rideTitle;
  final String inviterName;
  final String inviteeUserId;
  final InvitationStatus status;
  final DateTime createdAt;

  const GroupRideInvitation({
    required this.id,
    required this.groupRideId,
    required this.rideTitle,
    required this.inviterName,
    required this.inviteeUserId,
    this.status = InvitationStatus.pending,
    required this.createdAt,
  });

  GroupRideInvitation copyWith({InvitationStatus? status}) {
    return GroupRideInvitation(
      id: id,
      groupRideId: groupRideId,
      rideTitle: rideTitle,
      inviterName: inviterName,
      inviteeUserId: inviteeUserId,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

/// RiderMate 2.0 — Group Ride Session Model
class GroupRideModel {
  final String id;
  final String title;
  final String startLocationName;
  final String destinationName;
  final double startLatitude;
  final double startLongitude;
  final double destLatitude;
  final double destLongitude;
  final String date;
  final String time;
  final String description;
  final GroupRideState state;
  final List<GroupRideMember> members;
  final List<GroupRideInvitation> invitations;
  final String createdByUserId;

  const GroupRideModel({
    required this.id,
    required this.title,
    required this.startLocationName,
    required this.destinationName,
    this.startLatitude = 0.0,
    this.startLongitude = 0.0,
    this.destLatitude = 0.0,
    this.destLongitude = 0.0,
    required this.date,
    required this.time,
    this.description = '',
    this.state = GroupRideState.inviting,
    this.members = const [],
    this.invitations = const [],
    required this.createdByUserId,
  });

  GroupRideModel copyWith({
    String? title,
    GroupRideState? state,
    List<GroupRideMember>? members,
    List<GroupRideInvitation>? invitations,
  }) {
    return GroupRideModel(
      id: id,
      title: title ?? this.title,
      startLocationName: startLocationName,
      destinationName: destinationName,
      startLatitude: startLatitude,
      startLongitude: startLongitude,
      destLatitude: destLatitude,
      destLongitude: destLongitude,
      date: date,
      time: time,
      description: description,
      state: state ?? this.state,
      members: members ?? this.members,
      invitations: invitations ?? this.invitations,
      createdByUserId: createdByUserId,
    );
  }
}
