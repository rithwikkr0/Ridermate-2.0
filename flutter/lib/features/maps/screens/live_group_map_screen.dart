import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

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
          // Map Placeholder
          Container(
            color: const Color(0xFF1E2020),
            child: Stack(
              children: [
                CustomPaint(
                  painter: _MapGridPainter(),
                  size: Size.infinite,
                ),
                // Markers
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.4,
                  left: MediaQuery.of(context).size.width * 0.4,
                  child: _buildMarker('https://i.pravatar.cc/150?img=11', true),
                ).animate().scale(),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.45,
                  left: MediaQuery.of(context).size.width * 0.6,
                  child: _buildMarker('https://i.pravatar.cc/150?img=12', false),
                ).animate().scale(delay: 100.ms),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.35,
                  left: MediaQuery.of(context).size.width * 0.5,
                  child: _buildMarker('https://i.pravatar.cc/150?img=13', false),
                ).animate().scale(delay: 200.ms),
              ],
            ),
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
                        _buildMemberTile('Alex', '0 km', '32 km/h', 'https://i.pravatar.cc/150?img=11', true),
                        _buildMemberTile('Sarah', '0.2 km ahead', '31 km/h', 'https://i.pravatar.cc/150?img=12', false),
                        _buildMemberTile('Mike', '0.5 km behind', '34 km/h', 'https://i.pravatar.cc/150?img=13', false),
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

  Widget _buildMarker(String avatarUrl, bool isMe) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: isMe ? AppColors.circuitOrange : Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: isMe ? AppColors.circuitOrange.withValues(alpha: 0.5) : Colors.black54,
            blurRadius: 10,
          )
        ],
      ),
      child: ClipOval(
        child: Image.network(avatarUrl, fit: BoxFit.cover),
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
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name + (isMe ? ' (You)' : ''), style: AppTextStyles.bodyLg().copyWith(color: isMe ? AppColors.circuitOrange : AppColors.onSurface)),
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

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final step = 40.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
