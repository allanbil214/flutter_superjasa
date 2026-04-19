import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/status_stepper.dart';
import '../../../../providers/app_state.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/service_model.dart';
import '../../../../data/models/payment_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../core/routing/route_names.dart';
import '../../scaffold/admin_scaffold.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final int orderId;

  const AdminOrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  OrderModel? _order;
  ServiceModel? _service;
  PaymentModel? _payment;
  UserModel? _customer;
  UserModel? _technician;
  List<UserModel> _availableTechnicians = [];
  bool _isLoading = true;
  bool _isProcessing = false;
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
        
        if (_order!.assignedTo != null) {
          _technician = await dataService.getUserById(_order!.assignedTo!);
        }
        
        // Get available technicians for this division
        _availableTechnicians = await dataService.getEmployeesByDivision(_order!.divisionId);
      }
    } catch (e) {
      _error = 'Gagal memuat detail pesanan';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      appBar: AppAppBar(
        title: _order?.orderCode ?? 'Detail Pesanan',
        actions: [
          if (_order?.status == OrderStatus.pending)
            TextButton.icon(
              onPressed: _isProcessing ? null : _confirmOrder,
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Konfirmasi'),
            ),
        ],
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
          
          // Customer Info
          _buildCustomerCard(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Service Details
          _buildServiceCard(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Payment Status
          _buildPaymentCard(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Technician Assignment
          _buildTechnicianCard(),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Action Buttons
          _buildActionButtons(),
          
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
              _buildInfoRow('Jadwal Servis', _formatDate(_order!.scheduledAt!)),
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

  Widget _buildCustomerCard() {
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
                      Text(
                        _customer?.name ?? '-',
                        style: AppTextStyles.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _customer?.phone ?? '-',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () => _navigateToChat(),
                ),
                IconButton(
                  icon: const Icon(Icons.phone_outlined),
                  onPressed: () {},
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
            Text('Detail Layanan', style: AppTextStyles.titleSmall),
            const Divider(height: AppSpacing.xl),
            Text(
              _service?.name ?? 'Layanan #${_order!.serviceId}',
              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.md),
            FutureBuilder<double>(
              future: MockDataService().getOrderTotal(_order!.id),
              builder: (context, snapshot) {
                final total = snapshot.data ?? 0;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: AppTextStyles.bodyMedium),
                    Text(
                      _formatCurrency(total),
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                      ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Status Pembayaran', style: AppTextStyles.titleSmall),
                if (_payment?.status == PaymentStatus.uploaded)
                  ElevatedButton(
                    onPressed: () => context.push(
                      RouteNames.adminVerifyPaymentPath(_order!.id),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('Verifikasi'),
                  ),
              ],
            ),
            const Divider(height: AppSpacing.xl),
            if (_payment == null)
              Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: AppColors.warning),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Menunggu pembayaran',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
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
                  if (_payment!.customerNote != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _buildInfoRow('Catatan Customer', _payment!.customerNote!),
                  ],
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Teknisi', style: AppTextStyles.titleSmall),
                if (_order!.status == OrderStatus.confirmed && _order!.assignedTo == null)
                  TextButton.icon(
                    onPressed: _isProcessing ? null : _showAssignSheet,
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Assign'),
                  ),
              ],
            ),
            const Divider(height: AppSpacing.xl),
            if (_technician != null)
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
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_order!.status == OrderStatus.confirmed)
                    IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      onPressed: _showAssignSheet,
                      tooltip: 'Ganti Teknisi',
                    ),
                ],
              )
            else
              Row(
                children: [
                  Icon(Icons.person_off_outlined, color: AppColors.textTertiary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Belum ditugaskan',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_order!.status == OrderStatus.pending)
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _confirmOrder,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Konfirmasi Pesanan'),
            ),
          ),
        if (_order!.status == OrderStatus.confirmed && _order!.assignedTo == null)
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _showAssignSheet,
              icon: const Icon(Icons.person_add),
              label: const Text('Assign Teknisi'),
            ),
          ),
        if (_order!.status == OrderStatus.cancelled)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.cancel, color: AppColors.error),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pesanan Dibatalkan',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_order!.cancelReason != null)
                        Text(
                          _order!.cancelReason!,
                          style: AppTextStyles.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showAssignSheet() {
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
                  'Pilih Teknisi',
                  style: AppTextStyles.titleMedium,
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _availableTechnicians.length,
                  itemBuilder: (context, index) {
                    final tech = _availableTechnicians[index];
                    final isSelected = _technician?.id == tech.id;
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.secondaryLight,
                        child: Text(
                          tech.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(tech.name),
                      subtitle: Text(tech.phone ?? '-'),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppColors.primary)
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        _assignTechnician(tech);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmOrder() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _order = OrderModel(
        id: _order!.id,
        orderCode: _order!.orderCode,
        customerId: _order!.customerId,
        serviceId: _order!.serviceId,
        divisionId: _order!.divisionId,
        assignedTo: _order!.assignedTo,
        status: OrderStatus.confirmed,
        address: _order!.address,
        notes: _order!.notes,
        scheduledAt: _order!.scheduledAt,
        confirmedAt: DateTime.now().toIso8601String(),
        assignedAt: _order!.assignedAt,
        onTheWayAt: _order!.onTheWayAt,
        inProgressAt: _order!.inProgressAt,
        doneAt: _order!.doneAt,
        cancelledAt: _order!.cancelledAt,
        cancelReason: _order!.cancelReason,
        createdAt: _order!.createdAt,
      );
      _isProcessing = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pesanan berhasil dikonfirmasi'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _assignTechnician(UserModel technician) async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _technician = technician;
      _order = OrderModel(
        id: _order!.id,
        orderCode: _order!.orderCode,
        customerId: _order!.customerId,
        serviceId: _order!.serviceId,
        divisionId: _order!.divisionId,
        assignedTo: technician.id,
        status: OrderStatus.assigned,
        address: _order!.address,
        notes: _order!.notes,
        scheduledAt: _order!.scheduledAt,
        confirmedAt: _order!.confirmedAt,
        assignedAt: DateTime.now().toIso8601String(),
        onTheWayAt: _order!.onTheWayAt,
        inProgressAt: _order!.inProgressAt,
        doneAt: _order!.doneAt,
        cancelledAt: _order!.cancelledAt,
        cancelReason: _order!.cancelReason,
        createdAt: _order!.createdAt,
      );
      _isProcessing = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pesanan ditugaskan ke ${technician.name}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _navigateToChat() async {
    final dataService = MockDataService();
    final chatRoom = await dataService.getChatRoom(
      _order!.customerId,
      _order!.divisionId,
    );
    
    if (chatRoom != null && mounted) {
      context.push(RouteNames.adminChatPath(chatRoom.id));
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

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}