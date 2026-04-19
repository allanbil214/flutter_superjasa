import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../scaffold/employee_scaffold.dart';

class EmployeeSettingsScreen extends StatefulWidget {
  const EmployeeSettingsScreen({super.key});

  @override
  State<EmployeeSettingsScreen> createState() => _EmployeeSettingsScreenState();
}

class _EmployeeSettingsScreenState extends State<EmployeeSettingsScreen> {
  // Notification Settings
  bool _pushNotifications = true;
  bool _newTaskNotifications = true;
  bool _chatNotifications = true;
  
  // Work Preferences
  bool _acceptWeekendTasks = true;
  bool _acceptEmergencyTasks = false;
  double _maxDistance = 15.0; // km
  List<String> _preferredAreas = ['Jakarta Barat', 'Jakarta Pusat'];
  
  // Display Settings
  bool _showEarnings = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return EmployeeScaffold(
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
            _buildSectionTitle('Notifikasi', icon: Icons.notifications_outlined),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Push Notification'),
                    subtitle: const Text('Aktifkan notifikasi push'),
                    value: _pushNotifications,
                    onChanged: (value) => setState(() => _pushNotifications = value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Notifikasi Tugas Baru'),
                    subtitle: const Text('Dapatkan notifikasi saat ada tugas baru'),
                    value: _newTaskNotifications,
                    onChanged: _pushNotifications 
                        ? (value) => setState(() => _newTaskNotifications = value)
                        : null,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Notifikasi Chat'),
                    subtitle: const Text('Dapatkan notifikasi pesan baru'),
                    value: _chatNotifications,
                    onChanged: _pushNotifications 
                        ? (value) => setState(() => _chatNotifications = value)
                        : null,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Preferensi Kerja Section
            _buildSectionTitle('Preferensi Kerja', icon: Icons.work_outline),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Terima Tugas Akhir Pekan'),
                    subtitle: const Text('Sabtu & Minggu'),
                    value: _acceptWeekendTasks,
                    onChanged: (value) => setState(() => _acceptWeekendTasks = value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Terima Tugas Darurat'),
                    subtitle: const Text('Tugas dengan prioritas tinggi'),
                    value: _acceptEmergencyTasks,
                    onChanged: (value) => setState(() => _acceptEmergencyTasks = value),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Jarak Maksimum'),
                    subtitle: Text('${_maxDistance.toStringAsFixed(0)} km'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showDistancePicker,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Area Preferensi'),
                    subtitle: Text(_preferredAreas.join(', ')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showAreaPicker,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Tampilan Section
            _buildSectionTitle('Tampilan', icon: Icons.palette_outlined),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Tampilkan Pendapatan'),
                    subtitle: const Text('Lihat estimasi pendapatan di dashboard'),
                    value: _showEarnings,
                    onChanged: (value) => setState(() => _showEarnings = value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Mode Gelap'),
                    subtitle: const Text('Gunakan tema gelap'),
                    value: _darkMode,
                    onChanged: (value) {
                      setState(() => _darkMode = value);
                      _showMockMessage('Mode Gelap');
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Info Section
            _buildSectionTitle('Informasi', icon: Icons.info_outline),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.verified_outlined, color: AppColors.success),
                    title: const Text('Status Akun'),
                    subtitle: const Text('Terverifikasi'),
                    trailing: const Icon(Icons.check_circle, color: AppColors.success),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.star_outline, color: AppColors.starActive),
                    title: const Text('Rating Anda'),
                    subtitle: const Text('4.8 ⭐ (24 ulasan)'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.assignment_turned_in_outlined),
                    title: const Text('Total Tugas Selesai'),
                    subtitle: const Text('42 tugas'),
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

  Widget _buildSectionTitle(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.xs),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.secondary),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            title,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showDistancePicker() {
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
                  'Jarak Maksimum',
                  style: AppTextStyles.titleMedium,
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Text(
                      '${_maxDistance.toStringAsFixed(0)} km',
                      style: AppTextStyles.displaySmall.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Slider(
                      value: _maxDistance,
                      min: 5,
                      max: 50,
                      divisions: 9,
                      label: '${_maxDistance.toStringAsFixed(0)} km',
                      activeColor: AppColors.secondary,
                      onChanged: (value) {
                        setState(() => _maxDistance = value);
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('5 km', style: AppTextStyles.caption),
                        Text('50 km', style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                  ),
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

  void _showAreaPicker() {
    final allAreas = [
      'Jakarta Barat',
      'Jakarta Pusat',
      'Jakarta Selatan',
      'Jakarta Timur',
      'Jakarta Utara',
      'Bekasi',
      'Depok',
      'Tangerang',
      'Bogor',
    ];
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardBorderRadius),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Area Preferensi',
                          style: AppTextStyles.titleMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {});
                            setState(() {
                              _preferredAreas = [];
                            });
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: allAreas.length,
                      itemBuilder: (context, index) {
                        final area = allAreas[index];
                        final isSelected = _preferredAreas.contains(area);
                        return CheckboxListTile(
                          title: Text(area),
                          value: isSelected,
                          activeColor: AppColors.secondary,
                          onChanged: (value) {
                            setModalState(() {
                              if (value == true) {
                                _preferredAreas.add(area);
                              } else {
                                _preferredAreas.remove(area);
                              }
                            });
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                        ),
                        child: Text('Simpan (${_preferredAreas.length} area)'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
                _newTaskNotifications = true;
                _chatNotifications = true;
                _acceptWeekendTasks = true;
                _acceptEmergencyTasks = false;
                _maxDistance = 15.0;
                _preferredAreas = ['Jakarta Barat', 'Jakarta Pusat'];
                _showEarnings = true;
                _darkMode = false;
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

  void _showMockMessage(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Fitur untuk prototype'),
        backgroundColor: AppColors.info,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}