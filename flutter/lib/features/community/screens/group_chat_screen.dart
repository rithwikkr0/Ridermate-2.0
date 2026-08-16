import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

import '../../../core/widgets/rm_text_field.dart';

class GroupChatScreen extends StatelessWidget {
  const GroupChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final messages = [
      {'text': 'Hey everyone, who is up for a ride this weekend?', 'isMe': false, 'sender': 'Arjun'},
      {'text': 'I am in! Where to?', 'isMe': true, 'sender': 'You'},
      {'text': 'Thinking of doing the Lonavala route early morning.', 'isMe': false, 'sender': 'Arjun'},
      {'text': 'Sounds good. What time?', 'isMe': false, 'sender': 'Priya'},
      {'text': 'Meet at 5:30 AM at the usual spot?', 'isMe': true, 'sender': 'You'},
      {'text': 'Perfect! See you all then.', 'isMe': false, 'sender': 'Arjun'},
    ];

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerHigh.withValues(alpha: 0.8),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mumbai Riders', style: AppTextStyles.headlineSm()),
            Text('128 members', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ),
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
          Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.marginMobile,
                    vertical: AppSpacing.md,
                  ),
                  itemCount: messages.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['isMe'] as bool;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.circuitOrange : AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
                          ),
                          border: isMe ? null : Border.all(color: AppColors.glassBorder),
                        ),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe) ...[
                              Text(msg['sender'] as String, style: AppTextStyles.labelCaps().copyWith(color: AppColors.circuitOrange)),
                              const SizedBox(height: 4),
                            ],
                            Text(
                              msg['text'] as String,
                              style: AppTextStyles.bodyMd().copyWith(
                                color: isMe ? Colors.white : AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 100 * index)).slideY(begin: 0.1);
                  },
                ),
              ),
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: EdgeInsets.only(
                      left: AppSpacing.marginMobile,
                      right: AppSpacing.marginMobile,
                      top: AppSpacing.md,
                      bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
                    ),
                    color: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
                    child: Row(
                      children: [
                        Expanded(
                          child: RmTextField(
                            hintText: 'Type a message...',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          decoration: const BoxDecoration(
                            color: AppColors.circuitOrange,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
