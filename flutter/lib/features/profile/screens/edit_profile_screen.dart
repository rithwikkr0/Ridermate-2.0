import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/rm_text_field.dart';
import '../../auth/models/user_model.dart';
import '../controllers/profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = context.read<ProfileController>().userOrDefault;
    _nameController = TextEditingController(text: user.fullName);
    _usernameController = TextEditingController(text: user.username);
    _bioController = TextEditingController(text: user.bio);
    _phoneController = TextEditingController(text: user.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final profileController = context.read<ProfileController>();
    final user = profileController.userOrDefault;

    final updatedUser = UserModel(
      id: user.id,
      username: _usernameController.text.trim(),
      fullName: _nameController.text.trim(),
      email: user.email,
      phone: _phoneController.text.trim(),
      profilePhotoUrl: user.profilePhotoUrl,
      bio: _bioController.text.trim(),
      riderLevel: user.riderLevel,
      xp: user.xp,
      totalDistanceKm: user.totalDistanceKm,
      totalRides: user.totalRides,
      achievements: user.achievements,
      emergencyContacts: user.emergencyContacts,
      vehicles: user.vehicles,
      preferences: user.preferences,
      createdAt: user.createdAt,
      updatedAt: DateTime.now(),
    );

    await profileController.updateProfile(updatedUser);
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<ProfileController>();
    final user = profileController.userOrDefault;
    final isLoading = profileController.isLoading;

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
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(AppRoutes.profile);
                          }
                        },
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Edit Profile', style: AppTextStyles.headlineMd()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: user.profilePhotoUrl.isNotEmpty
                              ? NetworkImage(user.profilePhotoUrl) as ImageProvider
                              : null,
                          backgroundColor: AppColors.surfaceContainerHigh,
                          child: user.profilePhotoUrl.isEmpty
                              ? const Icon(Icons.person, size: 50, color: AppColors.onSurfaceVariant)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.circuitOrange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  RmTextField(
                    label: 'Name',
                    controller: _nameController,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  RmTextField(
                    label: 'Username',
                    controller: _usernameController,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  RmTextField(
                    label: 'Phone',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  RmTextField(
                    label: 'Bio',
                    controller: _bioController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    text: isLoading ? 'SAVING...' : 'SAVE CHANGES',
                    onPressed: isLoading ? null : _handleSave,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
