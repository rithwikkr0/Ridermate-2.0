import 'dart:async';
import '../../../core/services/location_service.dart';
import '../../../providers/base_controller.dart';
import '../models/group_ride_model.dart';

/// RiderMate 2.0 — Group Ride Controller
/// Manages Group Ride lifecycle, invitation state machine, location sharing consent,
/// and live member coordinate streaming.
class GroupRideController extends BaseController {
  final LocationService locationService;
  StreamSubscription? _locationSubscription;

  GroupRideModel? _activeGroupRide;
  GroupRideModel? get activeGroupRide => _activeGroupRide;

  final List<GroupRideInvitation> _myInvitations = [];
  List<GroupRideInvitation> get myInvitations => List.unmodifiable(_myInvitations);

  bool _isLocationSharingEnabled = true;
  bool get isLocationSharingEnabled => _isLocationSharingEnabled;

  double _lastBroadcastLat = 0.0;
  double _lastBroadcastLng = 0.0;
  DateTime? _lastBroadcastTime;

  GroupRideController({LocationService? locationService})
      : locationService = locationService ?? const DeviceLocationService() {
    _initSampleData();
  }

  void _initSampleData() {
    _myInvitations.add(
      GroupRideInvitation(
        id: 'inv_101',
        groupRideId: 'grp_weekend_ride',
        rideTitle: 'Bengaluru → Nandi Hills Morning Pass',
        inviterName: 'Rahul Sharma',
        inviteeUserId: 'current_user',
        status: InvitationStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    );
  }

  /// Create a new Group Ride
  Future<GroupRideModel> createGroupRide({
    required String title,
    required String startLocation,
    required String destination,
    required String date,
    required String time,
    String description = '',
    required String currentUserName,
    required String currentUserId,
  }) async {
    final newRide = GroupRideModel(
      id: 'grp_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      startLocationName: startLocation,
      destinationName: destination,
      date: date,
      time: time,
      description: description,
      state: GroupRideState.active,
      createdByUserId: currentUserId,
      members: [
        GroupRideMember(
          userId: currentUserId,
          name: '$currentUserName (You)',
          status: MemberStatus.sharingLocation,
          isSharingLocation: true,
          destinationName: destination,
          updatedAt: DateTime.now(),
        ),
      ],
    );

    _activeGroupRide = newRide;
    _startLocationBroadcaster();
    notifyListeners();
    return newRide;
  }

  /// Invite a friend to the active group ride
  void inviteFriend(String friendName, String friendUserId) {
    if (_activeGroupRide == null) return;

    final newInv = GroupRideInvitation(
      id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
      groupRideId: _activeGroupRide!.id,
      rideTitle: _activeGroupRide!.title,
      inviterName: 'You',
      inviteeUserId: friendUserId,
      status: InvitationStatus.pending,
      createdAt: DateTime.now(),
    );

    final updatedInvites = [..._activeGroupRide!.invitations, newInv];
    final updatedMembers = [
      ..._activeGroupRide!.members,
      GroupRideMember(
        userId: friendUserId,
        name: friendName,
        status: MemberStatus.invited,
        isSharingLocation: false,
        updatedAt: DateTime.now(),
      ),
    ];

    _activeGroupRide = _activeGroupRide!.copyWith(
      invitations: updatedInvites,
      members: updatedMembers,
    );
    notifyListeners();
  }

  /// Accept an invitation to join a group ride
  void acceptInvitation(String invitationId, String currentUserId, String currentUserName) {
    final invIdx = _myInvitations.indexWhere((i) => i.id == invitationId);
    if (invIdx != -1) {
      _myInvitations[invIdx] =
          _myInvitations[invIdx].copyWith(status: InvitationStatus.accepted);

      // Join active ride
      _activeGroupRide = GroupRideModel(
        id: _myInvitations[invIdx].groupRideId,
        title: _myInvitations[invIdx].rideTitle,
        startLocationName: 'Current Location',
        destinationName: 'Group Destination',
        date: 'Today',
        time: 'Now',
        state: GroupRideState.active,
        createdByUserId: _myInvitations[invIdx].inviterName,
        members: [
          GroupRideMember(
            userId: 'user_host',
            name: _myInvitations[invIdx].inviterName,
            status: MemberStatus.sharingLocation,
            isSharingLocation: true,
            updatedAt: DateTime.now(),
          ),
          GroupRideMember(
            userId: currentUserId,
            name: '$currentUserName (You)',
            status: MemberStatus.sharingLocation,
            isSharingLocation: true,
            updatedAt: DateTime.now(),
          ),
        ],
      );

      _startLocationBroadcaster();
      notifyListeners();
    }
  }

  /// Decline an invitation
  void declineInvitation(String invitationId) {
    final invIdx = _myInvitations.indexWhere((i) => i.id == invitationId);
    if (invIdx != -1) {
      _myInvitations[invIdx] =
          _myInvitations[invIdx].copyWith(status: InvitationStatus.declined);
      notifyListeners();
    }
  }

  /// Explicit privacy toggle for location sharing (ON/OFF)
  void toggleLocationSharing(bool isSharing) {
    _isLocationSharingEnabled = isSharing;
    if (_activeGroupRide != null) {
      final updatedMembers = _activeGroupRide!.members.map((m) {
        if (m.name.contains('(You)')) {
          return m.copyWith(
            isSharingLocation: isSharing,
            status: isSharing ? MemberStatus.sharingLocation : MemberStatus.joined,
          );
        }
        return m;
      }).toList();

      _activeGroupRide = _activeGroupRide!.copyWith(members: updatedMembers);
    }
    notifyListeners();
  }

  /// Leave the active group ride
  void leaveGroupRide() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    if (_activeGroupRide != null) {
      final updatedMembers = _activeGroupRide!.members.map((m) {
        if (m.name.contains('(You)')) {
          return m.copyWith(
            status: MemberStatus.left,
            isSharingLocation: false,
          );
        }
        return m;
      }).toList();

      _activeGroupRide = _activeGroupRide!.copyWith(
        members: updatedMembers,
        state: GroupRideState.completed,
      );
    }
    notifyListeners();
  }

  /// Battery & movement throttled live location broadcaster
  void _startLocationBroadcaster() {
    _locationSubscription?.cancel();
    _locationSubscription = locationService.getLocationStream().listen(
      (point) {
        if (!point.isValid) return;

        final now = DateTime.now();
        final distChanged = (_lastBroadcastLat - point.latitude).abs() > 0.0001 ||
            (_lastBroadcastLng - point.longitude).abs() > 0.0001;
        final timeElapsed = _lastBroadcastTime == null ||
            now.difference(_lastBroadcastTime!).inSeconds >= 5;

        // Throttle check to prevent high-frequency excessive updates
        if (distChanged || timeElapsed) {
          _lastBroadcastLat = point.latitude;
          _lastBroadcastLng = point.longitude;
          _lastBroadcastTime = now;

          if (_activeGroupRide != null && _isLocationSharingEnabled) {
            final updatedMembers = _activeGroupRide!.members.map((m) {
              if (m.name.contains('(You)')) {
                return m.copyWith(
                  latitude: point.latitude,
                  longitude: point.longitude,
                  speedKmh: point.speed,
                  heading: point.heading,
                  updatedAt: now,
                );
              }
              return m;
            }).toList();

            _activeGroupRide = _activeGroupRide!.copyWith(members: updatedMembers);
            notifyListeners();
          }
        }
      },
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}
