import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/status_stepper.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../providers/app_state.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/service_model.dart';
import '../../../../data/models/payment_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/chat_room_model.dart';
import '../../../../core/routing/route_names.dart';

class CustomerOrderDetailScreen extends StatefulWidget {
  final int orderId;

  const CustomerOrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<CustomerOrderDetailScreen> createState() => _CustomerOrderDetailScreenState();
}

class _CustomerOrderDetailScreenState extends State<CustomerOrderDetailScreen> {
  OrderModel? _order;
  ServiceModel? _service;
  PaymentModel? _payment;
  UserModel? _technician;
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
    return Scaffold(
      appBar: AppAppBar(
        title: _order?.orderCode ?? 'Detail Pesanan',
        actions: [
          if (_order?.status == OrderStatus.pending)
            IconButton(
              icon: const Icon(Icons.payment),
              onPressed: () => _navigateToPayment(),
              tooltip: 'Bayar',
            ),
          if (_order?.status == OrderStatus.done)
            IconButton(
              icon: const Icon(Icons.star_outline),
              onPressed: () => _navigateToReview(),
              tooltip: 'Beri Ulasan',
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
          
          // Order Info Card
          _buildInfoCard(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Service Details
          _buildServiceCard(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Payment Status
          _buildPaymentCard(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Technician Info (if assigned)
          if (_technician != null) _buildTechnicianCard(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Address
          _buildAddressCard(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Notes
          if (_order!.notes != null) _buildNotesCard(),
          
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Informasi Pesanan',
                  style: AppTextStyles.titleSmall,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _order!.displayStatus,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.xl),
            _buildInfoRow('No. Pesanan', _order!.orderCode),
            const SizedBox(height: AppSpacing.sm),
            _buildInfoRow('Tanggal Pesan', _formatDate(_order!.createdAt)),
            if (_order!.scheduledAt != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildInfoRow('Jadwal Servis', _formatDate(_order!.scheduledAt!)),
            ],
            if (_order!.doneAt != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildInfoRow('Selesai', _formatDate(_order!.doneAt!)),
            ],
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
            Text(
              'Detail Layanan',
              style: AppTextStyles.titleSmall,
            ),
            const Divider(height: AppSpacing.xl),
            Text(
              _service?.name ?? 'Layanan #${_order!.serviceId}',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_service?.description != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                _service!.description!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            FutureBuilder<double>(
              future: MockDataService().getOrderTotal(_order!.id),
              builder: (context, snapshot) {
                final total = snapshot.data ?? 0;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: AppTextStyles.bodyMedium,
                    ),
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
                Text(
                  'Status Pembayaran',
                  style: AppTextStyles.titleSmall,
                ),
                if (_payment == null && _order!.status == OrderStatus.pending)
                  TextButton(
                    onPressed: () => _navigateToPayment(),
                    child: const Text('Bayar Sekarang'),
                  ),
              ],
            ),
            const Divider(height: AppSpacing.xl),
            if (_payment == null)
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppColors.warning,
                  ),
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
                  if (_payment!.verifiedAt != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _buildInfoRow('Diverifikasi', _formatDate(_payment!.verifiedAt!)),
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
            Text(
              'Teknisi',
              style: AppTextStyles.titleSmall,
            ),
            const Divider(height: AppSpacing.xl),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    _technician!.name.substring(0, 1).toUpperCase(),
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _technician!.name,
                        style: AppTextStyles.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _technician!.phone ?? '-',
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
                  tooltip: 'Chat Teknisi',
                ),
                IconButton(
                  icon: const Icon(Icons.phone_outlined),
                  onPressed: () {
                    // TODO: Implement call
                  },
                  tooltip: 'Hubungi',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Alamat Servis',
                  style: AppTextStyles.titleSmall,
                ),
              ],
            ),
            const Divider(height: AppSpacing.xl),
            Text(
              _order!.address,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Catatan',
                  style: AppTextStyles.titleSmall,
                ),
              ],
            ),
            const Divider(height: AppSpacing.xl),
            Text(
              _order!.notes!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
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
          width: 120,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_order!.status == OrderStatus.pending && _payment == null)
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToPayment(),
              icon: const Icon(Icons.payment),
              label: const Text('Bayar Sekarang'),
            ),
          ),
        if (_order!.status == OrderStatus.done)
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToReview(),
              icon: const Icon(Icons.star_outline),
              label: const Text('Beri Ulasan'),
            ),
          ),
        if (_order!.status == OrderStatus.confirmed || 
            _order!.status == OrderStatus.assigned ||
            _order!.status == OrderStatus.onTheWay ||
            _order!.status == OrderStatus.inProgress)
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: OutlinedButton.icon(
              onPressed: () => _navigateToChat(),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Hubungi Admin'),
            ),
          ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (_order!.status) {
      case OrderStatus.pending:
        return AppColors.statusPending;
      case OrderStatus.confirmed:
        return AppColors.statusConfirmed;
      case OrderStatus.assigned:
        return AppColors.statusAssigned;
      case OrderStatus.onTheWay:
        return AppColors.statusOnTheWay;
      case OrderStatus.inProgress:
        return AppColors.statusInProgress;
      case OrderStatus.done:
        return AppColors.statusDone;
      case OrderStatus.reviewed:
        return AppColors.statusReviewed;
      case OrderStatus.cancelled:
        return AppColors.statusCancelled;
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

  void _navigateToPayment() {
    context.push(RouteNames.customerUploadPaymentPath(_order!.id));
  }

  void _navigateToReview() {
    context.push(RouteNames.customerWriteReviewPath(_order!.id));
  }

  void _navigateToChat() async {
    if (_order == null) return;

    final dataService = MockDataService();
    final appState = Provider.of<AppState>(context, listen: false);

    ChatRoomModel? chatRoom = await dataService.getChatRoom(
      appState.currentUserId,
      _order!.divisionId,
    );

    if (chatRoom != null && mounted) {
      context.push(RouteNames.customerChatPath(chatRoom.id));
    } else {
      final allRooms = await dataService.getChatRooms();
      final divisionRoom = allRooms.firstWhere(
        (r) => r.divisionId == _order!.divisionId,
        orElse: () => allRooms.first,
      );
      if (mounted) {
        context.push(RouteNames.customerChatPath(divisionRoom.id));
      }
    }
  }
}