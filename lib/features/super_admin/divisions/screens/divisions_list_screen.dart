import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../data/models/division_model.dart';
import '../../../../core/routing/route_names.dart';
import '../../scaffold/super_admin_scaffold.dart';

class SuperAdminDivisionsListScreen extends StatefulWidget {
  const SuperAdminDivisionsListScreen({super.key});

  @override
  State<SuperAdminDivisionsListScreen> createState() => _SuperAdminDivisionsListScreenState();
}

class _SuperAdminDivisionsListScreenState extends State<SuperAdminDivisionsListScreen> {
  List<DivisionWithStats> _divisions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final dataService = MockDataService();
      final divisions = await dataService.getDivisions();
      final orders = await dataService.getOrders();
      
      List<DivisionWithStats> divisionsWithStats = [];
      
      for (final division in divisions) {
        final divisionOrders = orders.where((o) => o.divisionId == division.id);
        final totalOrders = divisionOrders.length;
        final activeOrders = divisionOrders.where((o) => o.isActive).length;
        final completedOrders = divisionOrders.where((o) => o.isCompleted).length;
        
        final revenue = totalOrders * 250000.0;
        
        divisionsWithStats.add(DivisionWithStats(
          division: division,
          totalOrders: totalOrders,
          activeOrders: activeOrders,
          completedOrders: completedOrders,
          revenue: revenue,
        ));
      }
      
      setState(() => _divisions = divisionsWithStats);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SuperAdminScaffold(
      appBar: AppAppBar(
        title: 'Semua Divisi',
        showBackButton: false,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat divisi...')
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        itemCount: _divisions.length,
        itemBuilder: (context, index) {
          return _buildDivisionCard(_divisions[index]);
        },
      ),
    );
  }

  Widget _buildDivisionCard(DivisionWithStats data) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {
          context.push(RouteNames.superAdminDivisionDetailPath(data.division.id));
        },
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getDivisionColor(data.division.id).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getDivisionIcon(data.division.id),
                      color: _getDivisionColor(data.division.id),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.division.name,
                          style: AppTextStyles.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.division.description ?? '',
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    data.division.isActive
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: data.division.isActive
                        ? AppColors.success
                        : AppColors.error,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('Total Order', data.totalOrders.toString()),
                  _buildStat('Aktif', data.activeOrders.toString(), color: AppColors.warning),
                  _buildStat('Selesai', data.completedOrders.toString(), color: AppColors.success),
                  _buildStat('Pendapatan', _formatCurrency(data.revenue)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
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

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}

class DivisionWithStats {
  final DivisionModel division;
  final int totalOrders;
  final int activeOrders;
  final int completedOrders;
  final double revenue;

  DivisionWithStats({
    required this.division,
    required this.totalOrders,
    required this.activeOrders,
    required this.completedOrders,
    required this.revenue,
  });
}