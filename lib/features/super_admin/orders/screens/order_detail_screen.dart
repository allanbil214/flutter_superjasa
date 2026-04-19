import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/status_stepper.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/service_model.dart';
import '../../../../data/models/payment_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/division_model.dart';
import '../../scaffold/super_admin_scaffold.dart';

class SuperAdminOrderDetailScreen extends StatefulWidget {
  final int orderId;

  const SuperAdminOrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<SuperAdminOrderDetailScreen> createState() => _SuperAdminOrderDetailScreenState();
}

class _SuperAdminOrderDetailScreenState extends State<SuperAdminOrderDetailScreen> {
  OrderModel? _order;
  ServiceModel? _service;
  PaymentModel? _payment;
  UserModel? _customer;
  UserModel? _technician;
  DivisionModel? _division;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
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
        _service = await dataService.getServiceById(_order!.serviceId);
        _payment = await dataService.getPaymentByOrder(_order!.id);
        _customer = await dataService.getUserById(_order!.customerId);
        _division = await dataService.getDivisionById(_order!.divisionId);
        
        if (_order!.assignedTo != null) {
          _technician = await dataService.getUserById(_order!.assignedTo!);
        }
      }
    } catch (e) {
      _error = 'Gagal memuat detail pesanan';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SuperAdminScaffold(
      appBar: AppAppBar(
        title: _order?.orderCode ?? 'Detail Pesanan',
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat detail...')
          : _error != null
              ? ErrorView(message: _error!, onRetry: _loadData)
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_order == null) {
      return const ErrorView(message: 'Pesanan tidak ditemukan');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          
          // Status Stepper
          StatusStepper(currentStatus: _order!.status),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Order Info
          _buildInfoCard(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Division Info
          _buildDivisionCard(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Customer Info
          _buildCustomerCard(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Service Details
          _buildServiceCard(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Payment Status
          _buildPaymentCard(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Technician Info
          if (_technician != null) _buildTechnicianCard(),
          
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informasi Pesanan', style: AppTextStyles.titleSmall),
            const Divider(height: AppSpacing.xl),
            _buildInfoRow('No. Pesanan', _order!.orderCode),
            const SizedBox(height: AppSpacing.sm),
            _buildInfoRow('Status', _order!.displayStatus),
            const SizedBox(height: AppSpacing.sm),
            _buildInfoRow('Tanggal Pesan', _formatDate(_order!.createdAt)),
            if (_order!.scheduledAt != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildInfoRow('Jadwal', _formatDate(_order!.scheduledAt!)),
            ],
            if (_order!.notes != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildInfoRow('Catatan', _order!.notes!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDivisionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Divisi', style: AppTextStyles.titleSmall),
            const Divider(height: AppSpacing.xl),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.business, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  _division?.name ?? 'Divisi #${_order!.divisionId}',
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pelanggan', style: AppTextStyles.titleSmall),
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
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildInfoRow('Alamat', _order!.address),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Layanan', style: AppTextStyles.titleSmall),
            const Divider(height: AppSpacing.xl),
            Text(
              _service?.name ?? 'Layanan #${_order!.serviceId}',
              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.md),
            FutureBuilder<double>(
              future: MockDataService().getOrderTotal(_order!.id),
              builder: (context, snapshot) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: AppTextStyles.bodyMedium),
                    Text(
                      _formatCurrency(snapshot.data ?? 0),
                      style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
                    ),
                  ],
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pembayaran', style: AppTextStyles.titleSmall),
            const Divider(height: AppSpacing.xl),
            if (_payment == null)
              Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: AppColors.warning),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Menunggu pembayaran', style: AppTextStyles.bodyMedium),
                ],
              )
            else
              Column(
                children: [
                  _buildInfoRow('Metode', _payment!.displayMethod),
                  if (_payment!.paymentChannel != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _buildInfoRow('Channel', _payment!.paymentChannel!),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  _buildInfoRow('Status', _payment!.displayStatus),
                  const SizedBox(height: AppSpacing.sm),
                  _buildInfoRow('Jumlah', _payment!.formattedAmount),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicianCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Teknisi', style: AppTextStyles.titleSmall),
            const Divider(height: AppSpacing.xl),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.secondaryLight,
                  child: Text(
                    _technician!.name.substring(0, 1).toUpperCase(),
                    style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_technician!.name, style: AppTextStyles.titleSmall),
                      Text(
                        _technician!.phone ?? '-',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateString;
    }
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}