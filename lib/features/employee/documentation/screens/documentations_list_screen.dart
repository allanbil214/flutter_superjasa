import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../providers/app_state.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/employee_documentation_model.dart';
import '../../../../core/routing/route_names.dart';
import '../../scaffold/employee_scaffold.dart';

class EmployeeDocumentationsListScreen extends StatefulWidget {
  const EmployeeDocumentationsListScreen({super.key});

  @override
  State<EmployeeDocumentationsListScreen> createState() => _EmployeeDocumentationsListScreenState();
}

class _EmployeeDocumentationsListScreenState extends State<EmployeeDocumentationsListScreen> {
  List<OrderWithDocumentationCount> _orders = [];
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
      final currentUser = appState.currentUser;
      
      if (currentUser == null) return;
      
      final orders = await dataService.getOrdersByEmployee(currentUser.id);
      final documentations = await dataService.getDocumentations();
      
      List<OrderWithDocumentationCount> ordersWithCount = [];
      
      for (final order in orders) {
        final orderDocs = documentations.where((d) => d.orderId == order.id);
        final beforeCount = orderDocs.where((d) => d.stage == DocumentationStage.before).length;
        final duringCount = orderDocs.where((d) => d.stage == DocumentationStage.during).length;
        final afterCount = orderDocs.where((d) => d.stage == DocumentationStage.after).length;
        
        ordersWithCount.add(OrderWithDocumentationCount(
          order: order,
          totalDocs: orderDocs.length,
          beforeCount: beforeCount,
          duringCount: duringCount,
          afterCount: afterCount,
        ));
      }
      
      // Sort: orders that need documentation first (in progress/done with less than 3 stages)
      ordersWithCount.sort((a, b) {
        final aNeedsDocs = a.order.status == OrderStatus.inProgress || 
                           a.order.status == OrderStatus.done;
        final bNeedsDocs = b.order.status == OrderStatus.inProgress || 
                           b.order.status == OrderStatus.done;
        
        if (aNeedsDocs && !bNeedsDocs) return -1;
        if (!aNeedsDocs && bNeedsDocs) return 1;
        
        return b.order.createdAt.compareTo(a.order.createdAt);
      });
      
      setState(() => _orders = ordersWithCount);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return EmployeeScaffold(
      appBar: AppAppBar(
        title: 'Dokumentasi',
        showBackButton: false,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat dokumentasi...')
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_orders.isEmpty) {
      return const EmptyState(
        icon: Icons.photo_camera_outlined,
        title: 'Belum ada dokumentasi',
        subtitle: 'Dokumentasi dari tugas yang dikerjakan akan muncul di sini',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final data = _orders[index];
          return _buildOrderCard(data);
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderWithDocumentationCount data) {
    final needsMoreDocs = data.order.status == OrderStatus.inProgress ||
                          (data.order.status == OrderStatus.done && data.totalDocs < 3);
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {
          context.push(RouteNames.employeeOrderDocumentationsPath(data.order.id));
        },
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.order.orderCode,
                          style: AppTextStyles.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(data.order.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            data.order.displayStatus,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: _getStatusColor(data.order.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (needsMoreDocs)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_photo_alternate,
                        color: AppColors.warning,
                        size: 20,
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Documentation Progress
              Text(
                'Dokumentasi (${data.totalDocs}/3)',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _buildStageIndicator(
                    label: 'Sebelum',
                    completed: data.beforeCount > 0,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: AppColors.divider,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _buildStageIndicator(
                    label: 'Saat',
                    completed: data.duringCount > 0,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: AppColors.divider,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _buildStageIndicator(
                    label: 'Setelah',
                    completed: data.afterCount > 0,
                    color: AppColors.success,
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      context.push(RouteNames.employeeOrderDocumentationsPath(data.order.id));
                    },
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: Text('Lihat (${data.totalDocs})'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton.icon(
                    onPressed: data.order.status == OrderStatus.done && data.totalDocs >= 3
                        ? null
                        : () {
                            context.push(RouteNames.employeeAddDocumentationPath(data.order.id));
                          },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStageIndicator({
    required String label,
    required bool completed,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: completed ? color : AppColors.divider,
            shape: BoxShape.circle,
          ),
          child: completed
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(fontSize: 10),
        ),
      ],
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
}

class OrderWithDocumentationCount {
  final OrderModel order;
  final int totalDocs;
  final int beforeCount;
  final int duringCount;
  final int afterCount;

  OrderWithDocumentationCount({
    required this.order,
    required this.totalDocs,
    required this.beforeCount,
    required this.duringCount,
    required this.afterCount,
  });
}