import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/services/shared_preferences_storage_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../safety/controllers/sos_controller.dart';
import '../../safety/models/emergency_contact_model.dart';
import '../../safety/repositories/emergency_repository.dart';

class AddEditEmergencyContactScreen extends StatefulWidget {
  final EmergencyContact? contact;
  const AddEditEmergencyContactScreen({super.key, this.contact});

  @override
  State<AddEditEmergencyContactScreen> createState() => _AddEditEmergencyContactScreenState();
}

class _AddEditEmergencyContactScreenState extends State<AddEditEmergencyContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late String _selectedRelationship;
  late bool _isPrimary;
  bool _isSaving = false;

  final List<String> _relationships = [
    'Parent',
    'Spouse',
    'Sibling',
    'Friend',
    'Riding Partner',
    'Doctor',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name ?? '');
    _phoneController = TextEditingController(text: widget.contact?.phoneNumber ?? '');
    _selectedRelationship = widget.contact?.relationship ?? 'Parent';
    if (!_relationships.contains(_selectedRelationship)) {
      _selectedRelationship = 'Other';
    }
    _isPrimary = widget.contact?.isPrimary ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final authUserId = context.read<AuthController>().currentUser?.id;
    final userId = (authUserId != null && authUserId.isNotEmpty)
        ? authUserId
        : ((await SharedPreferencesStorageService().getString('user_id')) ?? 'user_guest');
    final repo = SqliteEmergencyRepository();

    final contact = EmergencyContact(
      id: widget.contact?.id ?? 'contact_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      relationship: _selectedRelationship,
      isPrimary: _isPrimary,
      createdAt: widget.contact?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final res = await repo.saveContact(contact);
    setState(() => _isSaving = false);

    if (mounted) {
      if (res.isSuccess) {
        context.read<SosController>().loadContacts();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.contact == null ? 'Contact Added' : 'Contact Updated'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.error?.message ?? 'Failed to save contact'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.contact != null;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isEditing ? 'Edit Emergency Contact' : 'Add Emergency Contact',
          style: AppTextStyles.headlineMd(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Full Name', style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        style: AppTextStyles.bodyLg(color: AppColors.onSurface),
                        decoration: InputDecoration(
                          hintText: 'e.g. Ramesh Kumar',
                          hintStyle: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                          filled: true,
                          fillColor: AppColors.surfaceContainerHigh,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.person_outline, color: AppColors.circuitOrange),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter contact name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text('Phone Number', style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: AppTextStyles.bodyLg(color: AppColors.onSurface),
                        decoration: InputDecoration(
                          hintText: 'e.g. +91 98765 43210',
                          hintStyle: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                          filled: true,
                          fillColor: AppColors.surfaceContainerHigh,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.circuitOrange),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter phone number';
                          }
                          final digits = value.replaceAll(RegExp(r'\D'), '');
                          if (digits.length < 10) {
                            return 'Enter a valid 10-digit phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text('Relationship', style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _relationships.map((rel) {
                          final isSelected = _selectedRelationship == rel;
                          return ChoiceChip(
                            label: Text(rel),
                            selected: isSelected,
                            selectedColor: AppColors.circuitOrange,
                            backgroundColor: AppColors.surfaceContainerHigh,
                            labelStyle: AppTextStyles.labelCapsSm(
                              color: isSelected ? Colors.white : AppColors.onSurface,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedRelationship = rel);
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SwitchListTile(
                        value: _isPrimary,
                        title: Text('Primary Emergency Contact', style: AppTextStyles.headlineSm()),
                        subtitle: Text(
                          'Will be called and texted first during SOS emergency',
                          style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant),
                        ),
                        activeThumbColor: AppColors.circuitOrange,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => setState(() => _isPrimary = val),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.circuitOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isSaving ? null : _saveContact,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEditing ? 'SAVE CHANGES' : 'ADD CONTACT',
                          style: AppTextStyles.button(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
