import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../data/models/division_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/service_model.dart';
import '../../../../core/routing/route_names.dart';
import '../../scaffold/super_admin_scaffold.dart';

class SuperAdminDivisionDetailScreen extends StatefulWidget {
  final int divisionId;

  const SuperAdminDivisionDetailScreen({
    super.key,
    required this.divisionId,
  });

  @override
  State<SuperAdminDivisionDetailScreen> createState() => _SuperAdminDivisionDetailScreenState();
}

class _SuperAdminDivisionDetailScreenState extends State<SuperAdminDivisionDetailScreen> {
  DivisionModel? _division;
  List<UserModel> _admins = [];
  List<UserModel> _employees = [];
  List<ServiceModel> _services = [];
  List<OrderModel> _recentOrders = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final dataService = MockDataService();
      
      _division = await dataService.getDivisionById(widget.divisionId);
      
      if (_division != null) {
        _admins = await dataService.getAdminsByDivision(widget.divisionId);
        _employees = await dataService.getEmployeesByDivision(widget.divisionId);
        _services = await dataService.getServicesByDivision(widget.divisionId);
        
        final orders = await dataService.getOrdersByDivision(widget.divisionId);
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _recentOrders = orders.take(5).toList();
        
        _stats = {
          'total_orders': orders.length,
          'active_orders': orders.where((o) => o.isActive).length,
          'completed_orders': orders.where((o) => o.isCompleted).length,
          'total_revenue': orders.length * 250000.0,
          'avg_rating': 4.6,
        };
      }
    } catch (e) {
      _error = 'Gagal memuat detail divisi';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SuperAdminScaffold(
      appBar: AppAppBar(
        title: _division?.name ?? 'Detail Divisi',
        actions: [
          Switch(
            value: _division?.isActive ?? true,
            onChanged: (_) => _toggleDivisionStatus(),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat detail...')
          : _error != null
              ? ErrorView(message: _error!, onRetry: _loadData)
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_division == null) {
      return const ErrorView(message: 'Divisi tidak ditemukan');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          
          // Header
          _buildHeader(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Stats Cards
          _buildStatsCards(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Admins
          _buildAdminsSection(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Employees
          _buildEmployeesSection(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Services
          _buildServicesSection(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Recent Orders
          _buildRecentOrders(),
          
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getDivisionColor().withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getDivisionIcon(),
                color: _getDivisionColor(),
                size: 30,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _division!.name,
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _division!.description ?? '',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          title: 'Total Order',
          value: '${_stats['total_orders']}',
          icon: Icons.shopping_cart_outlined,
          color: AppColors.primary,
        ),
        _buildStatCard(
          title: 'Order Aktif',
          value: '${_stats['active_orders']}',
          icon: Icons.pending_actions,
          color: AppColors.warning,
        ),
        _buildStatCard(
          title: 'Pendapatan',
          value: _formatCurrency(_stats['total_revenue']),
          icon: Icons.payments_outlined,
          color: AppColors.success,
        ),
        _buildStatCard(
          title: 'Rating',
          value: '${_stats['avg_rating']} ⭐',
          icon: Icons.star_outline,
          color: AppColors.starActive,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const Spacer(),
            Text(
              value,
              style: AppTextStyles.titleLarge.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Admin (${_admins.length})', style: AppTextStyles.titleSmall),
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _admins.isEmpty
            ? Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'Belum ada admin',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            : Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _admins.map((admin) => _buildUserChip(admin, true)).toList(),
              ),
      ],
    );
  }

  Widget _buildEmployeesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Teknisi (${_employees.length})', style: AppTextStyles.titleSmall),
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _employees.isEmpty
            ? Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'Belum ada teknisi',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            : Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _employees.map((emp) => _buildUserChip(emp, false)).toList(),
              ),
      ],
    );
  }

  Widget _buildUserChip(UserModel user, bool isAdmin) {
    return ActionChip(
      avatar: CircleAvatar(
        backgroundColor: isAdmin ? AppColors.primaryLight : AppColors.secondaryLight,
        child: Text(
          user.name.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      label: Text(user.name),
      onPressed: () {
        context.push(RouteNames.superAdminUserDetailPath(user.id));
      },
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Layanan (${_services.length})', style: AppTextStyles.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _services.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final service = _services[index];
              return ListTile(
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.build, size: 16, color: AppColors.primary),
                ),
                title: Text(service.name),
                subtitle: Text(service.formattedPrice),
                trailing: service.isActive
                    ? const Icon(Icons.check_circle, color: AppColors.success, size: 20)
                    : const Icon(Icons.cancel, color: AppColors.error, size: 20),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pesanan Terbaru', style: AppTextStyles.titleSmall),
            TextButton(
              onPressed: () => context.go(RouteNames.superAdminOrders),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _recentOrders.isEmpty
            ? Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Center(
                    child: Text(
                      'Belum ada pesanan',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              )
            : Column(
                children: _recentOrders.map((order) => Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ListTile(
                    leading: Container(
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
                    title: Text(order.orderCode),
                    subtitle: Text(order.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Container(
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
                    onTap: () {
                      context.push(RouteNames.superAdminOrderDetailPath(order.id));
                    },
                  ),
                )).toList(),
              ),
      ],
    );
  }

  IconData _getDivisionIcon() {
    switch (widget.divisionId) {
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

  Color _getDivisionColor() {
    switch (widget.divisionId) {
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

  void _toggleDivisionStatus() {
    setState(() {
      _division = DivisionModel(
        id: _division!.id,
        name: _division!.name,
        slug: _division!.slug,
        description: _division!.description,
        icon: _division!.icon,
        isActive: !_division!.isActive,
        adminIds: _division!.adminIds,
        employeeIds: _division!.employeeIds,
        createdAt: _division!.createdAt,
      );
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_division!.isActive ? 'Divisi diaktifkan' : 'Divisi dinonaktifkan'),
        backgroundColor: _division!.isActive ? AppColors.success : AppColors.error,
      ),
    );
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return 'Rp 0';
    final numValue = amount is int ? amount : (amount as double).toInt();
    return 'Rp ${numValue.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}