import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/notification_list_tile.dart';
import '../../../../providers/app_state.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../data/models/notification_model.dart';

class CustomerNotificationsScreen extends StatefulWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  State<CustomerNotificationsScreen> createState() => _CustomerNotificationsScreenState();
}

class _CustomerNotificationsScreenState extends State<CustomerNotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final dataService = MockDataService();
      _notifications = await dataService.getNotificationsByUser(appState.currentUserId);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        title: 'Notifikasi',
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Tandai Semua Dibaca',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat notifikasi...')
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_notifications.isEmpty) {
      return const EmptyState(
        icon: Icons.notifications_outlined,
        title: 'Belum ada notifikasi',
        subtitle: 'Notifikasi akan muncul di sini',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          return NotificationListTile(
            notification: _notifications[index],
            onTap: () => _handleNotificationTap(_notifications[index]),
          );
        },
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read
    setState(() {
      notification = NotificationModel(
        id: notification.id,
        userId: notification.userId,
        title: notification.title,
        body: notification.body,
        type: notification.type,
        referenceId: notification.referenceId,
        referenceType: notification.referenceType,
        isRead: true,
        createdAt: notification.createdAt,
      );
    });

    // Navigate based on type
    if (notification.referenceType == 'orders' && notification.referenceId != null) {
      context.push('/customer/orders/${notification.referenceId}');
    } else if (notification.referenceType == 'payments' && notification.referenceId != null) {
      // Navigate to payment or order
    }
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) {
        return NotificationModel(
          id: n.id,
          userId: n.userId,
          title: n.title,
          body: n.body,
          type: n.type,
          referenceId: n.referenceId,
          referenceType: n.referenceType,
          isRead: true,
          createdAt: n.createdAt,
        );
      }).toList();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semua notifikasi ditandai dibaca')),
    );
  }
}