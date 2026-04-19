import 'package:flutter/material.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/mock_data_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final UserModel? currentUser;
  final bool showAvatar;

  const ChatBubble({
    super.key,
    required this.message,
    this.currentUser,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.senderId == currentUser?.id;
    final isBot = message.isFromBot;
    
    if (isBot) {
      return _buildBotBubble();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && showAvatar) _buildAvatar(context, isMe),
          if (!isMe && showAvatar) const SizedBox(width: AppSpacing.sm),
          
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe && message.senderId != null)
                  FutureBuilder<UserModel?>(
                    future: MockDataService().getUserById(message.senderId!),
                    builder: (context, snapshot) {
                      return Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: 4),
                        child: Text(
                          snapshot.data?.name ?? 'User',
                          style: AppTextStyles.labelSmall,
                        ),
                      );
                    }
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.bubbleCustomer : AppColors.bubbleBot,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    message.content ?? '',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isMe ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: AppSpacing.sm, right: AppSpacing.sm),
                  child: Text(
                    _formatTime(message.createdAt),
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ),
          
          if (isMe && showAvatar) const SizedBox(width: AppSpacing.sm),
          if (isMe && showAvatar) _buildAvatar(context, isMe),
        ],
      ),
    );
  }

  Widget _buildBotBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.bubbleBot,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.content ?? '',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, bool isMe) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary : AppColors.secondary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          currentUser?.name.substring(0, 1).toUpperCase() ?? '?',
          style: AppTextStyles.labelMedium.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _formatTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}