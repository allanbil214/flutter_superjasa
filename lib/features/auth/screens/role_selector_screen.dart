import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/user_model.dart';
import '../../../core/widgets/loading_indicator.dart';

class RoleSelectorScreen extends StatelessWidget {
  const RoleSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.selectRole),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return const LoadingIndicator(message: 'Memuat...');
          }
          
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Pilih peran untuk melanjutkan',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Expanded(
                  child: ListView(
                    children: [
                      _buildRoleCard(
                        context,
                        title: AppStrings.customer,
                        subtitle: 'Pesan jasa, chat admin, lacak pesanan',
                        icon: Icons.person_outline,
                        color: AppColors.primary,
                        role: UserRole.customer,
                        onTap: () => _loginAsRole(context, UserRole.customer),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildRoleCard(
                        context,
                        title: AppStrings.employee,
                        subtitle: 'Lihat tugas, update status, dokumentasi',
                        icon: Icons.engineering_outlined,
                        color: AppColors.secondary,
                        role: UserRole.employee,
                        onTap: () => _loginAsRole(context, UserRole.employee),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildRoleCard(
                        context,
                        title: AppStrings.admin,
                        subtitle: 'Kelola pesanan, verifikasi pembayaran, atur tim',
                        icon: Icons.admin_panel_settings_outlined,
                        color: AppColors.warning,
                        role: UserRole.admin,
                        onTap: () => _loginAsRole(context, UserRole.admin),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildRoleCard(
                        context,
                        title: AppStrings.superAdmin,
                        subtitle: 'Pantau semua divisi, laporan global',
                        icon: Icons.shield_outlined,
                        color: AppColors.error,
                        role: UserRole.superAdmin,
                        onTap: () => _loginAsRole(context, UserRole.superAdmin),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required UserRole role,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: AppSpacing.cardElevation,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loginAsRole(BuildContext context, UserRole role) async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.loginAsRole(role);
    
    if (context.mounted) {
      _navigateToHome(context, role);
    }
  }

  void _navigateToHome(BuildContext context, UserRole role) {
    switch (role) {
      case UserRole.customer:
        context.go('/customer/home');
        break;
      case UserRole.admin:
        context.go('/admin/dashboard');
        break;
      case UserRole.employee:
        context.go('/employee/tasks');
        break;
      case UserRole.superAdmin:
        context.go('/super-admin/dashboard');
        break;
    }
  }
}