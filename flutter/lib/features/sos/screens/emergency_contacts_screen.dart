import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/services/shared_preferences_storage_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../safety/controllers/sos_controller.dart';
import '../../safety/models/emergency_contact_model.dart';
import '../../safety/repositories/emergency_repository.dart';
import '../../safety/services/emergency_call_service.dart';
import 'add_emergency_contact_screen.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SosController>().loadContacts();
    });
  }

  Future<void> _deleteContact(EmergencyContact contact) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text('Delete Contact?', style: AppTextStyles.headlineSm()),
        content: Text('Remove ${contact.name} from emergency contacts?', style: AppTextStyles.bodyMd()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('CANCEL', style: AppTextStyles.button(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('DELETE', style: AppTextStyles.button(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final authUserId = context.read<AuthController>().currentUser?.id;
      final userId = (authUserId != null && authUserId.isNotEmpty)
          ? authUserId
          : ((await SharedPreferencesStorageService().getString('user_id')) ?? 'user_guest');
      final repo = SqliteEmergencyRepository();
      await repo.deleteContact(contact.id, userId: userId);
      if (mounted) {
        context.read<SosController>().loadContacts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact Removed'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _setPrimary(EmergencyContact contact) async {
    final authUserId = context.read<AuthController>().currentUser?.id;
    final userId = (authUserId != null && authUserId.isNotEmpty)
        ? authUserId
        : ((await SharedPreferencesStorageService().getString('user_id')) ?? 'user_guest');
    final repo = SqliteEmergencyRepository();
    await repo.setPrimaryContact(contact.id, userId: userId);
    if (mounted) {
      context.read<SosController>().loadContacts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${contact.name} set as primary contact'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sosController = context.watch<SosController>();
    final contacts = sosController.contacts;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      extendBodyBehindAppBar: true,
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
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Emergency Contacts', style: AppTextStyles.headlineMd()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'These contacts will be called & sent emergency alerts with your live location when SOS is triggered.',
                    style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (contacts.isEmpty)
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          children: [
                            const Icon(Icons.contact_phone_outlined, size: 64, color: AppColors.circuitOrange),
                            const SizedBox(height: AppSpacing.md),
                            Text('No Emergency Contacts', style: AppTextStyles.headlineSm()),
                            const SizedBox(height: 8),
                            Text(
                              'Add trusted contacts who can respond quickly during an emergency.',
                              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.circuitOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AddEditEmergencyContactScreen()),
                              ).then((_) => sosController.loadContacts()),
                              icon: const Icon(Icons.add),
                              label: const Text('ADD CONTACT'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...contacts.map((contact) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _buildContactCard(contact),
                        )).toList().animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: contacts.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditEmergencyContactScreen()),
              ).then((_) => sosController.loadContacts()),
              backgroundColor: AppColors.circuitOrange,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text('ADD CONTACT', style: AppTextStyles.button(color: Colors.white)),
            )
          : null,
    );
  }

  Widget _buildContactCard(EmergencyContact contact) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: contact.isPrimary
                      ? AppColors.circuitOrange.withValues(alpha: 0.2)
                      : AppColors.surfaceContainerHigh,
                  child: Text(
                    contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                    style: AppTextStyles.headlineSm(
                      color: contact.isPrimary ? AppColors.circuitOrange : AppColors.onSurface,
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
                          Flexible(
                            child: Text(
                              contact.name,
                              style: AppTextStyles.headlineSm(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (contact.isPrimary) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.amber),
                              ),
                              child: const Text(
                                'PRIMARY',
                                style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.circuitOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.circuitOrange.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          contact.relationship,
                          style: AppTextStyles.labelCapsSm(color: AppColors.circuitOrange),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(contact.phoneNumber, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.phone_forwarded_rounded, color: Colors.greenAccent, size: 26),
                  onPressed: () => const EmergencyCallService().placeCall(contact.phoneNumber),
                ),
              ],
            ),
            const Divider(color: AppColors.glassBorder, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!contact.isPrimary)
                  TextButton.icon(
                    onPressed: () => _setPrimary(contact),
                    icon: const Icon(Icons.star_outline, size: 16, color: Colors.amber),
                    label: const Text('Set Primary', style: TextStyle(color: Colors.amber, fontSize: 12)),
                  ),
                TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddEditEmergencyContactScreen(contact: contact)),
                  ).then((_) {
                    if (mounted) context.read<SosController>().loadContacts();
                  }),
                  icon: const Icon(Icons.edit, size: 16, color: AppColors.onSurfaceVariant),
                  label: Text('Edit', style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant)),
                ),
                TextButton.icon(
                  onPressed: () => _deleteContact(contact),
                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                  label: const Text('Remove', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
