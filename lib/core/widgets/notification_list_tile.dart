import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

class NotificationListTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationListTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: notification.isRead ? null : AppColors.primary.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.xs,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getIconBackground(notification.type),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getIcon(notification.type),
          size: 20,
          color: Colors.white,
        ),
      ),
      title: Text(
        notification.title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            notification.body,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(notification.createdAt),
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'payment':
        return Icons.payment;
      case 'order_update':
        return Icons.assignment;
      case 'new_order':
        return Icons.add_shopping_cart;
      case 'assignment':
        return Icons.person_add;
      case 'chat':
        return Icons.chat_bubble_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getIconBackground(String type) {
    switch (type) {
      case 'payment':
        return AppColors.warning;
      case 'order_update':
        return AppColors.info;
      case 'new_order':
        return AppColors.success;
      case 'assignment':
        return AppColors.primary;
      case 'chat':
        return AppColors.secondary;
      default:
        return AppColors.textTertiary;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inMinutes < 1) {
        return 'Baru saja';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} menit yang lalu';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} jam yang lalu';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari yang lalu';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (_) {
      return dateString;
    }
  }
}