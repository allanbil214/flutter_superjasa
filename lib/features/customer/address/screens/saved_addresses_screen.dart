import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jasafix_app/features/customer/home/widgets/customer_scaffold.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/empty_state.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  List<AddressModel> _addresses = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  void _loadAddresses() {
    // Mock addresses
    _addresses = [
      AddressModel(
        id: 1,
        label: 'Rumah',
        recipientName: 'Putri Anggraini',
        phone: '08512345001',
        address: 'Jl. Puri Indah No. 10, Jakarta Barat',
        isPrimary: true,
      ),
      AddressModel(
        id: 2,
        label: 'Kantor',
        recipientName: 'Putri Anggraini',
        phone: '08512345001',
        address: 'Jl. Sudirman No. 123, Jakarta Pusat',
        isPrimary: false,
      ),
    ];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CustomerScaffold(
      appBar: AppAppBar(
        title: 'Alamat Tersimpan',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewAddress,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_addresses.isEmpty) {
      return EmptyState(
        icon: Icons.location_on_outlined,
        title: 'Belum ada alamat tersimpan',
        subtitle: 'Tambahkan alamat untuk memudahkan pemesanan',
        buttonText: 'Tambah Alamat',
        onButtonPressed: _addNewAddress,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      itemCount: _addresses.length,
      itemBuilder: (context, index) {
        return _buildAddressCard(_addresses[index]);
      },
    );
  }

  Widget _buildAddressCard(AddressModel address) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: address.isPrimary
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        address.label == 'Rumah' ? Icons.home : Icons.business,
                        size: 14,
                        color: address.isPrimary ? AppColors.primary : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        address.label,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: address.isPrimary ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (address.isPrimary) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Utama',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () => _editAddress(address),
                      child: const Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    if (!address.isPrimary)
                      PopupMenuItem(
                        onTap: () => _setAsPrimary(address),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle_outline, size: 18),
                            SizedBox(width: 8),
                            Text('Jadikan Utama'),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      onTap: () => _deleteAddress(address),
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
            const SizedBox(height: AppSpacing.md),
            Text(
              address.recipientName,
              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              address.phone,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              address.address,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  void _addNewAddress() {
    _showAddressForm();
  }

  void _editAddress(AddressModel address) {
    _showAddressForm(address: address);
  }

  void _setAsPrimary(AddressModel address) {
    setState(() {
      for (var addr in _addresses) {
        addr.isPrimary = addr.id == address.id;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${address.label} dijadikan alamat utama'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _deleteAddress(AddressModel address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Alamat'),
        content: Text('Yakin ingin menghapus alamat ${address.label}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _addresses.removeWhere((a) => a.id == address.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Alamat berhasil dihapus'),
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

  void _showAddressForm({AddressModel? address}) {
    final labelController = TextEditingController(text: address?.label);
    final nameController = TextEditingController(text: address?.recipientName);
    final phoneController = TextEditingController(text: address?.phone);
    final addressController = TextEditingController(text: address?.address);
    String selectedLabel = address?.label ?? 'Rumah';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardBorderRadius),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.screenHorizontal,
                right: AppSpacing.screenHorizontal,
                top: AppSpacing.lg,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address == null ? 'Tambah Alamat' : 'Edit Alamat',
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Label
                  Text('Label', style: AppTextStyles.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _buildLabelChip('Rumah', selectedLabel, () {
                        setModalState(() => selectedLabel = 'Rumah');
                      }),
                      const SizedBox(width: AppSpacing.sm),
                      _buildLabelChip('Kantor', selectedLabel, () {
                        setModalState(() => selectedLabel = 'Kantor');
                      }),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Name
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Penerima',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Phone
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Nomor Telepon',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Address
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Alamat Lengkap',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: AppSpacing.buttonHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        if (address == null) {
                          setState(() {
                            _addresses.add(AddressModel(
                              id: DateTime.now().millisecondsSinceEpoch,
                              label: selectedLabel,
                              recipientName: nameController.text,
                              phone: phoneController.text,
                              address: addressController.text,
                              isPrimary: _addresses.isEmpty,
                            ));
                          });
                        } else {
                          setState(() {
                            final index = _addresses.indexWhere((a) => a.id == address.id);
                            _addresses[index] = AddressModel(
                              id: address.id,
                              label: selectedLabel,
                              recipientName: nameController.text,
                              phone: phoneController.text,
                              address: addressController.text,
                              isPrimary: address.isPrimary,
                            );
                          });
                        }
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(address == null ? 'Alamat ditambahkan' : 'Alamat diperbarui'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      child: Text(address == null ? 'Simpan' : 'Perbarui'),
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

  Widget _buildLabelChip(String label, String selected, VoidCallback onTap) {
    final isSelected = selected == label;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              label == 'Rumah' ? Icons.home : Icons.business,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddressModel {
  final int id;
  final String label;
  final String recipientName;
  final String phone;
  final String address;
  bool isPrimary;

  AddressModel({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.address,
    required this.isPrimary,
  });
}