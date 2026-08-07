import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

/// AI chat bubble — user and assistant message styles
class AiChatBubble extends StatelessWidget {
  const AiChatBubble({
    super.key,
    required this.message,
    this.isUser,
    this.isAi,
    this.time,
    this.showAvatar = true,
  });

  final String message;
  final bool? isUser;
  final bool? isAi;
  final String? time;
  final bool showAvatar;

  bool get userMsg => isUser ?? !(isAi ?? false);

  @override
  Widget build(BuildContext context) {
    final isMe = userMsg;
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
        horizontal: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && showAvatar) ...[
            _AiAvatar(),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm + 4,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.circuitOrange
                        : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppSpacing.radiusLg),
                      topRight: const Radius.circular(AppSpacing.radiusLg),
                      bottomLeft: Radius.circular(isMe ? AppSpacing.radiusLg : 4),
                      bottomRight: Radius.circular(isMe ? 4 : AppSpacing.radiusLg),
                    ),
                    border: isMe
                        ? null
                        : Border.all(color: AppColors.glassBorder),
                  ),
                  child: Text(
                    message,
                    style: AppTextStyles.bodyMd(
                      color: isMe ? Colors.white : AppColors.onSurface,
                    ),
                  ),
                ),
                if (time != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    time!,
                    style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
          if (isMe && showAvatar) ...[
            const SizedBox(width: AppSpacing.sm),
            _UserAvatar(),
          ],
        ],
      ),
    );
  }
}

class _AiAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: AppColors.orangeGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 18),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: const Icon(Icons.person_rounded, color: AppColors.onSurface, size: 18),
    );
  }
}
