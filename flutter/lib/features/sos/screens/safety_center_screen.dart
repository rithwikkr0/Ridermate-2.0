import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/router/app_router.dart';
import '../../safety/controllers/sos_controller.dart';
import '../../safety/widgets/sos_button.dart';
import '../../safety/services/emergency_call_service.dart';
import 'add_emergency_contact_screen.dart';

class SafetyCenterScreen extends StatefulWidget {
  const SafetyCenterScreen({super.key});
  @override
  State<SafetyCenterScreen> createState() => _SafetyCenterScreenState();
}

class _SafetyCenterScreenState extends State<SafetyCenterScreen> {
  bool _crashDetection = true;
  bool _autoSos = true;
  bool _locationSharing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SosController>().loadContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sosController = context.watch<SosController>();
    final contacts = sosController.contacts;
    final primary = sosController.primaryContact;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, -0.3),
                radius: 1.2,
                colors: [Color(0x1AFF0000), Colors.transparent],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
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
                      Text('Safety Center', style: AppTextStyles.headlineLg(color: AppColors.onSurface)),
                    ],
                  ).animate().fadeIn(),
                  const SizedBox(height: AppSpacing.lg),

                  // Missing Emergency Contact Warning Banner
                  if (contacts.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('⚠ Emergency Contact Missing', style: AppTextStyles.headlineSm(color: Colors.amber)),
                                const SizedBox(height: 2),
                                Text(
                                  'Add a contact so RiderMate can send your GPS during SOS.',
                                  style: AppTextStyles.bodyXs(color: AppColors.onSurface),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddEditEmergencyContactScreen()),
                            ).then((_) => sosController.loadContacts()),
                            child: const Text('ADD CONTACT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: -0.1),

                  // SOS Button Widget
                  SosButton(
                    onPressed: () => context.push('/sos/countdown'),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Safety Controls
                  Text('Safety Controls', style: AppTextStyles.headlineSm(color: AppColors.onSurface)),
                  const SizedBox(height: AppSpacing.sm),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _ToggleTile('Crash Detection', 'Automatically detects high-impact crashes',
                            Icons.car_crash_rounded, _crashDetection, (v) => setState(() => _crashDetection = v)),
                        _divider(),
                        _ToggleTile('Auto-SOS Dispatch', 'Triggers 5s SOS countdown on crash',
                            Icons.sos_rounded, _autoSos, (v) => setState(() => _autoSos = v)),
                        _divider(),
                        _ToggleTile('Live Location Broadcast', 'Broadcasts GPS stream during active ride',
                            Icons.location_on_rounded, _locationSharing, (v) => setState(() => _locationSharing = v)),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: AppSpacing.lg),

                  // Emergency Contacts Header & Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Emergency Contacts (${contacts.length})', style: AppTextStyles.headlineSm(color: AppColors.onSurface)),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.emergencyContacts),
                        child: Text('Manage', style: AppTextStyles.labelCaps(color: AppColors.circuitOrange)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: contacts.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              children: [
                                const Icon(Icons.person_add_outlined, color: AppColors.onSurfaceVariant),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text('No emergency contacts added yet.',
                                      style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: contacts.take(3).map((contact) {
                              final isPrimary = contact.id == primary?.id;
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: isPrimary
                                              ? AppColors.circuitOrange.withValues(alpha: 0.2)
                                              : AppColors.surfaceContainerHigh,
                                          child: Text(
                                            contact.name[0].toUpperCase(),
                                            style: AppTextStyles.statLabel(
                                              color: isPrimary ? AppColors.circuitOrange : AppColors.onSurface,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(contact.name, style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                                                  if (isPrimary) ...[
                                                    const SizedBox(width: 6),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.amber.withValues(alpha: 0.2),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: const Text('PRIMARY', style: TextStyle(color: Colors.amber, fontSize: 9, fontWeight: FontWeight.bold)),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              Text('${contact.relationship} · ${contact.phoneNumber}',
                                                  style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant)),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.phone, color: Colors.greenAccent, size: 20),
                                          onPressed: () => const EmergencyCallService().placeCall(contact.phoneNumber),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (contact != contacts.take(3).last) _divider(),
                                ],
                              );
                            }).toList(),
                          ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: AppSpacing.lg),

                  // History Navigation
                  Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          onTap: () => context.push(AppRoutes.safetyHistory),
                          child: Column(
                            children: [
                              const Icon(Icons.history_rounded, color: AppColors.circuitOrange, size: 28),
                              const SizedBox(height: 8),
                              Text('Safety & SOS History', style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, color: Color(0x1AFFFFFF));
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile(this.title, this.subtitle, this.icon, this.value, this.onChanged);
  final String title, subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.circuitOrange, size: 18),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                  Text(subtitle, style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged, activeColor: AppColors.circuitOrange),
          ],
        ),
      );
}
