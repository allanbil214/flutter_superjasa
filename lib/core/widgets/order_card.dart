import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';
import '../../data/models/service_model.dart';
import '../../data/services/mock_data_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;
  final bool showStatus;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.showStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getServiceDetails(),
      builder: (context, snapshot) {
        final service = snapshot.data;
        
        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.xs,
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Order Code & Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.orderCode,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      if (showStatus)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            order.displayStatus,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: _getStatusColor(order.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.sm),
                  
                  // Service Name
                  Text(
                    service?.name ?? 'Layanan #${order.serviceId}',
                    style: AppTextStyles.titleSmall,
                  ),
                  
                  const SizedBox(height: AppSpacing.xs),
                  
                  // Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          order.address,
                          style: AppTextStyles.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  if (order.scheduledAt != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          _formatDate(order.scheduledAt!),
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: AppSpacing.sm),
                  
                  // Divider
                  const Divider(height: 1),
                  
                  const SizedBox(height: AppSpacing.sm),
                  
                  // Footer: Price
                  FutureBuilder<double>(
                    future: _getOrderTotal(),
                    builder: (context, totalSnapshot) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Total: ',
                            style: AppTextStyles.bodySmall,
                          ),
                          Text(
                            _formatCurrency(totalSnapshot.data ?? 0),
                            style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      );
                    }
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<ServiceModel?> _getServiceDetails() async {
    return await MockDataService().getServiceById(order.serviceId);
  }

  Future<double> _getOrderTotal() async {
    return await MockDataService().getOrderTotal(order.id);
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
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateString;
    }
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}