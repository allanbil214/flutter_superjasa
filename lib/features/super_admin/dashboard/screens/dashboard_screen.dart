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
import '../../../../data/models/division_model.dart';
import '../../../../core/routing/route_names.dart';
import '../../scaffold/super_admin_scaffold.dart';

class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() => _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  bool _isLoading = true;
  List<DivisionModel> _divisions = [];
  List<OrderModel> _recentOrders = [];
  Map<String, dynamic> _globalStats = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final dataService = MockDataService();
      
      _divisions = await dataService.getDivisions();
      final orders = await dataService.getOrders();
      
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _recentOrders = orders.take(10).toList();
      
      // Calculate global stats
      final totalOrders = orders.length;
      final activeOrders = orders.where((o) => o.isActive).length;
      final completedOrders = orders.where((o) => o.isCompleted).length;
      final pendingOrders = orders.where((o) => o.status == OrderStatus.pending).length;
      
      // Revenue mock
      final totalRevenue = 45750000;
      final monthlyRevenue = 12500000;
      
      _globalStats = {
        'total_orders': totalOrders,
        'active_orders': activeOrders,
        'completed_orders': completedOrders,
        'pending_orders': pendingOrders,
        'total_revenue': totalRevenue,
        'monthly_revenue': monthlyRevenue,
        'total_divisions': _divisions.length,
        'total_employees': 11,
        'total_customers': 8,
      };
      
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    return SuperAdminScaffold(
      appBar: AppAppBar(
        title: 'Dashboard Super Admin',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(RouteNames.superAdminNotifications),
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
            
            // Key Metrics
            _buildKeyMetrics(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Division Performance
            _buildDivisionPerformance(),
            
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
            const Color(0xFF4A148C),
            const Color(0xFF7B1FA2),
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
                radius: 28,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  appState.currentUser?.name.substring(0, 1).toUpperCase() ?? 'SA',
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
                      appState.currentUser?.name ?? 'Super Admin',
                      style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Total Pendapatan: ${_formatCurrency(_globalStats['total_revenue'])}',
            style: AppTextStyles.headlineSmall.copyWith(color: Colors.white),
          ),
          Text(
            'Bulan ini: ${_formatCurrency(_globalStats['monthly_revenue'])}',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.3,
      children: [
        _buildMetricCard(
          title: 'Total Order',
          value: '${_globalStats['total_orders']}',
          icon: Icons.shopping_cart_outlined,
          color: AppColors.primary,
        ),
        _buildMetricCard(
          title: 'Order Aktif',
          value: '${_globalStats['active_orders']}',
          icon: Icons.pending_actions,
          color: AppColors.warning,
        ),
        _buildMetricCard(
          title: 'Divisi',
          value: '${_globalStats['total_divisions']}',
          icon: Icons.business_outlined,
          color: AppColors.info,
        ),
        _buildMetricCard(
          title: 'Teknisi',
          value: '${_globalStats['total_employees']}',
          icon: Icons.engineering_outlined,
          color: AppColors.secondary,
        ),
        _buildMetricCard(
          title: 'Pelanggan',
          value: '${_globalStats['total_customers']}',
          icon: Icons.people_outline,
          color: AppColors.success,
        ),
        _buildMetricCard(
          title: 'Menunggu',
          value: '${_globalStats['pending_orders']}',
          icon: Icons.hourglass_empty,
          color: AppColors.error,
          badge: _globalStats['pending_orders'] > 0,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool badge = false,
  }) {
    return Card(
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
    );
  }

  Widget _buildDivisionPerformance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Performa Divisi', style: AppTextStyles.titleMedium),
            TextButton(
              onPressed: () => context.go(RouteNames.superAdminDivisions),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _divisions.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final division = _divisions[index];
              return _buildDivisionCard(division);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDivisionCard(DivisionModel division) {
    return Card(
      child: InkWell(
        onTap: () {
          context.push(RouteNames.superAdminDivisionDetailPath(division.id));
        },
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getDivisionColor(division.id).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getDivisionIcon(division.id),
                  color: _getDivisionColor(division.id),
                  size: 20,
                ),
              ),
              const Spacer(),
              Text(
                division.name,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '5 layanan',
                style: AppTextStyles.caption,
              ),
            ],
          ),
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
            Text('Pesanan Terbaru', style: AppTextStyles.titleMedium),
            TextButton(
              onPressed: () => context.go(RouteNames.superAdminOrders),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
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
        onTap: () {
          context.push(RouteNames.superAdminOrderDetailPath(order.id));
        },
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
                    FutureBuilder<DivisionModel?>(
                      future: MockDataService().getDivisionById(order.divisionId),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data?.name ?? 'Divisi #${order.divisionId}',
                          style: AppTextStyles.caption,
                        );
                      }
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

  IconData _getDivisionIcon(int id) {
    switch (id) {
      case 1: return Icons.ac_unit;
      case 2: return Icons.phone_android;
      case 3: return Icons.tv;
      case 4: return Icons.computer;
      case 5: return Icons.local_laundry_service;
      case 6: return Icons.wifi;
      case 7: return Icons.print;
      default: return Icons.build;
    }
  }

  Color _getDivisionColor(int id) {
    switch (id) {
      case 1: return const Color(0xFF00BCD4);
      case 2: return const Color(0xFF4CAF50);
      case 3: return const Color(0xFFFF9800);
      case 4: return const Color(0xFF2196F3);
      case 5: return const Color(0xFF9C27B0);
      case 6: return const Color(0xFFF44336);
      case 7: return const Color(0xFF607D8B);
      default: return AppColors.primary;
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return AppColors.statusPending;
      case OrderStatus.confirmed: return AppColors.statusConfirmed;
      case OrderStatus.assigned: return AppColors.statusAssigned;
      case OrderStatus.onTheWay: return AppColors.statusOnTheWay;
      case OrderStatus.inProgress: return AppColors.statusInProgress;
      case OrderStatus.done: return AppColors.statusDone;
      case OrderStatus.reviewed: return AppColors.statusReviewed;
      case OrderStatus.cancelled: return AppColors.statusCancelled;
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return 'Rp 0';
    final numValue = amount is int ? amount : (amount as double).toInt();
    return 'Rp ${numValue.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}