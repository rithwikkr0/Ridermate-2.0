import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/services/shared_preferences_storage_service.dart';
import '../../safety/models/sos_event_model.dart';
import '../../safety/repositories/emergency_repository.dart';

class SafetyHistoryScreen extends StatefulWidget {
  const SafetyHistoryScreen({super.key});

  @override
  State<SafetyHistoryScreen> createState() => _SafetyHistoryScreenState();
}

class _SafetyHistoryScreenState extends State<SafetyHistoryScreen> {
  final EmergencyRepository _repository = SqliteEmergencyRepository();
  List<SosEventModel> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    final userId = (await SharedPreferencesStorageService().getString('user_id')) ?? 'user_guest';
    final res = await _repository.getSosEvents(userId: userId);
    if (mounted) {
      setState(() {
        _isLoading = false;
        _events = res.data ?? [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.7, -0.4),
                radius: 1.2,
                colors: [Color(0x0DFF6B00), Colors.transparent],
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadEvents,
              color: AppColors.circuitOrange,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.marginMobile,
                  AppSpacing.md,
                  AppSpacing.marginMobile,
                  100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface, size: 20),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text('Emergency & Safety History', style: AppTextStyles.headlineLg(color: AppColors.onSurface)),
                      ],
                    ).animate().fadeIn(),
                    const SizedBox(height: AppSpacing.lg),
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(color: AppColors.circuitOrange),
                        ),
                      )
                    else if (_events.isEmpty)
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            children: [
                              const Icon(Icons.shield_outlined, size: 60, color: Colors.greenAccent),
                              const SizedBox(height: AppSpacing.md),
                              Text('No Emergency Events', style: AppTextStyles.headlineSm()),
                              const SizedBox(height: 8),
                              Text(
                                'You have no recorded SOS alerts or emergency triggers. Stay safe on the road!',
                                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._events.map((event) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _buildEventCard(event),
                          )).toList().animate().fadeIn(duration: 300.ms).slideY(begin: 0.05),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(SosEventModel event) {
    Color statusColor;
    String statusText;
    IconData iconData;

    switch (event.status) {
      case SosStatus.completed:
        statusColor = Colors.greenAccent;
        statusText = 'SOS RESOLVED — SAFE';
        iconData = Icons.check_circle_outline;
        break;
      case SosStatus.cancelled:
        statusColor = Colors.amber;
        statusText = 'CANCELLED';
        iconData = Icons.cancel_outlined;
        break;
      case SosStatus.active:
      case SosStatus.initiated:
      case SosStatus.countdown:
        statusColor = const Color(0xFFFF3333);
        statusText = 'ACTIVE EMERGENCY';
        iconData = Icons.warning_amber_rounded;
        break;
      case SosStatus.failed:
        statusColor = Colors.redAccent;
        statusText = 'FAILED DISPATCH';
        iconData = Icons.error_outline;
        break;
    }

    final localTime = event.startedAt.toLocal();
    final dateStr = '${localTime.day}/${localTime.month}/${localTime.year} at ${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(iconData, color: statusColor, size: 22),
                    const SizedBox(width: 8),
                    Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                Text(dateStr, style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant)),
              ],
            ),
            const Divider(color: AppColors.glassBorder, height: 20),
            if (event.latitude != null && event.longitude != null) ...[
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.circuitOrange, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'GPS: ${event.latitude!.toStringAsFixed(4)}, ${event.longitude!.toStringAsFixed(4)} (±${event.accuracy?.toStringAsFixed(0) ?? '?'}m)',
                    style: AppTextStyles.bodyXs(color: AppColors.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            if (event.rideId != null) ...[
              Row(
                children: [
                  const Icon(Icons.two_wheeler, color: AppColors.circuitOrange, size: 16),
                  const SizedBox(width: 6),
                  Text('Associated Ride ID: ${event.rideId}', style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 6),
            ],
            if (event.contactAttempts.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Contact Dispatches:', style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 4),
              ...event.contactAttempts.map((attempt) => Padding(
                    padding: const EdgeInsets.only(left: 8, top: 2),
                    child: Text('• $attempt', style: AppTextStyles.bodyXs(color: AppColors.onSurface)),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
