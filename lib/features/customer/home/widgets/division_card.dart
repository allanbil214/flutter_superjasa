import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../data/models/division_model.dart';
import '../../../../data/services/mock_data_service.dart';

class DivisionCard extends StatefulWidget {
  final DivisionModel division;
  final VoidCallback onTap;

  const DivisionCard({
    super.key,
    required this.division,
    required this.onTap,
  });

  @override
  State<DivisionCard> createState() => _DivisionCardState();
}

class _DivisionCardState extends State<DivisionCard> {
  int _serviceCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServiceCount();
  }

  Future<void> _loadServiceCount() async {
    try {
      final dataService = MockDataService();
      final services = await dataService.getServicesByDivision(widget.division.id);
      if (mounted) {
        setState(() {
          _serviceCount = services.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: widget.onTap,
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
                  color: _getDivisionColor(widget.division.id).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getDivisionIcon(widget.division.id),
                  size: 28,
                  color: _getDivisionColor(widget.division.id),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.division.name,
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _isLoading ? '...' : '$_serviceCount Layanan',
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
      case 1: return Icons.electrical_services;
      case 2: return Icons.construction;
      case 3: return Icons.grid_view;
      case 4: return Icons.chair; 
      case 5: return Icons.local_laundry_service;
      case 6: return Icons.wifi;
      case 7: return Icons.print;
      default: return Icons.build;
    }
  }

  Color _getDivisionColor(int id) {
    switch (id) {
      case 1: return const Color(0xFF2196F3);
      case 2: return const Color(0xFF795548);
      case 3: return const Color(0xFFFF9800);
      case 4: return const Color(0xFF9C27B0);
      case 5: return const Color(0xFF9C27B0);
      case 6: return const Color(0xFFF44336);
      case 7: return const Color(0xFF607D8B);
      default: return AppColors.primary;
    }
  }
}