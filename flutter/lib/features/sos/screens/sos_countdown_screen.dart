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

  void _triggerImmediate({bool viaWhatsApp = false}) {
    final rideController = context.read<RideController>();
    final isRideActive = rideController.isRideActive;
    final currentRide = rideController.currentRide;

    context.read<SosController>().triggerImmediateSos(
          rideId: isRideActive ? currentRide?.id : null,
          rideDistanceKm: isRideActive ? currentRide?.distanceKm : null,
          rideDuration: isRideActive ? currentRide?.duration : null,
          viaWhatsApp: viaWhatsApp,
        );
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
            colors: [Color(0xFF4A0000), Color(0xFFE50914)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Icon(Icons.warning_amber_rounded, size: 70, color: Colors.white),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'EMERGENCY SOS',
                  style: AppTextStyles.headlineLg(color: Colors.white).copyWith(letterSpacing: 2),
                ),
                const SizedBox(height: 4),
                Text(
                  'Auto-dispatching distress SMS & call in',
                  style: AppTextStyles.bodyMd(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),

                // Countdown Circle
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: Text(
                      '${sosController.countdownSeconds}',
                      style: AppTextStyles.displayStat(color: Colors.white).copyWith(fontSize: 75),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Target Contact Display
                Text(
                  'Target Emergency Contact:',
                  style: AppTextStyles.labelCapsSm(color: Colors.white70),
                ),
                const SizedBox(height: 2),
                Text(
                  targetNames,
                  style: AppTextStyles.headlineSm(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Instant One-Click Trigger Buttons
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFCC0000),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => _triggerImmediate(viaWhatsApp: false),
                    label: Text(
                      'SEND DRAFT SMS & CALL NOW',
                      style: AppTextStyles.button(color: const Color(0xFFCC0000)).copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => _triggerImmediate(viaWhatsApp: true),
                    label: Text(
                      'SEND VIA WHATSAPP & CALL NOW',
                      style: AppTextStyles.button(color: Colors.white).copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      backgroundColor: Colors.black.withValues(alpha: 0.25),
                    ),
                    onPressed: () {
                      context.read<SosController>().cancelSos();
                      context.pop();
                    },
                    child: Text(
                      'CANCEL SOS',
                      style: AppTextStyles.button(color: Colors.white).copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
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
