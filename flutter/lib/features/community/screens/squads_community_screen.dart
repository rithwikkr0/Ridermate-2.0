import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../controllers/community_controller.dart';
import '../models/squad_model.dart';
import 'squad_details_screen.dart';

class SquadsCommunityScreen extends StatefulWidget {
  const SquadsCommunityScreen({super.key});

  @override
  State<SquadsCommunityScreen> createState() => _SquadsCommunityScreenState();
}

class _SquadsCommunityScreenState extends State<SquadsCommunityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityController>().loadSquads();
    });
  }

  void _showCreateSquadDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    bool isPrivate = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceContainerHigh,
          title: Text('Create Riding Squad', style: AppTextStyles.headlineSm()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: AppTextStyles.bodyMd(),
                  decoration: InputDecoration(
                    labelText: 'Squad Name',
                    hintText: 'e.g. Western Ghats Explorers',
                    filled: true,
                    fillColor: AppColors.surfaceContainerHighest,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  style: AppTextStyles.bodyMd(),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'e.g. Weekend tourers and highway lovers',
                    filled: true,
                    fillColor: AppColors.surfaceContainerHighest,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                CheckboxListTile(
                  title: const Text('Private Squad (Invite Code Required)'),
                  value: isPrivate,
                  activeColor: AppColors.circuitOrange,
                  onChanged: (val) => setDialogState(() => isPrivate = val ?? false),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('CANCEL')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.circuitOrange),
              onPressed: () async {
                if (nameCtrl.text.trim().isNotEmpty) {
                  final community = context.read<CommunityController>();
                  final res = await community.createSquad(
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    isPrivate: isPrivate,
                  );
                  if (mounted) {
                    Navigator.of(ctx).pop();
                    if (res.isSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Squad "${nameCtrl.text}" created! 🏍️'), backgroundColor: AppColors.circuitOrange),
                      );
                    }
                  }
                }
              },
              child: const Text('CREATE', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showJoinSquadDialog() {
    final codeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text('Join via Invite Code', style: AppTextStyles.headlineSm()),
        content: TextField(
          controller: codeCtrl,
          style: AppTextStyles.bodyMd(),
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'e.g. RM-WEST-1234',
            filled: true,
            fillColor: AppColors.surfaceContainerHighest,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.circuitOrange),
            onPressed: () async {
              final code = codeCtrl.text.trim();
              if (code.isNotEmpty) {
                final community = context.read<CommunityController>();
                // Find squad with invite code
                final matching = community.squads.where((s) => s.inviteCode.toUpperCase() == code.toUpperCase()).toList();
                if (matching.isNotEmpty) {
                  final res = await community.joinSquad(matching.first.id, inviteCode: code);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(res.isSuccess ? 'Joined squad!' : 'Failed: ${res.error?.message}')),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid squad invite code'), backgroundColor: Colors.red),
                    );
                  }
                }
              }
            },
            child: const Text('JOIN', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final community = context.watch<CommunityController>();
    final mySquads = community.squads.where((s) => s.isMember).toList();
    final discoverSquads = community.squads.where((s) => !s.isMember).toList();

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Squads & Clubs', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
        actions: [
          IconButton(
            icon: const Icon(Icons.vpn_key_outlined, color: AppColors.onSurface),
            tooltip: 'Join with Code',
            onPressed: _showJoinSquadDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.circuitOrange,
        onPressed: _showCreateSquadDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Create Squad', style: AppTextStyles.buttonSm(color: Colors.white)),
      ),
      body: RefreshIndicator(
        color: AppColors.circuitOrange,
        onRefresh: () => community.loadSquads(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile, AppSpacing.md, AppSpacing.marginMobile, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // My Squads Section
              Text('MY SQUADS (${mySquads.length})', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: AppSpacing.sm),

              if (mySquads.isEmpty)
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.groups_outlined, size: 40, color: AppColors.onSurfaceVariant),
                        const SizedBox(height: 6),
                        Text('You haven\'t joined any squads yet.', style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                )
              else
                ...mySquads.map((s) => _squadTile(s, isJoined: true)),

              const SizedBox(height: AppSpacing.xl),

              // Discover Squads Section
              Text('DISCOVER SQUADS (${discoverSquads.length})', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: AppSpacing.sm),

              if (discoverSquads.isEmpty && mySquads.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('All available public squads are joined!', style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant)),
                )
              else if (discoverSquads.isEmpty)
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Center(
                    child: Text('No squads found. Tap "Create Squad" to start one!', style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant)),
                  ),
                )
              else
                ...discoverSquads.map((s) => _squadTile(s, isJoined: false)),

              const SizedBox(height: AppSpacing.xl),

              // Group Rides Section
              Text('UPCOMING GROUP RIDES (${community.groupRides.length})', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: AppSpacing.sm),

              if (community.groupRides.isEmpty)
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Center(
                    child: Text('No group rides scheduled right now.', style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant)),
                  ),
                )
              else
                ...community.groupRides.map((ride) => _groupRideCard(ride, community)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _squadTile(SquadModel squad, {required bool isJoined}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Icon(Icons.two_wheeler, color: AppColors.circuitOrange, size: 24)),
          ),
          title: Row(
            children: [
              Text(squad.name, style: AppTextStyles.headlineXs()),
              if (squad.isPrivate) ...[
                const SizedBox(width: 4),
                const Icon(Icons.lock, size: 12, color: AppColors.onSurfaceVariant),
              ],
            ],
          ),
          subtitle: Text(
            squad.description.isNotEmpty ? squad.description : '${squad.memberCount} members',
            style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant),
          ),
          trailing: isJoined
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                  child: const Text('JOINED', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                )
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.circuitOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => context.read<CommunityController>().joinSquad(squad.id, inviteCode: squad.inviteCode),
                  child: const Text('JOIN', style: TextStyle(fontSize: 11)),
                ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SquadDetailsScreen(squad: squad)),
            );
          },
        ),
      ),
    );
  }

  Widget _groupRideCard(GroupRideModel ride, CommunityController community) {
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
            Text('Led by ${ride.creatorName} • ${ride.memberCount} riders joined', style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant)),
            if (ride.startLocation.isNotEmpty || ride.destination.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Route: ${ride.startLocation} ➔ ${ride.destination}', style: AppTextStyles.bodySm()),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (ride.isJoined)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent)),
                    icon: const Icon(Icons.exit_to_app, size: 14, color: Colors.redAccent),
                    label: const Text('LEAVE', style: TextStyle(color: Colors.redAccent, fontSize: 11)),
                    onPressed: () => community.leaveGroupRide(ride.id),
                  )
                else
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.circuitOrange),
                    icon: const Icon(Icons.group_add, size: 14, color: Colors.white),
                    label: const Text('JOIN RIDE', style: TextStyle(color: Colors.white, fontSize: 11)),
                    onPressed: () => community.joinGroupRide(ride.id),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
