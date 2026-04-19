import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/payment_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../core/routing/route_names.dart';
import '../../scaffold/admin_scaffold.dart';

class VerifyPaymentScreen extends StatefulWidget {
  final int orderId;

  const VerifyPaymentScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<VerifyPaymentScreen> createState() => _VerifyPaymentScreenState();
}

class _VerifyPaymentScreenState extends State<VerifyPaymentScreen> {
  OrderModel? _order;
  PaymentModel? _payment;
  UserModel? _customer;
  bool _isLoading = true;
  bool _isProcessing = false;
  final TextEditingController _noteController = TextEditingController();
  String? _error;

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
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final dataService = MockDataService();
      final orders = await dataService.getOrders();
      _order = orders.firstWhere((o) => o.id == widget.orderId);
      
      if (_order != null) {
        _payment = await dataService.getPaymentByOrder(_order!.id);
        _customer = await dataService.getUserById(_order!.customerId);
      }
    } catch (e) {
      _error = 'Gagal memuat data pembayaran';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      appBar: AppAppBar(
        title: 'Verifikasi Pembayaran',
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat data...')
          : _error != null
              ? ErrorView(message: _error!, onRetry: _loadData)
              : _buildBody(),
      bottomSheet: _payment?.status == PaymentStatus.uploaded
          ? _buildBottomBar()
          : null,
    );
  }

  Widget _buildBody() {
    if (_payment == null) {
      return const ErrorView(message: 'Data pembayaran tidak ditemukan');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          
          // Order Summary
          _buildOrderSummary(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Customer Info
          _buildCustomerInfo(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Payment Details
          _buildPaymentDetails(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Proof Image (mock)
          _buildProofImage(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Admin Note Input
          if (_payment!.status == PaymentStatus.uploaded)
            _buildAdminNoteInput(),
          
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
            Text('Ringkasan Pesanan', style: AppTextStyles.titleSmall),
            const Divider(height: AppSpacing.xl),
            _buildInfoRow('No. Pesanan', _order?.orderCode ?? '-'),
            const SizedBox(height: AppSpacing.sm),
            _buildInfoRow('Status Pesanan', _order?.displayStatus ?? '-'),
            const SizedBox(height: AppSpacing.sm),
            _buildInfoRow('Total Tagihan', _payment!.formattedAmount),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informasi Pelanggan', style: AppTextStyles.titleSmall),
            const Divider(height: AppSpacing.xl),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    _customer?.name.substring(0, 1).toUpperCase() ?? 'C',
                    style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_customer?.name ?? '-', style: AppTextStyles.titleSmall),
                      Text(
                        _customer?.phone ?? '-',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detail Pembayaran', style: AppTextStyles.titleSmall),
            const Divider(height: AppSpacing.xl),
            _buildInfoRow('Metode', _payment!.displayMethod),
            if (_payment!.paymentChannel != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildInfoRow('Channel', _payment!.paymentChannel!),
            ],
            const SizedBox(height: AppSpacing.sm),
            _buildInfoRow('Jumlah', _payment!.formattedAmount),
            const SizedBox(height: AppSpacing.sm),
            _buildInfoRow('Tanggal', _formatDate(_payment!.createdAt)),
            if (_payment!.customerNote != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildInfoRow('Catatan Customer', _payment!.customerNote!),
            ],
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getStatusColor().withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Status: ${_payment!.displayStatus}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProofImage() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bukti Transfer', style: AppTextStyles.titleSmall),
            const Divider(height: AppSpacing.xl),
            InkWell(
              onTap: _showImagePreview,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 48,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Bukti Transfer Tersedia',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Tap untuk melihat',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
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

  Widget _buildAdminNoteInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Catatan Admin (Opsional)', style: AppTextStyles.titleSmall),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Tambahkan catatan untuk verifikasi ini...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(value, style: AppTextStyles.bodyMedium),
        ),
      ],
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
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isProcessing ? null : () => _verifyPayment(false),
                icon: const Icon(Icons.close),
                label: const Text('Tolak'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : () => _verifyPayment(true),
                icon: const Icon(Icons.check),
                label: _isProcessing ? const Text('Memproses...') : const Text('Verifikasi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (_payment!.status) {
      case PaymentStatus.pending:
        return AppColors.statusPending;
      case PaymentStatus.uploaded:
        return AppColors.warning;
      case PaymentStatus.verified:
        return AppColors.success;
      case PaymentStatus.rejected:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon() {
    switch (_payment!.status) {
      case PaymentStatus.pending:
        return Icons.hourglass_empty;
      case PaymentStatus.uploaded:
        return Icons.pending_actions;
      case PaymentStatus.verified:
        return Icons.check_circle;
      case PaymentStatus.rejected:
        return Icons.cancel;
    }
  }

  void _showImagePreview() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Bukti Transfer'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Container(
              height: 400,
              width: double.infinity,
              color: AppColors.background,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 64,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Preview Bukti Transfer',
                      style: AppTextStyles.bodyMedium,
                    ),
                    Text(
                      '(Prototype - Gambar tidak tersedia)',
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

  Future<void> _verifyPayment(bool approve) async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _payment = PaymentModel(
        id: _payment!.id,
        orderId: _payment!.orderId,
        amount: _payment!.amount,
        paymentMethod: _payment!.paymentMethod,
        paymentChannel: _payment!.paymentChannel,
        status: approve ? PaymentStatus.verified : PaymentStatus.rejected,
        proofImage: _payment!.proofImage,
        customerNote: _payment!.customerNote,
        adminNote: _noteController.text.isNotEmpty ? _noteController.text : null,
        verifiedBy: 1,
        verifiedAt: DateTime.now().toIso8601String(),
        createdAt: _payment!.createdAt,
      );
      _isProcessing = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approve 
                ? 'Pembayaran berhasil diverifikasi' 
                : 'Pembayaran ditolak',
          ),
          backgroundColor: approve ? AppColors.success : AppColors.error,
        ),
      );
      
      if (approve) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.go(RouteNames.adminOrderDetailPath(_order!.id));
          }
        });
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateString;
    }
  }
}