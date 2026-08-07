class GroupRiderMarker {
  final String riderId;
  final String name;
  final String avatarUrl;
  final double latitude;
  final double longitude;
  final double speedKmh;
  final bool isLeader;

  const GroupRiderMarker({
    required this.riderId,
    required this.name,
    required this.avatarUrl,
    required this.latitude,
    required this.longitude,
    required this.speedKmh,
    required this.isLeader,
  });
}
