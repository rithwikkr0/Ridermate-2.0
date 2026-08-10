import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../safety/controllers/sos_controller.dart';
import '../../rides/controllers/ride_controller.dart';

class SosCountdownScreen extends StatefulWidget {
  const SosCountdownScreen({super.key});

  @override
  State<SosCountdownScreen> createState() => _SosCountdownScreenState();
}

class _SosCountdownScreenState extends State<SosCountdownScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rideController = context.read<RideController>();
      final isRideActive = rideController.isRideActive;
      final currentRide = rideController.currentRide;

      context.read<SosController>().triggerSos(
            rideId: isRideActive ? currentRide?.id : null,
            rideDistanceKm: isRideActive ? currentRide?.distanceKm : null,
            rideDuration: isRideActive ? currentRide?.duration : null,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final sosController = context.watch<SosController>();
    final isEmergencyActive = sosController.sosState == SosState.activeEmergency;
    final primary = sosController.primaryContact;
    final contacts = sosController.contacts;

    if (isEmergencyActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.pushReplacement('/sos/tracking');
      });
    }

    final targetNames = primary != null
        ? '${primary.name} (${primary.phoneNumber})'
        : (contacts.isNotEmpty
            ? contacts.map((c) => c.name).join(', ')
            : 'No contacts configured');

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF660000), Color(0xFFFF1111)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.white),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'EMERGENCY SOS',
                  style: AppTextStyles.headlineLg(color: Colors.white).copyWith(letterSpacing: 2),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Emergency mode will activate in',
                  style: AppTextStyles.bodyMd(color: Colors.white70),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: Text(
                      '${sosController.countdownSeconds}',
                      style: AppTextStyles.displayStat(color: Colors.white).copyWith(fontSize: 100),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Notifying Primary Contact:',
                  style: AppTextStyles.labelCapsSm(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  targetNames,
                  style: AppTextStyles.headlineSm(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 64),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: Colors.black.withValues(alpha: 0.2),
                    ),
                    onPressed: () {
                      context.read<SosController>().cancelSos();
                      context.pop();
                    },
                    child: Text(
                      'CANCEL SOS',
                      style: AppTextStyles.button(color: Colors.white).copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
