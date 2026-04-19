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
import '../../../../core/routing/route_names.dart';
import '../../scaffold/super_admin_scaffold.dart';

class SuperAdminNotificationsScreen extends StatefulWidget {
  const SuperAdminNotificationsScreen({super.key});

  @override
  State<SuperAdminNotificationsScreen> createState() => _SuperAdminNotificationsScreenState();
}

class _SuperAdminNotificationsScreenState extends State<SuperAdminNotificationsScreen> {
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
    return SuperAdminScaffold(
      appBar: AppAppBar(
        title: 'Notifikasi',
        actions: [
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Tandai Semua',
                style: AppTextStyles.labelMedium.copyWith(
                  color: const Color(0xFF4A148C),
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
    setState(() {
      final idx = _notifications.indexWhere((n) => n.id == notification.id);
      if (idx >= 0) {
        _notifications[idx] = NotificationModel(
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
      }
    });

    if (notification.referenceType == 'orders' && notification.referenceId != null) {
      context.push(RouteNames.superAdminOrderDetailPath(notification.referenceId!));
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