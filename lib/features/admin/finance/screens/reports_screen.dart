import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../scaffold/admin_scaffold.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      appBar: AppAppBar(
        title: 'Laporan',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            
            // Period Selector
            _buildPeriodSelector(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Revenue Card
            _buildRevenueCard(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Chart Placeholder
            _buildChartPlaceholder(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Summary Stats
            _buildSummaryStats(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Top Services
            _buildTopServices(),
            
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildPeriodChip('Hari Ini', true),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildPeriodChip('Minggu Ini', false),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildPeriodChip('Bulan Ini', false),
        ),
      ],
    );
  }

  Widget _buildPeriodChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRevenueCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Pendapatan', style: AppTextStyles.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Rp 12.500.000',
              style: AppTextStyles.displaySmall.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  Icons.arrow_upward,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 4),
                Text(
                  '+15.3%',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'dari periode sebelumnya',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartPlaceholder() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Grafik Pendapatan', style: AppTextStyles.titleSmall),
            const SizedBox(height: AppSpacing.lg),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 48,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Grafik akan ditampilkan di sini',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '(Prototype - Data statis)',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          children: [
            _buildSummaryRow('Total Order', '156'),
            const Divider(height: AppSpacing.lg),
            _buildSummaryRow('Order Selesai', '142'),
            const Divider(height: AppSpacing.lg),
            _buildSummaryRow('Rata-rata per Order', 'Rp 88.028'),
            const Divider(height: AppSpacing.lg),
            _buildSummaryRow('Komisi Teknisi', 'Rp 3.750.000'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildTopServices() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Layanan Terpopuler', style: AppTextStyles.titleSmall),
            const Divider(height: AppSpacing.xl),
            _buildServiceRow('Cuci AC', '45 order', 'Rp 6.750.000'),
            const SizedBox(height: AppSpacing.sm),
            _buildServiceRow('Ganti LCD HP', '32 order', 'Rp 9.600.000'),
            const SizedBox(height: AppSpacing.sm),
            _buildServiceRow('Servis Laptop', '28 order', 'Rp 5.600.000'),
            const SizedBox(height: AppSpacing.sm),
            _buildServiceRow('Instalasi WiFi', '20 order', 'Rp 3.000.000'),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceRow(String name, String orders, String revenue) {
    return Row(
      children: [
        Expanded(
          child: Text(name, style: AppTextStyles.bodyMedium),
        ),
        Text(
          orders,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          revenue,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}