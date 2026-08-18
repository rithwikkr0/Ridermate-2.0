import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/real_map_view.dart';
import '../controllers/group_ride_controller.dart';
import '../models/group_ride_model.dart';

class LiveGroupMapScreen extends StatefulWidget {
  const LiveGroupMapScreen({super.key});

  @override
  State<LiveGroupMapScreen> createState() => _LiveGroupMapScreenState();
}

class _LiveGroupMapScreenState extends State<LiveGroupMapScreen> {
  final GroupRideController _groupController = GroupRideController();

  final List<Map<String, dynamic>> _availableFriends = [
    {'id': 'f_rahul', 'name': 'Rahul Sharma', 'selected': true},
    {'id': 'f_dhanush', 'name': 'Dhanush Kumar', 'selected': false},
    {'id': 'f_kiran', 'name': 'Kiran Rao', 'selected': true},
    {'id': 'f_subash', 'name': 'Subash V', 'selected': false},
  ];

  @override
  void initState() {
    super.initState();
    _groupController.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _groupController.removeListener(_onControllerUpdate);
    _groupController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  void _showCreateRideModal() {
    final titleCtrl = TextEditingController(text: 'Sunday Nandi Ride');
    final fromCtrl = TextEditingController(text: 'Current Location');
    final destCtrl = TextEditingController(text: 'Nandi Hills Peak');
    final dateCtrl = TextEditingController(text: 'Sunday');
    final timeCtrl = TextEditingController(text: '7:00 AM');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(

        builder: (context, setModalState) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: EdgeInsets.only(
              left: AppSpacing.marginMobile,
              right: AppSpacing.marginMobile,
              top: AppSpacing.lg,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CREATE GROUP RIDE', style: AppTextStyles.headlineSm(color: AppColors.circuitOrange)),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Ride Name',
                      labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: fromCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'FROM',
                            labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: destCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'TO',
                            labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: dateCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: timeCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Time',
                            labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('ADD FRIENDS', style: AppTextStyles.labelCaps(color: AppColors.circuitOrange)),
                  const SizedBox(height: AppSpacing.sm),
                  ..._availableFriends.map(
                    (f) => CheckboxListTile(
                      activeColor: AppColors.circuitOrange,
                      title: Text(f['name'], style: const TextStyle(color: Colors.white)),
                      value: f['selected'] as bool,
                      onChanged: (val) {
                        setModalState(() {
                          f['selected'] = val ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.circuitOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _groupController.createGroupRide(
                          title: titleCtrl.text,
                          startLocation: fromCtrl.text,
                          destination: destCtrl.text,
                          date: dateCtrl.text,
                          time: timeCtrl.text,
                          currentUserName: 'Active Rider',
                          currentUserId: 'user_active',
                        );

                        // Invite selected friends
                        for (var f in _availableFriends.where((x) => x['selected'] == true)) {
                          _groupController.inviteFriend(f['name'], f['id']);
                        }
                      },
                      child: Text('CREATE GROUP RIDE & SEND INVITATIONS', style: AppTextStyles.labelCaps()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Marker> _buildMemberMarkers() {
    final ride = _groupController.activeGroupRide;
    if (ride == null) return [];

    final List<Marker> markers = [];
    for (var member in ride.members) {
      if (member.isSharingLocation &&
          member.status == MemberStatus.sharingLocation &&
          member.latitude != 0.0 &&
          member.longitude != 0.0) {
        markers.add(
          Marker(
            point: LatLng(member.latitude, member.longitude),
            width: 70,
            height: 70,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.circuitOrange),
                  ),
                  child: Text(
                    member.name.split(' ').first,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const Icon(Icons.location_on, color: AppColors.circuitOrange, size: 28),
              ],
            ),
          ),
        );
      }
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final activeRide = _groupController.activeGroupRide;
    final invitations = _groupController.myInvitations;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Group Ride Details', style: AppTextStyles.headlineMd()),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.circuitOrange),
            onPressed: _showCreateRideModal,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Real OpenStreetMap Layer with Group Member Location Pins
          RealMapView(
            initialZoom: 14.0,
            showControls: true,
            followUserLocation: true,
            extraMarkers: _buildMemberMarkers(),
          ),

          // Pending Invitations Card Banner
          if (invitations.any((i) => i.status == InvitationStatus.pending))
            Positioned(
              top: 90,
              left: AppSpacing.marginMobile,
              right: AppSpacing.marginMobile,
              child: GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GROUP RIDE INVITATION', style: AppTextStyles.labelCaps(color: AppColors.circuitOrange)),
                      const SizedBox(height: 4),
                      Text(
                        invitations.firstWhere((i) => i.status == InvitationStatus.pending).rideTitle,
                        style: AppTextStyles.bodyLg(color: Colors.white),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.circuitOrange),
                              onPressed: () {
                                final inv = invitations.firstWhere((i) => i.status == InvitationStatus.pending);
                                _groupController.acceptInvitation(inv.id, 'user_active', 'Active Rider');
                              },
                              child: const Text('ACCEPT', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                              onPressed: () {
                                final inv = invitations.firstWhere((i) => i.status == InvitationStatus.pending);
                                _groupController.declineInvitation(inv.id);
                              },
                              child: const Text('DECLINE'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Bottom Squad Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.marginMobile),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark.withValues(alpha: 0.92),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    border: Border(top: BorderSide(color: AppColors.glassBorder)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              activeRide != null ? activeRide.title.toUpperCase() : 'NO ACTIVE GROUP RIDE',
                              style: AppTextStyles.labelCaps(color: AppColors.circuitOrange),
                            ),
                            if (activeRide != null)
                              Row(
                                children: [
                                  Text(
                                    'LOCATION SHARING',
                                    style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant),
                                  ),
                                  Switch(
                                    value: _groupController.isLocationSharingEnabled,
                                    activeThumbColor: AppColors.circuitOrange,
                                    onChanged: (val) => _groupController.toggleLocationSharing(val),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        if (activeRide == null) ...[
                          Text(
                            'Create or join a group ride to view real-time squad locations.',
                            style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.circuitOrange,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _showCreateRideModal,
                            child: Text('CREATE GROUP RIDE', style: AppTextStyles.labelCaps()),
                          ),
                        ] else ...[
                          Text('SQUAD MEMBERS', style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
                          const SizedBox(height: AppSpacing.sm),
                          ...activeRide.members.map(
                            (member) => _buildMemberTile(member),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
                            icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                            label: const Text('LEAVE GROUP RIDE'),
                            onPressed: () => _groupController.leaveGroupRide(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ).animate().slideY(begin: 1.0, duration: 300.ms).fadeIn(),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(GroupRideMember member) {
    final isSharing = member.isSharingLocation && member.status == MemberStatus.sharingLocation;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isSharing ? AppColors.circuitOrange : Colors.grey,
            child: Icon(isSharing ? Icons.person : Icons.person_off, color: Colors.white, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: AppTextStyles.bodyLg().copyWith(
                    color: member.name.contains('(You)') ? AppColors.circuitOrange : AppColors.onSurface,
                  ),
                ),
                Text(
                  isSharing ? 'Sharing Live GPS' : 'Location sharing unavailable',
                  style: AppTextStyles.bodyMd().copyWith(
                    color: isSharing ? Colors.greenAccent : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isSharing)
            Text(
              '${member.speedKmh.toStringAsFixed(0)} km/h',
              style: AppTextStyles.statLabel().copyWith(color: AppColors.onSurface),
            ),
        ],
      ),
    );
  }
}
