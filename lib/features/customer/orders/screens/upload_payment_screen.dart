import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jasafix_app/core/constants/app_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../data/models/order_model.dart';
import '../../../../core/routing/route_names.dart';

class UploadPaymentScreen extends StatefulWidget {
  final int orderId;

  const UploadPaymentScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<UploadPaymentScreen> createState() => _UploadPaymentScreenState();
}

class _UploadPaymentScreenState extends State<UploadPaymentScreen> {
  String? _selectedMethod;
  String? _selectedChannel;
  final _noteController = TextEditingController();
  OrderModel? _order;
  double _totalAmount = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;

  final List<PaymentMethodOption> _paymentMethods = [
    PaymentMethodOption(
      id: 'transfer_bank',
      name: 'Transfer Bank',
      icon: Icons.account_balance,
      channels: ['BCA', 'Mandiri', 'BNI', 'BRI'],
    ),
    PaymentMethodOption(
      id: 'e_wallet',
      name: 'E-Wallet',
      icon: Icons.account_balance_wallet,
      channels: ['GoPay', 'OVO', 'Dana', 'ShopeePay'],
    ),
    PaymentMethodOption(
      id: 'cash',
      name: 'Tunai',
      icon: Icons.money,
      channels: [],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final dataService = MockDataService();
      final orders = await dataService.getOrders();
      _order = orders.firstWhere((o) => o.id == widget.orderId);
      _totalAmount = await dataService.getOrderTotal(widget.orderId);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        title: 'Upload Bukti Pembayaran',
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat...')
          : _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          
          // Order Summary
          _buildOrderSummary(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Payment Method
          Text(
            'Metode Pembayaran',
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          ..._paymentMethods.map((method) => _buildMethodCard(method)),
          
          if (_selectedMethod != null && _selectedMethod != 'cash') ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Pilih Bank / E-Wallet',
              style: AppTextStyles.titleSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildChannelSelector(),
          ],
          
          const SizedBox(height: AppSpacing.lg),
          
          // Account Numbers (mock)
          if (_selectedChannel != null) _buildAccountInfo(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Upload Proof
          if (_selectedMethod != null && _selectedMethod != 'cash') ...[
            Text(
              'Upload Bukti Transfer',
              style: AppTextStyles.titleSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildUploadArea(),
          ],
          
          const SizedBox(height: AppSpacing.lg),
          
          // Note
          Text(
            'Catatan (Opsional)',
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _noteController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Contoh: Sudah transfer via BCA',
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Pembayaran',
              style: AppTextStyles.titleSmall,
            ),
            const Divider(height: AppSpacing.xl),
            _buildSummaryRow('No. Pesanan', _order?.orderCode ?? '-'),
            const SizedBox(height: AppSpacing.sm),
            _buildSummaryRow('Total Pembayaran', _formatCurrency(_totalAmount),
                isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.titleSmall.copyWith(color: AppColors.primary)
              : AppTextStyles.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildMethodCard(PaymentMethodOption method) {
    final isSelected = _selectedMethod == method.id;
    
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        side: isSelected
            ? BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMethod = method.id;
            _selectedChannel = method.channels.isNotEmpty ? null : null;
          });
        },
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  method.icon,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  method.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChannelSelector() {
    final method = _paymentMethods.firstWhere((m) => m.id == _selectedMethod);
    
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: method.channels.map((channel) {
        final isSelected = _selectedChannel == channel;
        return ChoiceChip(
          label: Text(channel),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedChannel = selected ? channel : null;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildAccountInfo() {
    return Card(
      color: AppColors.info.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppColors.info,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Informasi Rekening',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildAccountRow('Bank', _selectedChannel ?? '-'),
            const SizedBox(height: AppSpacing.sm),
            _buildAccountRow('No. Rekening', _getAccountNumber()),
            const SizedBox(height: AppSpacing.sm),
            _buildAccountRow('Atas Nama', AppConfig.companyName),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getAccountNumber() {
    final mockAccounts = {
      'BCA': '1234567890',
      'Mandiri': '0987654321',
      'BNI': '1122334455',
      'BRI': '5544332211',
      'GoPay': '081234567890',
      'OVO': '081234567890',
      'Dana': '081234567890',
      'ShopeePay': '081234567890',
    };
    return mockAccounts[_selectedChannel] ?? '-';
  }

  Widget _buildUploadArea() {
    return InkWell(
      onTap: _showUploadOptions,
      borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
          color: AppColors.background,
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Tap untuk upload bukti transfer',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Format: JPG, PNG, PDF (Max 5MB)',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed: _canSubmit ? _submitPayment : null,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(_selectedMethod == 'cash' 
                    ? 'Konfirmasi Pembayaran Tunai' 
                    : 'Kirim Bukti Pembayaran'),
          ),
        ),
      ),
    );
  }

  bool get _canSubmit {
    if (_selectedMethod == null) return false;
    if (_selectedMethod == 'cash') return true;
    return _selectedChannel != null;
  }

  void _showUploadOptions() {
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
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Ambil Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _mockUpload();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _mockUpload();
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('Pilih File PDF'),
                onTap: () {
                  Navigator.pop(context);
                  _mockUpload();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _mockUpload() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Fitur upload untuk prototype'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  Future<void> _submitPayment() async {
    setState(() => _isSubmitting = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() => _isSubmitting = false);
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: 48,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pembayaran Terkirim!',
                style: AppTextStyles.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Bukti pembayaran Anda sedang diverifikasi oleh admin.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go(RouteNames.customerOrders);
              },
              child: const Text('Lihat Pesanan Saya'),
            ),
          ],
        ),
      );
    }
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}

class PaymentMethodOption {
  final String id;
  final String name;
  final IconData icon;
  final List<String> channels;

  PaymentMethodOption({
    required this.id,
    required this.name,
    required this.icon,
    required this.channels,
  });
}