import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/ai_chat_bubble.dart';
import '../controllers/ai_controller.dart';

class AiCopilotHomeScreen extends StatefulWidget {
  const AiCopilotHomeScreen({super.key});

  @override
  State<AiCopilotHomeScreen> createState() => _AiCopilotHomeScreenState();
}

class _AiCopilotHomeScreenState extends State<AiCopilotHomeScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      context.read<AiController>().sendMessage(text);
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiController = context.watch<AiController>();
    final messages = aiController.messages;

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
                120, // Bottom clearance
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI COPILOT', style: AppTextStyles.labelCaps()).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Good morning, Rider.', style: AppTextStyles.headlineLg().copyWith(color: AppColors.onSurface)).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.xs),
                  Text('How can I help you today?', style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant)).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.xl),

                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/ai/listening'),
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [AppColors.circuitOrange, Color(0x33FF6B00), Colors.transparent],
                            stops: [0.2, 0.6, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(color: AppColors.circuitOrange.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: 10),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.mic, color: Colors.white, size: 64),
                        ),
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(begin: const Offset(0.98, 0.98), end: const Offset(1.02, 1.02), duration: 2.seconds),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.read<AiController>().sendMessage('Give me a pre-ride brief'),
                          child: _buildActionChip('Pre-Ride Brief'),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        GestureDetector(
                          onTap: () => context.read<AiController>().sendMessage('Suggest a scenic route'),
                          child: _buildActionChip('Route Suggest'),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        GestureDetector(
                          onTap: () => context.read<AiController>().sendMessage('What is the weather report?'),
                          child: _buildActionChip('Weather'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Text('RECENT CONVERSATION', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: AppSpacing.md),

                  if (messages.isEmpty)
                    const AiChatBubble(
                      message: "Ready to coach your next ride. Ask me about weather, routes, or recovery!",
                      isAi: true,
                    )
                  else
                    ...messages.map((msg) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: AiChatBubble(
                            message: msg.text,
                            isAi: msg.isFromAi,
                          ),
                        )),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile, vertical: AppSpacing.md),
                  color: AppColors.surfaceDark.withValues(alpha: 0.6),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: TextField(
                              controller: _textController,
                              style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurface),
                              decoration: InputDecoration(
                                hintText: 'Ask AI Copilot anything...',
                                hintStyle: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        GestureDetector(
                          onTap: _sendMessage,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              gradient: AppColors.orangeGradient,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Text(label, style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurface)),
    );
  }
}
