import 'package:flutter/material.dart';
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
import '../../scaffold/super_admin_scaffold.dart';

class SuperAdminProfileScreen extends StatelessWidget {
  const SuperAdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    
    return SuperAdminScaffold(
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
              icon: Icons.settings_outlined,
              title: 'Pengaturan Aplikasi',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.people_outline,
              title: 'Manajemen User',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Pusat Bantuan',
              onTap: () {},
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
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4A148C),
                Color(0xFF7B1FA2),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              user?.name.substring(0, 1).toUpperCase() ?? 'SA',
              style: AppTextStyles.displaySmall.copyWith(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          user?.name ?? 'Super Admin',
          style: AppTextStyles.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF4A148C).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            user?.displayRole ?? 'Super Admin',
            style: AppTextStyles.labelMedium.copyWith(
              color: const Color(0xFF4A148C),
            ),
          ),
        ),
      ],
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
      leading: Icon(icon, color: color ?? const Color(0xFF4A148C)),
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
          color: const Color(0xFF4A148C).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.build, color: Color(0xFF4A148C)),
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
                Provider.of<AppState>(context, listen: false)
                    .switchRole(UserRole.employee);
                context.go(RouteNames.employeeTasks);
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
                // Already super admin
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