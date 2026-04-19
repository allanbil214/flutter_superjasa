import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

class StatusStepper extends StatelessWidget {
  final OrderStatus currentStatus;
  final bool showLabels;

  const StatusStepper({
    super.key,
    required this.currentStatus,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = OrderStatus.values.where((s) => s != OrderStatus.cancelled).toList();
    final currentIndex = currentStatus.index;
    
    if (currentIndex < 0) {
      // Cancelled order
      return _buildCancelledStatus();
    }

    return Column(
      children: [
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: statuses.length,
            separatorBuilder: (_, __) => _buildConnector(
              index: statuses.indexOf(statuses[statuses.length - 1]),
              isActive: false,
            ),
            itemBuilder: (context, index) {
              final status = statuses[index];
              final isCompleted = index <= currentIndex;
              final isActive = index == currentIndex;
              
              return _buildStep(
                status: status,
                isCompleted: isCompleted,
                isActive: isActive,
              );
            },
          ),
        ),
        if (showLabels) ...[
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: statuses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 4),
              itemBuilder: (context, index) {
                final status = statuses[index];
                final isCompleted = index <= currentIndex;
                final isActive = index == currentIndex;
                
                return SizedBox(
                  width: 70,
                  child: Text(
                    _getStatusLabel(status),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isCompleted || isActive 
                          ? AppColors.primary 
                          : AppColors.textTertiary,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStep({
    required OrderStatus status,
    required bool isCompleted,
    required bool isActive,
  }) {
    Color backgroundColor;
    IconData icon;
    
    if (isCompleted) {
      backgroundColor = AppColors.primary;
      icon = Icons.check;
    } else if (isActive) {
      backgroundColor = AppColors.primaryLight;
      icon = _getStatusIcon(status);
    } else {
      backgroundColor = AppColors.divider;
      icon = _getStatusIcon(status);
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: isActive ? Border.all(
          color: AppColors.primary,
          width: 2,
        ) : null,
      ),
      child: Icon(
        icon,
        size: 16,
        color: isCompleted || isActive ? Colors.white : AppColors.textTertiary,
      ),
    );
  }

  Widget _buildConnector({required int index, required bool isActive}) {
    return Container(
      width: 20,
      height: 2,
      color: isActive ? AppColors.primary : AppColors.divider,
    );
  }

  Widget _buildCancelledStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cancel, color: AppColors.error, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Pesanan Dibatalkan',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.hourglass_empty;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.assigned:
        return Icons.person_outline;
      case OrderStatus.onTheWay:
        return Icons.directions_bike;
      case OrderStatus.inProgress:
        return Icons.build_circle_outlined;
      case OrderStatus.done:
        return Icons.task_alt;
      case OrderStatus.reviewed:
        return Icons.star_outline;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Menunggu';
      case OrderStatus.confirmed:
        return 'Dikonfirmasi';
      case OrderStatus.assigned:
        return 'Ditugaskan';
      case OrderStatus.onTheWay:
        return 'OTW';
      case OrderStatus.inProgress:
        return 'Dikerjakan';
      case OrderStatus.done:
        return 'Selesai';
      case OrderStatus.reviewed:
        return 'Diulas';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
    }
  }
}