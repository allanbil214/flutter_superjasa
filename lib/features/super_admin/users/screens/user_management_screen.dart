import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../providers/app_state.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../data/models/user_model.dart';
import '../../../../core/routing/route_names.dart';
import '../../scaffold/super_admin_scaffold.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  UserRole? _roleFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final dataService = MockDataService();
      _users = await dataService.getUsers();
      _users.sort((a, b) => a.name.compareTo(b.name));
      _applyFilters();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    var filtered = _users;
    
    if (_roleFilter != null) {
      filtered = filtered.where((u) => u.role == _roleFilter).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((u) =>
        u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        u.email.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    _filteredUsers = filtered;
  }

  @override
  Widget build(BuildContext context) {
    return SuperAdminScaffold(
      appBar: AppAppBar(
        title: 'Manajemen User',
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: _addUser,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat data user...')
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari user...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _applyFilters();
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _applyFilters();
              });
            },
          ),
        ),
        
        // Role Filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
          child: Row(
            children: [
              _buildFilterChip('Semua', null),
              const SizedBox(width: AppSpacing.sm),
              _buildFilterChip('Super Admin', UserRole.superAdmin),
              const SizedBox(width: AppSpacing.sm),
              _buildFilterChip('Admin', UserRole.admin),
              const SizedBox(width: AppSpacing.sm),
              _buildFilterChip('Teknisi', UserRole.employee),
              const SizedBox(width: AppSpacing.sm),
              _buildFilterChip('Customer', UserRole.customer),
            ],
          ),
        ),
        
        const SizedBox(height: AppSpacing.sm),
        const Divider(height: 1),
        
        // User Stats
        Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('Total', _users.length),
              _buildStat('Aktif', _users.where((u) => u.isActive).length, color: AppColors.success),
              _buildStat('Nonaktif', _users.where((u) => !u.isActive).length, color: AppColors.error),
            ],
          ),
        ),
        
        const Divider(height: 1),
        
        // User List
        Expanded(
          child: _filteredUsers.isEmpty
              ? EmptyState(
                  icon: Icons.people_outline,
                  title: 'Tidak ada user',
                  subtitle: _roleFilter != null || _searchQuery.isNotEmpty
                      ? 'Coba ubah filter'
                      : 'Tambah user baru dengan tombol +',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, index) {
                    return _buildUserCard(_filteredUsers[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, UserRole? role) {
    final isSelected = _roleFilter == role;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _roleFilter = role;
          _applyFilters();
        });
      },
      backgroundColor: AppColors.surface,
      selectedColor: const Color(0xFF4A148C).withOpacity(0.1),
      checkmarkColor: const Color(0xFF4A148C),
    );
  }

  Widget _buildStat(String label, int value, {Color? color}) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: AppTextStyles.titleLarge.copyWith(color: color),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {
          context.push(RouteNames.superAdminUserDetailPath(user.id));
        },
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: _getRoleColor(user.role),
                    child: Text(
                      user.name.substring(0, 1).toUpperCase(),
                      style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: user.isActive ? AppColors.success : AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getRoleColor(user.role).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.displayRole,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _getRoleColor(user.role),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: () => _toggleUserStatus(user),
                    child: Row(
                      children: [
                        Icon(
                          user.isActive ? Icons.block : Icons.check_circle,
                          size: 18,
                          color: user.isActive ? AppColors.error : AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        Text(user.isActive ? 'Nonaktifkan' : 'Aktifkan'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () => _editUser(user),
                    child: const Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () => _deleteUser(user),
                    child: const Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.customer: return AppColors.primary;
      case UserRole.employee: return AppColors.secondary;
      case UserRole.admin: return AppColors.warning;
      case UserRole.superAdmin: return const Color(0xFF4A148C);
    }
  }

  void _toggleUserStatus(UserModel user) {
    setState(() {
      final index = _users.indexWhere((u) => u.id == user.id);
      _users[index] = UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        avatar: user.avatar,
        address: user.address,
        isActive: !user.isActive,
        createdAt: user.createdAt,
      );
      _applyFilters();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(user.isActive ? 'User dinonaktifkan' : 'User diaktifkan'),
        backgroundColor: user.isActive ? AppColors.error : AppColors.success,
      ),
    );
  }

  void _addUser() {
    _showMockMessage('Tambah User');
  }

  void _editUser(UserModel user) {
    _showMockMessage('Edit User');
  }

  void _deleteUser(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus User'),
        content: Text('Yakin ingin menghapus user ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _users.removeWhere((u) => u.id == user.id);
                _applyFilters();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User berhasil dihapus'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
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