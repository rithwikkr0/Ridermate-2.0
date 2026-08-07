import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/rm_text_field.dart';
import 'package:go_router/go_router.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Edit Profile', style: AppTextStyles.headlineMd()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: Stack(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=33'),
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
                    initialValue: 'John Rider',
                    onChanged: (val) {},
                  ),
                  const SizedBox(height: AppSpacing.md),
                  RmTextField(
                    label: 'Username',
                    initialValue: '@johnrider',
                    onChanged: (val) {},
                  ),
                  const SizedBox(height: AppSpacing.md),
                  RmTextField(
                    label: 'Bio',
                    initialValue: 'Mountain biker & road cyclist...',
                    maxLines: 3,
                    onChanged: (val) {},
                  ),
                  const SizedBox(height: AppSpacing.md),
                  RmTextField(
                    label: 'Location',
                    initialValue: 'Mumbai, India',
                    onChanged: (val) {},
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(label: 'Save Changes',
                    onPressed: () => context.pop(),
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
