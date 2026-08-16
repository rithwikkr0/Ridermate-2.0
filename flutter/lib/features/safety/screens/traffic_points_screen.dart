import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../auth/controllers/auth_controller.dart';
import '../models/traffic_violation_model.dart';
import '../repositories/sqlite_traffic_repository.dart';

/// RiderMate 2.0 — Safety Score & Traffic Points Dashboard Screen
class TrafficPointsScreen extends StatefulWidget {
  const TrafficPointsScreen({super.key});

  @override
  State<TrafficPointsScreen> createState() => _TrafficPointsScreenState();
}

class _TrafficPointsScreenState extends State<TrafficPointsScreen> {
  final SqliteTrafficRepository _repository = SqliteTrafficRepository();
  int _safetyScore = 100;
  List<TrafficViolation> _violations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authController = context.read<AuthController>();
    final uid = authController.currentUser?.id ?? 'user_guest';

    final scoreRes = await _repository.getSafetyScore(userId: uid);
    final listRes = await _repository.getViolations(userId: uid);

    if (mounted) {
      setState(() {
        _safetyScore = scoreRes.dataOrNull ?? 100;
        _violations = listRes.dataOrNull ?? [];
        _isLoading = false;
      });
    }
  }

  Color get _scoreColor {
    if (_safetyScore >= 90) return const Color(0xFF34C759); // Green
    if (_safetyScore >= 70) return const Color(0xFFFFCC00); // Yellow
    return const Color(0xFFFF3B30); // Red
  }

  String get _scoreLabel {
    if (_safetyScore >= 90) return 'EXCELLENT RIDER';
    if (_safetyScore >= 70) return 'GOOD RIDER';
    return 'CAUTION REQUIRED';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
          onPressed: () => context.pop(),
        ),
        title: Text('Safety Score & Points', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.6, -0.4),
                radius: 1.2,
                colors: [Color(0x1AFF6B00), Colors.transparent],
              ),
            ),
          ),
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.circuitOrange))
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.marginMobile,
                      AppSpacing.md,
                      AppSpacing.marginMobile,
                      100,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Safety Score Gauge Card
                        GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              children: [
                                Text('RIDERMATE SAFETY SCORE',
                                    style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
                                const SizedBox(height: AppSpacing.md),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 140,
                                      height: 140,
                                      child: CircularProgressIndicator(
                                        value: _safetyScore / 100.0,
                                        strokeWidth: 12,
                                        backgroundColor: AppColors.surfaceContainerHigh,
                                        color: _scoreColor,
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          '$_safetyScore',
                                          style: AppTextStyles.displayStat(color: _scoreColor),
                                        ),
                                        Text('/ 100', style: AppTextStyles.caption(color: AppColors.onSurfaceVariant)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _scoreColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: _scoreColor.withValues(alpha: 0.4)),
                                  ),
                                  child: Text(_scoreLabel,
                                      style: AppTextStyles.statLabel(color: _scoreColor)),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn().scale(),
                        const SizedBox(height: AppSpacing.xl),

                        // Points Penalty Rules Table
                        _buildSectionHeader('RIDERMATE SAFETY POINTS TABLE'),
                        const SizedBox(height: AppSpacing.sm),
                        GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              children: [
                                _buildRuleRow('Minor Overspeed (81–95 km/h)', '-2 pts', Colors.orange),
                                const Divider(color: AppColors.glassBorder, height: 1),
                                _buildRuleRow('Moderate Overspeed (96–110 km/h)', '-5 pts', Colors.deepOrange),
                                const Divider(color: AppColors.glassBorder, height: 1),
                                _buildRuleRow('Severe Overspeed (>110 km/h)', '-10 pts', Colors.red),
                                const Divider(color: AppColors.glassBorder, height: 1),
                                _buildRuleRow('Harsh Braking Event', '-2 pts', Colors.amber),
                                const Divider(color: AppColors.glassBorder, height: 1),
                                _buildRuleRow('Harsh Acceleration', '-2 pts', Colors.amber),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Violations History Timeline
                        _buildSectionHeader('VIOLATIONS HISTORY (${_violations.length})'),
                        const SizedBox(height: AppSpacing.sm),
                        if (_violations.isEmpty)
                          GlassCard(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.verified_user_rounded, color: Colors.greenAccent, size: 28),
                                  const SizedBox(width: AppSpacing.md),
                                  Text('No safety violations recorded!',
                                      style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _violations.length,
                            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              final v = _violations[index];
                              return GlassCard(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.circuitOrange.withValues(alpha: 0.15),
                                    child: Icon(
                                      v.type == ViolationType.overspeed
                                          ? Icons.speed_rounded
                                          : Icons.warning_amber_rounded,
                                      color: AppColors.circuitOrange,
                                    ),
                                  ),
                                  title: Text(v.type.displayName, style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
                                  subtitle: Text(v.evidence, style: AppTextStyles.caption(color: AppColors.onSurfaceVariant)),
                                  trailing: Text('-${v.pointsDeducted} pts',
                                      style: AppTextStyles.statLabel(color: Colors.redAccent)),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(title, style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
    );
  }

  Widget _buildRuleRow(String label, String points, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
          Text(points, style: AppTextStyles.statLabel(color: color)),
        ],
      ),
    );
  }
}
