import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../controllers/community_controller.dart';
import '../models/squad_model.dart';
import '../repositories/sqlite_squad_repository.dart';

class SquadDetailsScreen extends StatefulWidget {
  final SquadModel? squad;

  const SquadDetailsScreen({
    super.key,
    this.squad,
  });

  @override
  State<SquadDetailsScreen> createState() => _SquadDetailsScreenState();
}

class _SquadDetailsScreenState extends State<SquadDetailsScreen> {
  late SquadModel _squad;
  List<SquadMemberModel> _members = [];
  bool _isLoadingMembers = true;

  @override
  void initState() {
    super.initState();
    _squad = widget.squad ?? SquadModel(
      id: 'default_squad',
      creatorId: 'user_default',
      name: 'RiderMate Club',
      description: 'The official community riding club',
      inviteCode: 'RM-CLUB-101',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final repo = SqliteSquadRepository();
    final res = await repo.getSquadMembers(_squad.id);
    if (mounted) {
      setState(() {
        _members = res.dataOrNull ?? [];
        _isLoadingMembers = false;
      });
    }
  }

  void _showScheduleRideDialog() {
    final titleCtrl = TextEditingController();
    final startCtrl = TextEditingController();
    final destCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text('Schedule Squad Ride', style: AppTextStyles.headlineSm()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                style: AppTextStyles.bodyMd(),
                decoration: InputDecoration(
                  labelText: 'Ride Title',
                  hintText: 'e.g. Coastal Highway Sunrise Cruise',
                  filled: true,
                  fillColor: AppColors.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: startCtrl,
                style: AppTextStyles.bodyMd(),
                decoration: InputDecoration(
                  labelText: 'Start Location',
                  hintText: 'e.g. Bandra Fort Assembly Point',
                  filled: true,
                  fillColor: AppColors.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: destCtrl,
                style: AppTextStyles.bodyMd(),
                decoration: InputDecoration(
                  labelText: 'Destination',
                  hintText: 'e.g. Lonavala Ghats Viewpoint',
                  filled: true,
                  fillColor: AppColors.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.circuitOrange),
            onPressed: () async {
              if (titleCtrl.text.trim().isNotEmpty) {
                final community = context.read<CommunityController>();
                final res = await community.createGroupRide(
                  squadId: _squad.id,
                  title: titleCtrl.text.trim(),
                  description: 'Squad ride organized for ${_squad.name}',
                  startTime: DateTime.now().add(const Duration(days: 1)),
                  startLocation: startCtrl.text.trim(),
                  destination: destCtrl.text.trim(),
                );
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  if (res.isSuccess) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Group ride scheduled! 🏍️'), backgroundColor: AppColors.circuitOrange),
                    );
                  }
                }
              }
            },
            child: const Text('SCHEDULE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final community = context.watch<CommunityController>();
    final liveSquad = community.squads.firstWhere((s) => s.id == _squad.id, orElse: () => _squad);
    final squadRides = community.groupRides.where((r) => r.squadId == _squad.id).toList();

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(liveSquad.name, style: AppTextStyles.headlineSm(color: AppColors.onSurface)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Squad Header Glass Card
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Center(child: Icon(Icons.two_wheeler, size: 36, color: AppColors.circuitOrange)),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(liveSquad.name, style: AppTextStyles.headlineMd()),
                  if (liveSquad.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(liveSquad.description, style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: AppSpacing.sm),

                  // Invite Code Row
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.vpn_key_outlined, size: 14, color: AppColors.circuitOrange),
                        const SizedBox(width: 6),
                        Text('CODE: ${liveSquad.inviteCode}', style: AppTextStyles.bodyXs(color: AppColors.circuitOrange).copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: liveSquad.inviteCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Invite code copied! 📋')),
                            );
                          },
                          child: const Icon(Icons.copy, size: 14, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.glassBorder, height: 24),

                  // Members / Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statItem('MEMBERS', '${liveSquad.memberCount}'),
                      _statItem('RIDES', '${squadRides.length}'),
                      _statItem('ROLE', liveSquad.role.toUpperCase()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Join / Leave Button
                  if (liveSquad.isMember)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        await community.leaveSquad(liveSquad.id);
                        await _loadMembers();
                      },
                      child: const Text('LEAVE SQUAD', style: TextStyle(color: Colors.redAccent)),
                    )
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.circuitOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        await community.joinSquad(liveSquad.id, inviteCode: liveSquad.inviteCode);
                        await _loadMembers();
                      },
                      child: const Text('JOIN SQUAD'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Members List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Squad Members (${_members.length})', style: AppTextStyles.headlineSm()),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            if (_isLoadingMembers)
              const Center(child: CircularProgressIndicator(color: AppColors.circuitOrange))
            else if (_members.isEmpty)
              Text('No members listed yet.', style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant))
            else
              ..._members.map((m) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.surfaceContainerHighest,
                          child: const Icon(Icons.person, size: 16, color: AppColors.onSurface),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.fullName, style: AppTextStyles.statLabel()),
                              Text('@${m.username}', style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: m.role == 'owner' ? Colors.amber.withValues(alpha: 0.2) : AppColors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            m.role.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: m.role == 'owner' ? Colors.amber : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: AppSpacing.md),

            // Squad Rides Header & Schedule Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Squad Rides (${squadRides.length})', style: AppTextStyles.headlineSm()),
                if (liveSquad.isMember)
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 16, color: AppColors.circuitOrange),
                    label: const Text('Schedule', style: TextStyle(color: AppColors.circuitOrange)),
                    onPressed: _showScheduleRideDialog,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            if (squadRides.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('No group rides planned for this squad yet.', style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant)),
              )
            else
              ...squadRides.map((r) => _squadRideCard(r, community)),
          ],
        ),
      ),
    );
  }

  Widget _squadRideCard(GroupRideModel ride, CommunityController community) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(ride.title, style: AppTextStyles.statLabel()),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.circuitOrange.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                  child: Text(ride.status.toUpperCase(), style: const TextStyle(color: AppColors.circuitOrange, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Route: ${ride.startLocation} ➔ ${ride.destination}', style: AppTextStyles.bodySm()),
            const SizedBox(height: 4),
            Text('${ride.memberCount} members joined', style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (ride.isJoined)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent)),
                    onPressed: () => community.leaveGroupRide(ride.id),
                    child: const Text('LEAVE RIDE', style: TextStyle(color: Colors.redAccent, fontSize: 11)),
                  )
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.circuitOrange),
                    onPressed: () => community.joinGroupRide(ride.id),
                    child: const Text('JOIN RIDE', style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.statLabel(color: AppColors.circuitOrange)),
      ],
    );
  }
}
