import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/real_map_view.dart';

class LiveGroupMapScreen extends StatelessWidget {
  const LiveGroupMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        title: Text('Squad Ride', style: AppTextStyles.headlineMd()),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Real OpenStreetMap Layer connected to real hardware GPS
          const RealMapView(
            initialZoom: 15.0,
            showControls: true,
            followUserLocation: true,
          ),
          
          // Bottom Squad List
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.marginMobile),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark.withValues(alpha: 0.8),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    border: Border(top: BorderSide(color: AppColors.glassBorder)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SQUAD MEMBERS', style: AppTextStyles.labelCaps()),
                        const SizedBox(height: AppSpacing.md),
                        _buildMemberTile('Active Rider (You)', '0.0 km', '0 km/h', '', true),
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

  Widget _buildMemberTile(String name, String distance, String speed, String avatarUrl, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.circuitOrange,
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyLg().copyWith(color: AppColors.circuitOrange)),
                Text(distance, style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Text(speed, style: AppTextStyles.statLabel().copyWith(color: AppColors.onSurface)),
        ],
      ),
    );
  }
}
