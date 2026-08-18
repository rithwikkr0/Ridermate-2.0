import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/ai_chat_bubble.dart';
import '../../../core/widgets/rm_scroll_body.dart';
import '../../../core/widgets/rm_nav_controller.dart';
import '../../../core/router/app_router.dart';
import '../../../providers/base_controller.dart';
import '../controllers/ai_controller.dart';

class AiCopilotHomeScreen extends StatefulWidget {
  const AiCopilotHomeScreen({super.key});

  @override
  State<AiCopilotHomeScreen> createState() => _AiCopilotHomeScreenState();
}

class _AiCopilotHomeScreenState extends State<AiCopilotHomeScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? customText]) {
    final text = (customText ?? _textController.text).trim();
    if (text.isNotEmpty) {
      context.read<AiController>().sendMessage(text);
      if (customText == null) {
        _textController.clear();
      }
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final aiController = context.watch<AiController>();
    final messages = aiController.messages;
    final isLoading = aiController.state == ViewState.loading;
    final isError = aiController.state == ViewState.error;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.greenAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.greenAccent, blurRadius: 6),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'RiderMate AI Copilot',
              style: AppTextStyles.headlineSm(color: Colors.white),
            ),
          ],
        ),
        actions: [
          if (messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.onSurfaceVariant),
              tooltip: 'Clear Conversation',
              onPressed: () {
                context.read<AiController>().clearConversation();
              },
            ),
          IconButton(
            icon: const Icon(Icons.mic, color: AppColors.circuitOrange),
            tooltip: 'Voice Assistant',
            onPressed: () => context.push(AppRoutes.aiListening),
          ),
        ],
      ),
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
          RmScrollBody(
            child: SafeArea(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.marginMobile,
                  AppSpacing.sm,
                  AppSpacing.marginMobile,
                  140, // Bottom clearance for input bar
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AI Status & Prompt Chips
                    Text('HIGH-PRECISION RIDING INTELLIGENCE',
                        style: AppTextStyles.labelCaps(color: AppColors.circuitOrange))
                        .animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: 4),
                    Text('Ready to assist your ride.',
                        style: AppTextStyles.headlineMd(color: AppColors.onSurface))
                        .animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: AppSpacing.md),

                    // Quick Topic Suggestions
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildTopicChip('🗺️ Trip Planning', 'Plan a weekend motorcycle touring trip with fuel stops'),
                          const SizedBox(width: 8),
                          _buildTopicChip('🛣️ Route Suggestions', 'Suggest scenic twisty routes with good pavement'),
                          const SizedBox(width: 8),
                          _buildTopicChip('🔧 Maintenance Intel', 'What is the recommended tire pressure and chain slack?'),
                          const SizedBox(width: 8),
                          _buildTopicChip('🛡️ Safety & Cornering', 'Give me safety coaching for trail braking and counter-steering'),
                          const SizedBox(width: 8),
                          _buildTopicChip('🌦️ Weather Advisory', 'What is the monsoon wet weather riding protocol?'),
                          const SizedBox(width: 8),
                          _buildTopicChip('🚨 Emergency Checklist', 'What should I do in case of a motorcycle crash or SOS?'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Conversation Timeline
                    Text('CONVERSATION TIMELINE',
                        style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: AppSpacing.md),

                    if (messages.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.circuitOrange.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.psychology, color: AppColors.circuitOrange, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('RiderMate AI Copilot', style: AppTextStyles.headlineSm(color: Colors.white)),
                                      Text('Ready for real-time telemetry, routing & safety queries.',
                                          style: AppTextStyles.caption(color: AppColors.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Tap any quick topic above or type a custom question below to start analyzing your motorcycle telemetry, trip logistics, and road safety.',
                              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms)
                    else
                      ...messages.map((msg) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: AiChatBubble(
                              message: msg.text,
                              isAi: msg.isFromAi,
                            ),
                          )),

                    // Loading / Thinking Shimmer
                    if (isLoading)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.circuitOrange.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.circuitOrange),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'RiderMate AI analyzing...',
                                    style: AppTextStyles.caption(color: AppColors.circuitOrange),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 200.ms),

                    // Error & Retry
                    if (isError)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'AI request failed. Please check network or try again.',
                                  style: AppTextStyles.bodySm(color: Colors.redAccent),
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.read<AiController>().retryLastMessage(),
                                child: Text('Retry', style: AppTextStyles.statLabel(color: AppColors.circuitOrange)),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Input Bar
          Builder(
            builder: (context) {
              final isNavVisible = RmNavScope.maybeOf(context)?.visible ?? true;
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                bottom: isNavVisible ? 85 : 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.marginMobile,
                        vertical: AppSpacing.md,
                      ),
                      color: AppColors.surfaceDark.withValues(alpha: 0.7),
                      child: SafeArea(
                        top: false,
                        bottom: !isNavVisible,
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
                                  style: AppTextStyles.bodyMd(color: AppColors.onSurface),
                                  decoration: InputDecoration(
                                    hintText: 'Ask RiderMate AI anything...',
                                    hintStyle: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (_) => _sendMessage(),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            GestureDetector(
                              onTap: () => _sendMessage(),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  gradient: AppColors.orangeGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x66FF6B00),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopicChip(String label, String prompt) {
    return GestureDetector(
      onTap: () => _sendMessage(prompt),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelCapsSm(color: AppColors.onSurface),
        ),
      ),
    );
  }
}
