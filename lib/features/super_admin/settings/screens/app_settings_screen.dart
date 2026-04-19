import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../scaffold/super_admin_scaffold.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  // General Settings
  bool _maintenanceMode = false;
  bool _allowRegistration = true;
  String _appName = AppConfig.appName;
  
  // Payment Settings
  double _taxPercent = 0.0;
  double _serviceFee = 0.0;
  bool _enableCashPayment = true;
  bool _enableTransferPayment = true;
  bool _enableEWalletPayment = true;
  
  // Feature Flags
  bool _enableChat = true;
  bool _enablePushNotifications = true;
  bool _enableReviews = true;
  bool _enableDocumentation = true;

  @override
  Widget build(BuildContext context) {
    return SuperAdminScaffold(
      appBar: AppAppBar(
        title: 'Pengaturan Aplikasi',
        actions: [
          TextButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Simpan'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            
            // General Settings
            _buildSectionTitle('Umum', icon: Icons.settings_outlined),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Nama Aplikasi'),
                    subtitle: Text(_appName),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: _editAppName,
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Maintenance Mode'),
                    subtitle: const Text('Nonaktifkan akses aplikasi untuk user'),
                    value: _maintenanceMode,
                    onChanged: (value) => setState(() => _maintenanceMode = value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Izinkan Registrasi'),
                    subtitle: const Text('User baru dapat mendaftar'),
                    value: _allowRegistration,
                    onChanged: (value) => setState(() => _allowRegistration = value),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Payment Settings
            _buildSectionTitle('Pembayaran', icon: Icons.payments_outlined),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Pajak (%)'),
                    subtitle: Text('$_taxPercent%'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: _editTax,
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Biaya Layanan'),
                    subtitle: Text('Rp ${_serviceFee.toStringAsFixed(0)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: _editServiceFee,
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Pembayaran Tunai'),
                    value: _enableCashPayment,
                    onChanged: (value) => setState(() => _enableCashPayment = value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Transfer Bank'),
                    value: _enableTransferPayment,
                    onChanged: (value) => setState(() => _enableTransferPayment = value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('E-Wallet'),
                    value: _enableEWalletPayment,
                    onChanged: (value) => setState(() => _enableEWalletPayment = value),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Feature Flags
            _buildSectionTitle('Fitur', icon: Icons.toggle_on_outlined),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Fitur Chat'),
                    subtitle: const Text('Customer dapat chat dengan admin/teknisi'),
                    value: _enableChat,
                    onChanged: (value) => setState(() => _enableChat = value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Push Notification'),
                    subtitle: const Text('Kirim notifikasi ke semua user'),
                    value: _enablePushNotifications,
                    onChanged: (value) => setState(() => _enablePushNotifications = value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Ulasan & Rating'),
                    subtitle: const Text('Customer dapat memberi ulasan'),
                    value: _enableReviews,
                    onChanged: (value) => setState(() => _enableReviews = value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Dokumentasi Teknisi'),
                    subtitle: const Text('Teknisi dapat upload dokumentasi'),
                    value: _enableDocumentation,
                    onChanged: (value) => setState(() => _enableDocumentation = value),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Danger Zone
            _buildSectionTitle('Danger Zone', icon: Icons.warning_outlined, color: AppColors.error),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.refresh, color: AppColors.warning),
                    title: const Text('Reset Semua Pengaturan'),
                    subtitle: const Text('Kembalikan ke pengaturan default'),
                    onTap: _resetAllSettings,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: AppColors.error),
                    title: const Text('Hapus Semua Data'),
                    subtitle: const Text('Hapus semua order, chat, dan data user'),
                    onTap: _clearAllData,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {IconData? icon, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.xs),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: color ?? AppColors.primary),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            title,
            style: AppTextStyles.titleSmall.copyWith(
              color: color ?? AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _editAppName() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: _appName);
        return AlertDialog(
          title: const Text('Nama Aplikasi'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Masukkan nama aplikasi',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _appName = controller.text);
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _editTax() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: _taxPercent.toString());
        return AlertDialog(
          title: const Text('Persentase Pajak'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Masukkan persentase pajak',
              suffixText: '%',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _taxPercent = double.tryParse(controller.text) ?? 0);
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _editServiceFee() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: _serviceFee.toString());
        return AlertDialog(
          title: const Text('Biaya Layanan'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Masukkan biaya layanan',
              prefixText: 'Rp ',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _serviceFee = double.tryParse(controller.text) ?? 0);
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _resetAllSettings() {
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
                _maintenanceMode = false;
                _allowRegistration = true;
                _appName = 'JasaFix';
                _taxPercent = 0.0;
                _serviceFee = 0.0;
                _enableCashPayment = true;
                _enableTransferPayment = true;
                _enableEWalletPayment = true;
                _enableChat = true;
                _enablePushNotifications = true;
                _enableReviews = true;
                _enableDocumentation = true;
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

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Data'),
        content: const Text('Tindakan ini tidak dapat dibatalkan. Yakin ingin menghapus semua data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur untuk prototype - Data tidak benar-benar dihapus'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaturan berhasil disimpan!'),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }
}