import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

import '../../../core/widgets/rm_text_field.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Hey everyone, who is up for a ride this weekend?', 'isMe': false, 'sender': 'Arjun'},
    {'text': 'I am in! Where to?', 'isMe': true, 'sender': 'You'},
    {'text': 'Thinking of doing the Lonavala route early morning.', 'isMe': false, 'sender': 'Arjun'},
    {'text': 'Sounds good. What time?', 'isMe': false, 'sender': 'Priya'},
    {'text': 'Meet at 5:30 AM at the usual spot?', 'isMe': true, 'sender': 'You'},
    {'text': 'Perfect! See you all then.', 'isMe': false, 'sender': 'Arjun'},
  ];

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'isMe': true, 'sender': 'You'});
      _textController.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
            Text('${128 + _messages.length} messages', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
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
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.marginMobile,
                    vertical: AppSpacing.md,
                  ),
                  itemCount: _messages.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
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
                    );
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
                            controller: _textController,
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
                            onPressed: _sendMessage,
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
