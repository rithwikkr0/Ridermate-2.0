import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../safety/controllers/sos_controller.dart';

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
      context.read<SosController>().triggerSos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sosController = context.watch<SosController>();
    final isEmergencyActive = sosController.sosState == SosState.activeEmergency;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8B0000), Color(0xFFFF2222)],
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
                if (!isEmergencyActive) ...[
                  const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.white),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    '${sosController.countdownSeconds}',
                    style: AppTextStyles.displayStat(color: Colors.white).copyWith(fontSize: 120),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Contacting emergency services...',
                    style: AppTextStyles.headlineSm(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Sending location to: Ramesh Rider, Meera Rider',
                    style: AppTextStyles.bodyMd(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 64),
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        context.read<SosController>().cancelSos();
                        context.pop();
                      },
                      child: Text('CANCEL', style: AppTextStyles.button(color: Colors.white)),
                    ),
                  ),
                ] else ...[
                  const Icon(Icons.check_circle_outline, size: 100, color: Colors.white),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'SOS Sent!',
                    style: AppTextStyles.displayStatSm(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Emergency contacts have been notified with your location.',
                    style: AppTextStyles.bodyMd(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        context.read<SosController>().resolveEmergency();
                        context.pop();
                      },
                      child: Text('Return', style: AppTextStyles.button(color: Colors.red)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
