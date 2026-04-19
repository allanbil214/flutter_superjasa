import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../providers/app_state.dart';
import '../../../../data/models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final UserRole? role;

  const EditProfileScreen({
    super.key,
    this.role,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  bool _isLoading = false;
  bool _hasChanges = false;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setupListeners();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final appState = Provider.of<AppState>(context, listen: false);
    _currentUser = appState.currentUser;
    
    if (_currentUser != null) {
      _nameController.text = _currentUser!.name;
      _phoneController.text = _currentUser!.phone ?? '';
      _addressController.text = _currentUser!.address ?? '';
    }
  }

  void _setupListeners() {
    _nameController.addListener(_checkChanges);
    _phoneController.addListener(_checkChanges);
    _addressController.addListener(_checkChanges);
  }

  void _checkChanges() {
    final hasChanged = _nameController.text != _currentUser?.name ||
        _phoneController.text != (_currentUser?.phone ?? '') ||
        _addressController.text != (_currentUser?.address ?? '');
    
    if (_hasChanges != hasChanged) {
      setState(() => _hasChanges = hasChanged);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        title: 'Edit Profil',
        actions: [
          TextButton(
            onPressed: _hasChanges && !_isLoading ? _saveProfile : null,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Simpan',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: _hasChanges ? AppColors.primary : AppColors.textTertiary,
                    ),
                  ),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Menyimpan...')
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xl),
            
            // Avatar Section
            _buildAvatarSection(),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Name Field
            _buildNameField(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Phone Field
            _buildPhoneField(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Address Field (for roles that have address)
            if (_shouldShowAddress()) _buildAddressField(),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Email (read-only)
            _buildEmailField(),
            
            const SizedBox(height: AppSpacing.md),
            Text(
              'Email tidak dapat diubah',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getRoleColor(),
                    _getRoleColor().withOpacity(0.7),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
                  style: AppTextStyles.displaySmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: _changeAvatar,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: _changeAvatar,
          child: Text(
            'Ganti Foto Profil',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nama Lengkap',
          style: AppTextStyles.titleSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Masukkan nama lengkap',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonBorderRadius),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nama tidak boleh kosong';
            }
            if (value.trim().length < 3) {
              return 'Nama minimal 3 karakter';
            }
            return null;
          },
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nomor Telepon',
          style: AppTextStyles.titleSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            hintText: 'Contoh: 081234567890',
            prefixIcon: const Icon(Icons.phone_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonBorderRadius),
            ),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (value.length < 10) {
                return 'Nomor telepon minimal 10 digit';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alamat',
          style: AppTextStyles.titleSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _addressController,
          decoration: InputDecoration(
            hintText: 'Masukkan alamat lengkap',
            prefixIcon: const Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonBorderRadius),
            ),
          ),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: AppTextStyles.titleSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          initialValue: _currentUser?.email ?? '',
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonBorderRadius),
            ),
            filled: true,
            fillColor: AppColors.background,
          ),
          enabled: false,
        ),
      ],
    );
  }

  bool _shouldShowAddress() {
    final role = widget.role ?? _currentUser?.role;
    return role == UserRole.customer || role == UserRole.employee;
  }

  Color _getRoleColor() {
    final role = widget.role ?? _currentUser?.role;
    switch (role) {
      case UserRole.customer:
        return AppColors.primary;
      case UserRole.employee:
        return AppColors.secondary;
      case UserRole.admin:
        return AppColors.warning;
      case UserRole.superAdmin:
        return const Color(0xFF4A148C);
      default:
        return AppColors.primary;
    }
  }

  void _changeAvatar() {
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
                  'Ganti Foto Profil',
                  style: AppTextStyles.titleMedium,
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Ambil Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _showMockMessage('Kamera');
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _showMockMessage('Galeri');
                },
              ),
              if (_currentUser?.avatar != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.error),
                  title: const Text('Hapus Foto', style: TextStyle(color: AppColors.error)),
                  onTap: () {
                    Navigator.pop(context);
                    _showMockMessage('Hapus Foto');
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Update user in AppState
    final appState = Provider.of<AppState>(context, listen: false);
    appState.updateCurrentUser(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
    );

    setState(() {
      _isLoading = false;
      _hasChanges = false;
      _currentUser = appState.currentUser;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil disimpan!'),
          backgroundColor: AppColors.success,
        ),
      );
      
      context.pop();
    }
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