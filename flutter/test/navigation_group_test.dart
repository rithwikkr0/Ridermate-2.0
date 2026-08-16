import 'package:flutter_test/flutter_test.dart';
import 'package:ridermate/features/maps/models/group_ride_model.dart';
import 'package:ridermate/features/maps/services/nominatim_place_search_service.dart';
import 'package:ridermate/features/maps/services/osrm_routing_service.dart';
import 'package:ridermate/features/maps/controllers/group_ride_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 4: Navigation, Solo Ride & Group Ride Unit Tests', () {

    test('NominatimPlaceSearchService returns places or fallback list', () async {
      final searchService = NominatimPlaceSearchService();
      final recents = await searchService.getRecentSearches();
      expect(recents.isNotEmpty, isTrue);
      expect(recents.first.latitude, isNotNull);
      expect(recents.first.longitude, isNotNull);
    });

    test('OsrmRoutingService generates routes with points, distance & duration', () async {
      final routingService = OsrmRoutingService();
      final routes = await routingService.planRoutes(
        startLat: 12.971598,
        startLng: 77.594566,
        destLat: 13.3702,
        destLng: 77.6835,
      );

      expect(routes.isNotEmpty, isTrue);
      final primary = routes.first;
      expect(primary.points.length, greaterThan(1));
      expect(primary.distanceKm, greaterThan(0));
      expect(primary.estimatedDuration.inMinutes, greaterThan(0));
    });

    test('GroupRideController initializes with sample invitations', () {
      final controller = GroupRideController();
      expect(controller.myInvitations.length, equals(1));
      expect(controller.myInvitations.first.status, equals(InvitationStatus.pending));
    });

    test('GroupRide creation sets active state and adds creator as member', () async {
      final controller = GroupRideController();
      final ride = await controller.createGroupRide(
        title: 'Nandi Pass Ride',
        startLocation: 'Bangalore',
        destination: 'Nandi Hills',
        date: 'Today',
        time: '6:00 AM',
        currentUserName: 'Rithwik',
        currentUserId: 'user_1',
      );

      expect(ride.state, equals(GroupRideState.active));
      expect(ride.members.length, equals(1));
      expect(ride.members.first.name, contains('Rithwik'));
      expect(ride.members.first.isSharingLocation, isTrue);
    });

    test('Friend invitation updates invitation state machine', () async {
      final controller = GroupRideController();
      await controller.createGroupRide(
        title: 'Coast Ride',
        startLocation: 'Point A',
        destination: 'Point B',
        date: 'Today',
        time: 'Now',
        currentUserName: 'Host',
        currentUserId: 'u_host',
      );

      controller.inviteFriend('Rahul', 'u_rahul');
      expect(controller.activeGroupRide!.members.length, equals(2));
      expect(controller.activeGroupRide!.members.last.status, equals(MemberStatus.invited));
    });

    test('Accepting invitation joins group ride', () {
      final controller = GroupRideController();
      final invId = controller.myInvitations.first.id;

      controller.acceptInvitation(invId, 'u_rider', 'Rider X');
      expect(controller.myInvitations.first.status, equals(InvitationStatus.accepted));
      expect(controller.activeGroupRide, isNotNull);
      expect(controller.activeGroupRide!.state, equals(GroupRideState.active));
    });

    test('Declining invitation updates status without joining ride', () {
      final controller = GroupRideController();
      final invId = controller.myInvitations.first.id;

      controller.declineInvitation(invId);
      expect(controller.myInvitations.first.status, equals(InvitationStatus.declined));
      expect(controller.activeGroupRide, isNull);
    });

    test('Explicit location sharing privacy toggle updates consent state', () async {
      final controller = GroupRideController();
      await controller.createGroupRide(
        title: 'Privacy Test',
        startLocation: 'Start',
        destination: 'End',
        date: 'Today',
        time: 'Now',
        currentUserName: 'User',
        currentUserId: 'u_1',
      );

      expect(controller.isLocationSharingEnabled, isTrue);
      controller.toggleLocationSharing(false);
      expect(controller.isLocationSharingEnabled, isFalse);

      final myMember = controller.activeGroupRide!.members.firstWhere((m) => m.name.contains('(You)'));
      expect(myMember.isSharingLocation, isFalse);
    });

    test('Leaving group ride updates member status to left', () async {
      final controller = GroupRideController();
      await controller.createGroupRide(
        title: 'Leave Test',
        startLocation: 'Start',
        destination: 'End',
        date: 'Today',
        time: 'Now',
        currentUserName: 'User',
        currentUserId: 'u_1',
      );

      controller.leaveGroupRide();
      final myMember = controller.activeGroupRide!.members.firstWhere((m) => m.name.contains('(You)'));
      expect(myMember.status, equals(MemberStatus.left));
      expect(myMember.isSharingLocation, isFalse);
    });
  });
}
