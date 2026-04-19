import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../data/models/division_model.dart';

class DivisionCard extends StatelessWidget {
  final DivisionModel division;
  final VoidCallback onTap;

  const DivisionCard({
    super.key,
    required this.division,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getDivisionColor(division.id).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getDivisionIcon(division.id),
                  size: 28,
                  color: _getDivisionColor(division.id),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                division.name,
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _getServiceCount(),
                style: AppTextStyles.caption,
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

  String _getServiceCount() {
    // Hardcoded for prototype
    switch (division.id) {
      case 1: return '5 Layanan';
      case 2: return '5 Layanan';
      case 3: return '5 Layanan';
      case 4: return '5 Layanan';
      case 5: return '3 Layanan';
      case 6: return '4 Layanan';
      case 7: return '4 Layanan';
      default: return '0 Layanan';
    }
  }
}