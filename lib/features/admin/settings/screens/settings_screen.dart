import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../scaffold/admin_scaffold.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _autoAssignTechnician = true;
  bool _showPricing = true;
  String _workingHoursStart = '08:00';
  String _workingHoursEnd = '20:00';

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      appBar: AppAppBar(
        title: 'Pengaturan',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            
            // Notifikasi Section
            _buildSectionTitle('Notifikasi'),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Push Notification'),
                    subtitle: const Text('Dapatkan notifikasi order baru'),
                    value: _pushNotifications,
                    onChanged: (value) => setState(() => _pushNotifications = value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Email Notification'),
                    subtitle: const Text('Dapatkan ringkasan via email'),
                    value: _emailNotifications,
                    onChanged: (value) => setState(() => _emailNotifications = value),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Operasional Section
            _buildSectionTitle('Operasional'),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Auto-Assign Teknisi'),
                    subtitle: const Text('Otomatis tugaskan teknisi ke order baru'),
                    value: _autoAssignTechnician,
                    onChanged: (value) => setState(() => _autoAssignTechnician = value),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Jam Operasional'),
                    subtitle: Text('$_workingHoursStart - $_workingHoursEnd'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showWorkingHoursPicker,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Tampilan Section
            _buildSectionTitle('Tampilan'),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Tampilkan Harga'),
                    subtitle: const Text('Customer dapat melihat harga layanan'),
                    value: _showPricing,
                    onChanged: (value) => setState(() => _showPricing = value),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Layanan Section
            _buildSectionTitle('Layanan'),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.build_outlined),
                    title: const Text('Kelola Layanan'),
                    subtitle: const Text('Tambah, edit, atau nonaktifkan layanan'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showMockMessage,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.local_offer_outlined),
                    title: const Text('Promo & Diskon'),
                    subtitle: const Text('Atur promo untuk layanan'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showMockMessage,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Reset Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _resetToDefault,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset ke Default'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: const BorderSide(color: AppColors.warning),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.xs),
      child: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }

  void _showWorkingHoursPicker() {
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
                  'Jam Operasional',
                  style: AppTextStyles.titleMedium,
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTimePicker(
                        label: 'Mulai',
                        value: _workingHoursStart,
                        onTap: () => _selectTime(true),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text('–', style: AppTextStyles.titleMedium),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildTimePicker(
                        label: 'Selesai',
                        value: _workingHoursEnd,
                        onTap: () => _selectTime(false),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Simpan'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimePicker({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: AppTextStyles.caption),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  void _selectTime(bool isStart) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse((isStart ? _workingHoursStart : _workingHoursEnd).split(':')[0]),
        minute: int.parse((isStart ? _workingHoursStart : _workingHoursEnd).split(':')[1]),
      ),
    ).then((time) {
      if (time != null) {
        setState(() {
          final formatted = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
          if (isStart) {
            _workingHoursStart = formatted;
          } else {
            _workingHoursEnd = formatted;
          }
        });
      }
    });
  }

  void _resetToDefault() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Pengaturan'),
        content: const Text('Yakin ingin mengembalikan semua pengaturan ke default?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _pushNotifications = true;
                _emailNotifications = false;
                _autoAssignTechnician = true;
                _showPricing = true;
                _workingHoursStart = '08:00';
                _workingHoursEnd = '20:00';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengaturan direset ke default'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showMockMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur untuk prototype'),
        backgroundColor: AppColors.info,
        duration: Duration(seconds: 2),
      ),
    );
  }
}