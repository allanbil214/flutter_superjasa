import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import '../../scaffold/admin_scaffold.dart';

class AdminEmployeeDetailScreen extends StatefulWidget {
  final int employeeId;

  const AdminEmployeeDetailScreen({
    super.key,
    required this.employeeId,
  });

  @override
  State<AdminEmployeeDetailScreen> createState() => _AdminEmployeeDetailScreenState();
}

class _AdminEmployeeDetailScreenState extends State<AdminEmployeeDetailScreen> {
  UserModel? _employee;
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
      
      _employee = await dataService.getUserById(widget.employeeId);
      
      if (_employee != null) {
        final allOrders = await dataService.getOrders();
        _orders = allOrders.where((o) => o.assignedTo == widget.employeeId).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        _reviews = await dataService.getReviewsByEmployee(widget.employeeId);
      }
    } catch (e) {
      _error = 'Gagal memuat data teknisi';
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
    return AdminScaffold(
      appBar: AppAppBar(
        title: 'Detail Teknisi',
        actions: [
          Switch(
            value: _employee?.isActive ?? true,
            onChanged: (_) {
              setState(() {
                _employee = UserModel(
                  id: _employee!.id,
                  name: _employee!.name,
                  email: _employee!.email,
                  phone: _employee!.phone,
                  role: _employee!.role,
                  avatar: _employee!.avatar,
                  address: _employee!.address,
                  isActive: !_employee!.isActive,
                  createdAt: _employee!.createdAt,
                );
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _employee!.isActive 
                        ? 'Teknisi diaktifkan' 
                        : 'Teknisi dinonaktifkan',
                  ),
                ),
              );
            },
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
    if (_employee == null) {
      return const ErrorView(message: 'Teknisi tidak ditemukan');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          
          // Profile Header
          _buildProfileHeader(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Stats Cards
          _buildStatsCards(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Contact Info
          _buildContactInfo(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Performance
          _buildPerformanceSection(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Recent Orders
          _buildRecentOrders(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Reviews
          _buildReviews(),
          
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
                  backgroundColor: AppColors.secondaryLight,
                  child: Text(
                    _employee!.name.substring(0, 1).toUpperCase(),
                    style: AppTextStyles.displaySmall.copyWith(color: Colors.white),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _employee!.isActive ? AppColors.success : AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      _employee!.isActive ? Icons.check : Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _employee!.name,
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _employee!.displayRole,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.secondary,
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
            title: 'Order Aktif',
            value: _activeOrders.toString(),
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            title: 'Selesai',
            value: _completedOrders.toString(),
            color: AppColors.success,
          ),
        ),
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
            _buildInfoRow(Icons.email_outlined, 'Email', _employee!.email),
            if (_employee!.phone != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildInfoRow(Icons.phone_outlined, 'Telepon', _employee!.phone!),
            ],
            if (_employee!.address != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildInfoRow(Icons.location_on_outlined, 'Alamat', _employee!.address!),
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
            
            // Completion Rate
            _buildPerformanceBar(
              label: 'Tingkat Penyelesaian',
              value: _completedOrders / (_orders.isEmpty ? 1 : _orders.length),
              color: AppColors.success,
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Rating Distribution
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
    final recentOrders = _orders.take(3).toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pesanan Terbaru', style: AppTextStyles.titleSmall),
            const Divider(height: AppSpacing.xl),
            if (recentOrders.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'Belum ada pesanan',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
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

  Widget _buildReviews() {
    final recentReviews = _reviews.take(3).toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ulasan Terbaru', style: AppTextStyles.titleSmall),
            const Divider(height: AppSpacing.xl),
            if (recentReviews.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'Belum ada ulasan',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...recentReviews.map((review) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ...List.generate(5, (index) => Icon(
                          index < review.rating ? Icons.star : Icons.star_border,
                          size: 16,
                          color: AppColors.starActive,
                        )),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          _formatDate(review.createdAt),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    if (review.comment != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        review.comment!,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ],
                ),
              )),
          ],
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateString;
    }
  }
}