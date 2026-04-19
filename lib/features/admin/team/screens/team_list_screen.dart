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
import '../../../../data/models/user_model.dart';
import '../../../../data/models/order_model.dart';
import '../../../../core/routing/route_names.dart';
import '../../scaffold/admin_scaffold.dart';

class AdminTeamListScreen extends StatefulWidget {
  const AdminTeamListScreen({super.key});

  @override
  State<AdminTeamListScreen> createState() => _AdminTeamListScreenState();
}

class _AdminTeamListScreenState extends State<AdminTeamListScreen> {
  List<EmployeeWithStats> _employees = [];
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
      
      final divisions = await dataService.getDivisions();
      final adminDivision = divisions.firstWhere(
        (d) => d.adminIds.contains(currentUser.id),
        orElse: () => divisions.first,
      );
      
      final employees = await dataService.getEmployeesByDivision(adminDivision.id);
      final orders = await dataService.getOrdersByDivision(adminDivision.id);
      
      List<EmployeeWithStats> employeesWithStats = [];
      
      for (final employee in employees) {
        final employeeOrders = orders.where((o) => o.assignedTo == employee.id);
        final activeOrders = employeeOrders.where((o) => o.isActive).length;
        final completedOrders = employeeOrders.where((o) => o.isCompleted).length;
        
        employeesWithStats.add(EmployeeWithStats(
          employee: employee,
          activeOrders: activeOrders,
          completedOrders: completedOrders,
          isAvailable: activeOrders < 3,
        ));
      }
      
      setState(() => _employees = employeesWithStats);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      appBar: AppAppBar(
        title: 'Tim Saya',
        showBackButton: false,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat tim...')
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        children: [
          const SizedBox(height: AppSpacing.md),
          
          // Summary Cards
          _buildSummaryCards(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Team List Title
          Text(
            'Daftar Teknisi',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Team List
          ..._employees.map((data) => _buildEmployeeCard(data)),
          
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalEmployees = _employees.length;
    final availableEmployees = _employees.where((e) => e.isAvailable).length;
    final totalActive = _employees.fold(0, (sum, e) => sum + e.activeOrders);
    final totalCompleted = _employees.fold(0, (sum, e) => sum + e.completedOrders);
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          title: 'Total Teknisi',
          value: totalEmployees.toString(),
          icon: Icons.people_outline,
          color: AppColors.primary,
        ),
        _buildStatCard(
          title: 'Tersedia',
          value: availableEmployees.toString(),
          icon: Icons.check_circle_outline,
          color: AppColors.success,
        ),
        _buildStatCard(
          title: 'Order Aktif',
          value: totalActive.toString(),
          icon: Icons.pending_actions,
          color: AppColors.warning,
        ),
        _buildStatCard(
          title: 'Order Selesai',
          value: totalCompleted.toString(),
          icon: Icons.task_alt,
          color: AppColors.info,
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
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

  Widget _buildEmployeeCard(EmployeeWithStats data) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {
          context.push(RouteNames.adminEmployeeDetailPath(data.employee.id));
        },
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.secondaryLight,
                        child: Text(
                          data.employee.name.substring(0, 1).toUpperCase(),
                          style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                        ),
                      ),
                      if (data.isAvailable)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.employee.name,
                          style: AppTextStyles.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.employee.phone ?? '-',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
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
                      color: data.isAvailable
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      data.isAvailable ? 'Tersedia' : 'Sibuk',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: data.isAvailable ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildEmployeeStat(
                    label: 'Order Aktif',
                    value: data.activeOrders.toString(),
                  ),
                  Container(width: 1, height: 20, color: AppColors.divider),
                  _buildEmployeeStat(
                    label: 'Selesai',
                    value: data.completedOrders.toString(),
                  ),
                  Container(width: 1, height: 20, color: AppColors.divider),
                  _buildEmployeeStat(
                    label: 'Rating',
                    value: '4.8',
                    icon: Icons.star,
                    iconColor: AppColors.starActive,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeStat({
    required String label,
    required String value,
    IconData? icon,
    Color? iconColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: iconColor ?? AppColors.textSecondary),
          const SizedBox(width: 4),
        ],
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}

class EmployeeWithStats {
  final UserModel employee;
  final int activeOrders;
  final int completedOrders;
  final bool isAvailable;

  EmployeeWithStats({
    required this.employee,
    required this.activeOrders,
    required this.completedOrders,
    required this.isAvailable,
  });
}