import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../providers/app_state.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/payment_model.dart';
import '../../../../core/routing/route_names.dart';
import '../../scaffold/admin_scaffold.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  int _pendingOrders = 0;
  int _activeOrders = 0;
  int _completedOrders = 0;
  int _pendingPayments = 0;
  double _todayRevenue = 0;
  List<OrderModel> _recentOrders = [];
  List<PaymentModel> _pendingPaymentList = [];

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
      
      // Get admin's division
      final currentUser = appState.currentUser;
      if (currentUser == null) return;
      
      // Find which division this admin manages
      final divisions = await dataService.getDivisions();
      final adminDivision = divisions.firstWhere(
        (d) => d.adminIds.contains(currentUser.id),
        orElse: () => divisions.first,
      );
      
      // Get orders for this division
      final orders = await dataService.getOrdersByDivision(adminDivision.id);
      
      // Calculate stats
      _pendingOrders = orders.where((o) => o.status == OrderStatus.pending).length;
      _activeOrders = orders.where((o) => 
        o.status == OrderStatus.confirmed || 
        o.status == OrderStatus.assigned ||
        o.status == OrderStatus.onTheWay ||
        o.status == OrderStatus.inProgress
      ).length;
      _completedOrders = orders.where((o) => 
        o.status == OrderStatus.done || 
        o.status == OrderStatus.reviewed
      ).length;
      
      // Get recent orders (last 5)
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _recentOrders = orders.take(5).toList();
      
      // Get pending payments
      final payments = await dataService.getPayments();
      _pendingPaymentList = payments.where((p) => 
        p.status == PaymentStatus.uploaded || p.status == PaymentStatus.pending
      ).toList();
      _pendingPayments = _pendingPaymentList.length;
      
      // Calculate today's revenue (mock)
      _todayRevenue = 1250000;
      
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    return AdminScaffold(
      appBar: AppAppBar(
        title: 'Dashboard Admin',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(RouteNames.adminNotifications),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => context.push(RouteNames.adminReports),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat dashboard...')
          : _buildBody(appState),
    );
  }

  Widget _buildBody(AppState appState) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            
            // Welcome Card
            _buildWelcomeCard(appState),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Stats Cards
            _buildStatsGrid(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Pending Payments Alert
            if (_pendingPayments > 0) _buildPaymentAlert(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Recent Orders
            _buildRecentOrders(),
            
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  appState.currentUser?.name.substring(0, 1).toUpperCase() ?? 'A',
                  style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat datang,',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      appState.currentUser?.name ?? 'Admin',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Hari ini: ${_formatCurrency(_todayRevenue)}',
            style: AppTextStyles.headlineSmall.copyWith(
              color: Colors.white,
            ),
          ),
          Text(
            'Pendapatan hari ini',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          title: 'Menunggu',
          value: _pendingOrders.toString(),
          icon: Icons.hourglass_empty,
          color: AppColors.statusPending,
          onTap: () => context.go(RouteNames.adminOrders),
        ),
        _buildStatCard(
          title: 'Aktif',
          value: _activeOrders.toString(),
          icon: Icons.autorenew,
          color: AppColors.statusInProgress,
          onTap: () => context.go(RouteNames.adminOrders),
        ),
        _buildStatCard(
          title: 'Selesai',
          value: _completedOrders.toString(),
          icon: Icons.check_circle_outline,
          color: AppColors.statusDone,
          onTap: () => context.go(RouteNames.adminOrders),
        ),
        _buildStatCard(
          title: 'Pembayaran',
          value: _pendingPayments.toString(),
          icon: Icons.payments_outlined,
          color: AppColors.warning,
          badge: _pendingPayments > 0,
          onTap: _pendingPayments > 0 
              ? () => _showPaymentSheet() 
              : null,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool badge = false,
    VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  if (badge) ...[
                    const Spacer(),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              const Spacer(),
              Text(
                value,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentAlert() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.payments_outlined,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_pendingPayments pembayaran menunggu verifikasi',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Tap untuk verifikasi',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: () => _showPaymentSheet(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pesanan Terbaru',
              style: AppTextStyles.titleMedium,
            ),
            TextButton(
              onPressed: () => context.go(RouteNames.adminOrders),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_recentOrders.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Text('Belum ada pesanan'),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentOrders.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final order = _recentOrders[index];
              return _buildOrderTile(order);
            },
          ),
      ],
    );
  }

  Widget _buildOrderTile(OrderModel order) {
    return Card(
      child: InkWell(
        onTap: () => context.push(RouteNames.adminOrderDetailPath(order.id)),
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  color: _getStatusColor(order.status),
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderCode,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.address,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.displayStatus,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: _getStatusColor(order.status),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.statusPending;
      case OrderStatus.confirmed:
        return AppColors.statusConfirmed;
      case OrderStatus.assigned:
        return AppColors.statusAssigned;
      case OrderStatus.onTheWay:
        return AppColors.statusOnTheWay;
      case OrderStatus.inProgress:
        return AppColors.statusInProgress;
      case OrderStatus.done:
        return AppColors.statusDone;
      case OrderStatus.reviewed:
        return AppColors.statusReviewed;
      case OrderStatus.cancelled:
        return AppColors.statusCancelled;
    }
  }

  void _showPaymentSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardBorderRadius),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Verifikasi Pembayaran',
                      style: AppTextStyles.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _pendingPaymentList.length,
                  itemBuilder: (context, index) {
                    final payment = _pendingPaymentList[index];
                    return FutureBuilder<OrderModel?>(
                      future: MockDataService().getOrders().then(
                        (orders) => orders.firstWhere((o) => o.id == payment.orderId),
                      ),
                      builder: (context, snapshot) {
                        final order = snapshot.data;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.warning.withOpacity(0.1),
                            child: const Icon(
                              Icons.payments_outlined,
                              color: AppColors.warning,
                            ),
                          ),
                          title: Text(order?.orderCode ?? 'Order #${payment.orderId}'),
                          subtitle: Text(
                            payment.formattedAmount,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              context.push(
                                RouteNames.adminVerifyPaymentPath(payment.orderId),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: const Text('Verifikasi'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}