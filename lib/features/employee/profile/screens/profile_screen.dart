import 'package:flutter/material.dart';
import 'package:jasafix_app/data/services/mock_data_service.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../providers/app_state.dart';
import '../../../../data/models/user_model.dart';
import '../../../../core/routing/route_names.dart';
import '../../scaffold/employee_scaffold.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  int _completedOrders = 0;
  double _averageRating = 0.0;
  int _totalReviews = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final dataService = MockDataService();
    final currentUser = appState.currentUser;
    
    if (currentUser == null) return;
    
    final orders = await dataService.getOrdersByEmployee(currentUser.id);
    final reviews = await dataService.getReviewsByEmployee(currentUser.id);
    
    setState(() {
      _completedOrders = orders.where((o) => o.isCompleted).length;
      _totalReviews = reviews.length;
      _averageRating = reviews.isEmpty ? 0.0 
          : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    
    return EmployeeScaffold(
      appBar: AppAppBar(
        title: AppStrings.navProfile,
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xl),
            
            // Profile Header
            _buildProfileHeader(user),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Stats Cards
            _buildStatsCards(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Profile Info
            _buildProfileInfo(user),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Menu Items
            _buildMenuItem(
              icon: Icons.settings_outlined,
              title: 'Pengaturan',
              onTap: () {
                context.push(RouteNames.employeeSettings);
              },
            ),
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Edit Profil',
              onTap: () {
                context.push('/edit-profile');
              },
            ),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Pusat Bantuan',
              onTap: () {
                context.push(RouteNames.helpCenter);
              },
            ),
            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'Tentang Aplikasi',
              onTap: () => _showAboutDialog(context),
            ),
            
            const Divider(height: AppSpacing.xl),
            
            // Switch Role (Demo)
            _buildMenuItem(
              icon: Icons.switch_account,
              title: 'Ganti Peran (Demo)',
              onTap: () => _showRoleSwitchDialog(context),
              color: AppColors.secondary,
            ),
            
            _buildMenuItem(
              icon: Icons.logout,
              title: AppStrings.logout,
              onTap: () => _logout(context),
              color: AppColors.error,
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Version
            Text(
              'Versi ${AppConfig.appVersion}',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel? user) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.secondary,
                AppColors.secondaryDark,
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              user?.name.substring(0, 1).toUpperCase() ?? 'E',
              style: AppTextStyles.displaySmall.copyWith(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          user?.name ?? 'Teknisi',
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
            user?.displayRole ?? 'Teknisi',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Order Selesai',
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
              subtitle: '$_totalReviews ulasan',
            ),
          ),
        ],
      ),
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
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(fontSize: 10),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(UserModel? user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          children: [
            _buildInfoRow(Icons.email_outlined, 'Email', user?.email ?? '-'),
            const Divider(height: AppSpacing.lg),
            _buildInfoRow(Icons.phone_outlined, 'Telepon', user?.phone ?? '-'),
            if (user?.address != null) ...[
              const Divider(height: AppSpacing.lg),
              _buildInfoRow(Icons.location_on_outlined, 'Alamat', user!.address!),
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(color: color),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConfig.appName,
      applicationVersion: AppConfig.appVersion,
      applicationIcon: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.build, color: AppColors.primary),
      ),
    );
  }

  void _showRoleSwitchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Peran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Customer'),
              onTap: () {
                Navigator.pop(context);
                Provider.of<AppState>(context, listen: false)
                    .switchRole(UserRole.customer);
                context.go(RouteNames.customerHome);
              },
            ),
            ListTile(
              leading: const Icon(Icons.engineering_outlined),
              title: const Text('Employee'),
              onTap: () {
                Navigator.pop(context);
                // Already employee
              },
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: const Text('Admin'),
              onTap: () {
                Navigator.pop(context);
                Provider.of<AppState>(context, listen: false)
                    .switchRole(UserRole.admin);
                context.go(RouteNames.adminDashboard);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: const Text('Super Admin'),
              onTap: () {
                Navigator.pop(context);
                Provider.of<AppState>(context, listen: false)
                    .switchRole(UserRole.superAdmin);
                context.go(RouteNames.superAdminDashboard);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    Provider.of<AppState>(context, listen: false).logout();
    context.go(RouteNames.login);
  }
}