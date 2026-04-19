import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/review_model.dart';
import '../../scaffold/super_admin_scaffold.dart';

class SuperAdminUserDetailScreen extends StatefulWidget {
  final int userId;

  const SuperAdminUserDetailScreen({
    super.key,
    required this.userId,
  });

  @override
  State<SuperAdminUserDetailScreen> createState() => _SuperAdminUserDetailScreenState();
}

class _SuperAdminUserDetailScreenState extends State<SuperAdminUserDetailScreen> {
  UserModel? _user;
  List<OrderModel> _orders = [];
  List<ReviewModel> _reviews = [];
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
      
      _user = await dataService.getUserById(widget.userId);
      
      if (_user != null) {
        if (_user!.role == UserRole.customer) {
          _orders = await dataService.getOrdersByCustomer(widget.userId);
          _reviews = []; // Customer doesn't get reviewed
        } else if (_user!.role == UserRole.employee) {
          _orders = await dataService.getOrdersByEmployee(widget.userId);
          _reviews = await dataService.getReviewsByEmployee(widget.userId);
        } else {
          _orders = [];
          _reviews = [];
        }
        
        _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } catch (e) {
      _error = 'Gagal memuat data user';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0;
    return _reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length;
  }

  int get _activeOrders => _orders.where((o) => o.isActive).length;
  int get _completedOrders => _orders.where((o) => o.isCompleted).length;

  @override
  Widget build(BuildContext context) {
    return SuperAdminScaffold(
      appBar: AppAppBar(
        title: 'Detail User',
        actions: [
          Switch(
            value: _user?.isActive ?? true,
            onChanged: (_) => _toggleUserStatus(),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat data...')
          : _error != null
              ? ErrorView(message: _error!, onRetry: _loadData)
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_user == null) {
      return const ErrorView(message: 'User tidak ditemukan');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          
          // Profile Header
          _buildProfileHeader(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Stats Cards (for employee/customer)
          if (_user!.role == UserRole.employee || _user!.role == UserRole.customer)
            _buildStatsCards(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Contact Info
          _buildContactInfo(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Performance (for employee)
          if (_user!.role == UserRole.employee)
            _buildPerformanceSection(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Recent Orders
          if (_orders.isNotEmpty)
            _buildRecentOrders(),
          
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: _getRoleColor(),
                  child: Text(
                    _user!.name.substring(0, 1).toUpperCase(),
                    style: AppTextStyles.displaySmall.copyWith(color: Colors.white),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _user!.isActive ? AppColors.success : AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      _user!.isActive ? Icons.check : Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _user!.name,
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: _getRoleColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _user!.displayRole,
                style: AppTextStyles.labelMedium.copyWith(
                  color: _getRoleColor(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: _user!.role == UserRole.employee ? 'Order Aktif' : 'Total Order',
            value: _user!.role == UserRole.employee ? _activeOrders.toString() : _orders.length.toString(),
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            title: _user!.role == UserRole.employee ? 'Selesai' : 'Selesai',
            value: _completedOrders.toString(),
            color: AppColors.success,
          ),
        ),
        if (_user!.role == UserRole.employee) ...[
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildStatCard(
              title: 'Rating',
              value: _averageRating.toStringAsFixed(1),
              color: AppColors.starActive,
              subtitle: '${_reviews.length} ulasan',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    String? subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.headlineSmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: AppTextStyles.labelSmall,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informasi Kontak', style: AppTextStyles.titleSmall),
            const Divider(height: AppSpacing.xl),
            _buildInfoRow(Icons.email_outlined, 'Email', _user!.email),
            if (_user!.phone != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildInfoRow(Icons.phone_outlined, 'Telepon', _user!.phone!),
            ],
            if (_user!.address != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildInfoRow(Icons.location_on_outlined, 'Alamat', _user!.address!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
            ),
            Text(value, style: AppTextStyles.bodyMedium),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Performa', style: AppTextStyles.titleSmall),
            const Divider(height: AppSpacing.xl),
            
            _buildPerformanceBar(
              label: 'Tingkat Penyelesaian',
              value: _completedOrders / (_orders.isEmpty ? 1 : _orders.length),
              color: AppColors.success,
            ),
            const SizedBox(height: AppSpacing.md),
            
            Text('Distribusi Rating', style: AppTextStyles.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            ...List.generate(5, (index) {
              final star = 5 - index;
              final count = _reviews.where((r) => r.rating == star).length;
              final percentage = _reviews.isEmpty ? 0.0 : count / _reviews.length;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Row(
                        children: [
                          Text('$star', style: AppTextStyles.bodySmall),
                          const Icon(Icons.star, size: 14, color: AppColors.starActive),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: AppColors.divider,
                          color: AppColors.starActive,
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    SizedBox(
                      width: 30,
                      child: Text(
                        count.toString(),
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceBar({
    required String label,
    required double value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodySmall),
            Text(
              '${(value * 100).toInt()}%',
              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: AppColors.divider,
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOrders() {
    final recentOrders = _orders.take(5).toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pesanan Terbaru', style: AppTextStyles.titleSmall),
            const Divider(height: AppSpacing.xl),
            ...recentOrders.map((order) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
                          style: AppTextStyles.bodyMedium,
                        ),
                        Text(
                          order.displayStatus,
                          style: AppTextStyles.caption.copyWith(
                            color: _getStatusColor(order.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor() {
    switch (_user!.role) {
      case UserRole.customer: return AppColors.primary;
      case UserRole.employee: return AppColors.secondary;
      case UserRole.admin: return AppColors.warning;
      case UserRole.superAdmin: return const Color(0xFF4A148C);
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

  void _toggleUserStatus() {
    setState(() {
      _user = UserModel(
        id: _user!.id,
        name: _user!.name,
        email: _user!.email,
        phone: _user!.phone,
        role: _user!.role,
        avatar: _user!.avatar,
        address: _user!.address,
        isActive: !_user!.isActive,
        createdAt: _user!.createdAt,
      );
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_user!.isActive ? 'User diaktifkan' : 'User dinonaktifkan'),
        backgroundColor: _user!.isActive ? AppColors.success : AppColors.error,
      ),
    );
  }
}