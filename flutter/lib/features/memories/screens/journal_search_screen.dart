import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/rm_text_field.dart';
import 'package:go_router/go_router.dart';

class JournalSearchScreen extends StatefulWidget {
  const JournalSearchScreen({super.key});

  @override
  State<JournalSearchScreen> createState() => _JournalSearchScreenState();
}

class _JournalSearchScreenState extends State<JournalSearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: RmTextField(
                          controller: _searchController,
                          hintText: 'Search journal entries...',
                          prefixIcon: Icons.search,
                          onChanged: (val) {
                            setState(() {
                              _query = val;
                            });
                          },
                        ),
                      ),
                    ],
                  ).animate().fadeIn(),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    _query.isEmpty ? 'RECENT ENTRIES' : 'SEARCH RESULTS',
                    style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: GlassCard(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Aug ${15 - index}', style: AppTextStyles.labelCaps(color: AppColors.circuitOrange)),
                                      Text('24.5 km', style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text('Morning Coastal Ride', style: AppTextStyles.bodyLg(color: AppColors.onSurface)),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'Beautiful sunrise today over the ocean. Great pace maintained all the way.',
                                    style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: Duration(milliseconds: 100 * index));
                      },
                    ),
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
