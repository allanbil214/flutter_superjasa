import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../scaffold/super_admin_scaffold.dart';

class SuperAdminReportsScreen extends StatefulWidget {
  const SuperAdminReportsScreen({super.key});

  @override
  State<SuperAdminReportsScreen> createState() => _SuperAdminReportsScreenState();
}

class _SuperAdminReportsScreenState extends State<SuperAdminReportsScreen> {
  String _selectedPeriod = 'today'; // 'today', 'week', 'month'
  
  // Mock data for different periods
  Map<String, ReportData> _reportData = {
    'today': ReportData(
      revenue: 1250000,
      orders: 8,
      completed: 6,
      growth: 5.2,
    ),
    'week': ReportData(
      revenue: 8750000,
      orders: 42,
      completed: 38,
      growth: 12.8,
    ),
    'month': ReportData(
      revenue: 45750000,
      orders: 156,
      completed: 142,
      growth: 18.5,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final currentData = _reportData[_selectedPeriod]!;
    
    return SuperAdminScaffold(
      appBar: AppAppBar(
        title: 'Laporan Global',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _showExportOptions,
          ),
        ],
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
            
            // Revenue Overview
            _buildRevenueOverview(currentData),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Chart Placeholder
            _buildChartPlaceholder(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Division Revenue
            _buildDivisionRevenue(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Summary Stats
            _buildSummaryStats(currentData),
            
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
          child: _buildPeriodChip(
            'Hari Ini',
            _selectedPeriod == 'today',
            onTap: () => setState(() => _selectedPeriod = 'today'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildPeriodChip(
            'Minggu Ini',
            _selectedPeriod == 'week',
            onTap: () => setState(() => _selectedPeriod = 'week'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildPeriodChip(
            'Bulan Ini',
            _selectedPeriod == 'month',
            onTap: () => setState(() => _selectedPeriod = 'month'),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodChip(String label, bool isSelected, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A148C) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4A148C) : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildRevenueOverview(ReportData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Pendapatan', style: AppTextStyles.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _formatCurrency(data.revenue),
              style: AppTextStyles.displaySmall.copyWith(
                color: const Color(0xFF4A148C),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  data.growth >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: data.growth >= 0 ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  '${data.growth >= 0 ? '+' : ''}${data.growth}%',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: data.growth >= 0 ? AppColors.success : AppColors.error,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Grafik Pendapatan', style: AppTextStyles.titleSmall),
                IconButton(
                  icon: const Icon(Icons.bar_chart, size: 20),
                  onPressed: _showChartOptions,
                ),
              ],
            ),
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

  Widget _buildDivisionRevenue() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pendapatan per Divisi', style: AppTextStyles.titleSmall),
            const Divider(height: AppSpacing.xl),
            _buildDivisionRow('Servis AC', 12500000, 0.27),
            const SizedBox(height: AppSpacing.sm),
            _buildDivisionRow('Servis HP', 9600000, 0.21),
            const SizedBox(height: AppSpacing.sm),
            _buildDivisionRow('Servis Elektronik', 5800000, 0.13),
            const SizedBox(height: AppSpacing.sm),
            _buildDivisionRow('Servis Komputer', 8200000, 0.18),
            const SizedBox(height: AppSpacing.sm),
            _buildDivisionRow('Servis Mesin Cuci', 3500000, 0.08),
            const SizedBox(height: AppSpacing.sm),
            _buildDivisionRow('Instalasi WiFi', 4150000, 0.09),
            const SizedBox(height: AppSpacing.sm),
            _buildDivisionRow('Servis Printer', 2000000, 0.04),
          ],
        ),
      ),
    );
  }

  Widget _buildDivisionRow(String name, int revenue, double percentage) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Text(name, style: AppTextStyles.bodyMedium),
            ),
            Expanded(
              child: Text(
                _formatCurrency(revenue),
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.end,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '${(percentage * 100).toInt()}%',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: AppColors.divider,
            color: const Color(0xFF4A148C),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStats(ReportData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          children: [
            _buildSummaryRow('Total Order', data.orders.toString()),
            const Divider(height: AppSpacing.lg),
            _buildSummaryRow('Order Selesai', data.completed.toString()),
            const Divider(height: AppSpacing.lg),
            _buildSummaryRow(
              'Rata-rata per Order',
              _formatCurrency((data.revenue / (data.orders == 0 ? 1 : data.orders)).toInt()),
            ),
            const Divider(height: AppSpacing.lg),
            _buildSummaryRow('Total Komisi Teknisi', _formatCurrency((data.revenue * 0.3).toInt())),
            const Divider(height: AppSpacing.lg),
            _buildSummaryRow('Laba Bersih (Estimasi)', _formatCurrency((data.revenue * 0.7).toInt())),
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

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardBorderRadius),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Export Laporan',
                  style: AppTextStyles.titleMedium,
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('Export sebagai PDF'),
                onTap: () {
                  Navigator.pop(context);
                  _showMockMessage('Export PDF');
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('Export sebagai Excel'),
                onTap: () {
                  Navigator.pop(context);
                  _showMockMessage('Export Excel');
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Export sebagai Gambar'),
                onTap: () {
                  Navigator.pop(context);
                  _showMockMessage('Export Gambar');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showChartOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardBorderRadius),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Tipe Grafik',
                  style: AppTextStyles.titleMedium,
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Bar Chart'),
                onTap: () {
                  Navigator.pop(context);
                  _showMockMessage('Bar Chart');
                },
              ),
              ListTile(
                leading: const Icon(Icons.show_chart),
                title: const Text('Line Chart'),
                onTap: () {
                  Navigator.pop(context);
                  _showMockMessage('Line Chart');
                },
              ),
              ListTile(
                leading: const Icon(Icons.pie_chart),
                title: const Text('Pie Chart'),
                onTap: () {
                  Navigator.pop(context);
                  _showMockMessage('Pie Chart');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMockMessage(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Fitur untuk prototype'),
        backgroundColor: AppColors.info,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}

class ReportData {
  final int revenue;
  final int orders;
  final int completed;
  final double growth;

  ReportData({
    required this.revenue,
    required this.orders,
    required this.completed,
    required this.growth,
  });
}