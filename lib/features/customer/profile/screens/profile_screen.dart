import 'package:flutter/material.dart';
import 'package:jasafix_app/data/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../providers/app_state.dart';
import '../../../../core/routing/route_names.dart';
import '../../home/widgets/customer_scaffold.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    
    return CustomerScaffold(
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
            
            // Profile Info
            _buildProfileInfo(user),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Menu Items
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Edit Profil',
              onTap: () {
                // TODO: Navigate to edit profile
              },
            ),
            _buildMenuItem(
              icon: Icons.location_on_outlined,
              title: 'Alamat Tersimpan',
              onTap: () {
                // TODO: Navigate to addresses
              },
            ),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Pusat Bantuan',
              onTap: () {
                // TODO: Navigate to help
              },
            ),
            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'Tentang Aplikasi',
              onTap: _showAboutDialog,
            ),
            
            const Divider(height: AppSpacing.xl),
            
            // Switch Role (Demo)
            _buildMenuItem(
              icon: Icons.switch_account,
              title: 'Ganti Peran (Demo)',
              onTap: _showRoleSwitchDialog,
              color: AppColors.secondary,
            ),
            
            _buildMenuItem(
              icon: Icons.logout,
              title: AppStrings.logout,
              onTap: _logout,
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

  Widget _buildProfileHeader(user) {
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
                AppColors.primary,
                AppColors.primaryLight,
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              user?.name.substring(0, 1).toUpperCase() ?? 'U',
              style: AppTextStyles.displaySmall.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          user?.name ?? 'User',
          style: AppTextStyles.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            user?.displayRole ?? 'Customer',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(user) {
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
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
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
      leading: Icon(
        icon,
        color: color ?? AppColors.primary,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: color,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  void _showAboutDialog() {
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
      children: [
        const SizedBox(height: AppSpacing.md),
        Text(
          '© ${DateTime.now().year} ${AppConfig.companyName}',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Semua hak cipta dilindungi.',
          textAlign: TextAlign.center,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  void _showRoleSwitchDialog() {
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
                Provider.of<AppState>(context, listen: false).switchRole(UserRole.customer);
                context.go(RouteNames.customerHome);
              },
            ),
            ListTile(
              leading: const Icon(Icons.engineering_outlined),
              title: const Text('Employee'),
              onTap: () {
                Navigator.pop(context);
                Provider.of<AppState>(context, listen: false).switchRole(UserRole.employee);
                context.go(RouteNames.employeeTasks);
              },
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: const Text('Admin'),
              onTap: () {
                Navigator.pop(context);
                Provider.of<AppState>(context, listen: false).switchRole(UserRole.admin);
                context.go(RouteNames.adminDashboard);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: const Text('Super Admin'),
              onTap: () {
                Navigator.pop(context);
                Provider.of<AppState>(context, listen: false).switchRole(UserRole.superAdmin);
                context.go(RouteNames.superAdminDashboard);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    Provider.of<AppState>(context, listen: false).logout();
    context.go(RouteNames.login);
  }
}