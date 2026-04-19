import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
import '../../../../data/models/user_model.dart';
import '../../../../data/models/chat_room_model.dart';
import '../../../../core/routing/route_names.dart';
import '../../scaffold/employee_scaffold.dart';

class EmployeeTaskDetailScreen extends StatefulWidget {
  final int orderId;

  const EmployeeTaskDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<EmployeeTaskDetailScreen> createState() => _EmployeeTaskDetailScreenState();
}

class _EmployeeTaskDetailScreenState extends State<EmployeeTaskDetailScreen> {
  OrderModel? _order;
  ServiceModel? _service;
  UserModel? _customer;
  bool _isLoading = true;
  bool _isUpdating = false;
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
        _customer = await dataService.getUserById(_order!.customerId);
      }
    } catch (e) {
      _error = 'Gagal memuat detail tugas';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(OrderStatus newStatus) async {
    setState(() => _isUpdating = true);
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _order = OrderModel(
        id: _order!.id,
        orderCode: _order!.orderCode,
        customerId: _order!.customerId,
        serviceId: _order!.serviceId,
        divisionId: _order!.divisionId,
        assignedTo: _order!.assignedTo,
        status: newStatus,
        address: _order!.address,
        notes: _order!.notes,
        scheduledAt: _order!.scheduledAt,
        confirmedAt: _order!.confirmedAt,
        assignedAt: _order!.assignedAt,
        onTheWayAt: newStatus == OrderStatus.onTheWay ? DateTime.now().toIso8601String() : _order!.onTheWayAt,
        inProgressAt: newStatus == OrderStatus.inProgress ? DateTime.now().toIso8601String() : _order!.inProgressAt,
        doneAt: newStatus == OrderStatus.done ? DateTime.now().toIso8601String() : _order!.doneAt,
        cancelledAt: _order!.cancelledAt,
        cancelReason: _order!.cancelReason,
        createdAt: _order!.createdAt,
      );
      _isUpdating = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status: ${newStatus.displayStatus}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return EmployeeScaffold(
      appBar: AppAppBar(
        title: _order?.orderCode ?? 'Detail Tugas',
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: _navigateToChat,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat detail...')
          : _error != null
              ? ErrorView(message: _error!, onRetry: _loadData)
              : _buildBody(),
      bottomSheet: _order?.isActive == true ? _buildBottomBar() : null,
    );
  }

  Widget _buildBody() {
    if (_order == null) {
      return const ErrorView(message: 'Tugas tidak ditemukan');
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
          
          // Service Info
          _buildServiceCard(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Customer Info
          _buildCustomerCard(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Address
          _buildAddressCard(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Notes
          if (_order!.notes != null) _buildNotesCard(),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Schedule
          if (_order!.scheduledAt != null) _buildScheduleCard(),
          
          const SizedBox(height: AppSpacing.xl),
        ],
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
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: AppTextStyles.bodyMedium),
                    Text(
                      _formatCurrency(snapshot.data ?? 0),
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
                IconButton(
                  icon: const Icon(Icons.phone_outlined),
                  onPressed: () {},
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
                Icon(Icons.location_on_outlined, size: 20, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text('Alamat Servis', style: AppTextStyles.titleSmall),
              ],
            ),
            const Divider(height: AppSpacing.xl),
            Text(_order!.address, style: AppTextStyles.bodyMedium),
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
                Icon(Icons.note_outlined, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.sm),
                Text('Catatan', style: AppTextStyles.titleSmall),
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

  Widget _buildScheduleCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text('Jadwal Servis', style: AppTextStyles.titleSmall),
              ],
            ),
            const Divider(height: AppSpacing.xl),
            Text(
              _formatDateTime(_order!.scheduledAt!),
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
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
        child: Row(
          children: [
            if (_order!.status == OrderStatus.assigned) ...[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isUpdating ? null : () => _updateStatus(OrderStatus.onTheWay),
                  icon: const Icon(Icons.directions_bike),
                  label: const Text('OTW'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
            ],
            if (_order!.status == OrderStatus.onTheWay) ...[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isUpdating ? null : () => _updateStatus(OrderStatus.inProgress),
                  icon: const Icon(Icons.build),
                  label: const Text('Mulai Pengerjaan'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
            ],
            if (_order!.status == OrderStatus.inProgress) ...[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isUpdating ? null : () => _updateStatus(OrderStatus.done),
                  icon: const Icon(Icons.check),
                  label: const Text('Selesai'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push(RouteNames.employeeAddDocumentationPath(_order!.id));
                  },
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Dokumentasi'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToChat() async {
    if (_order == null || _customer == null) return;

    final dataService = MockDataService();
    ChatRoomModel? chatRoom = await dataService.getChatRoom(
      _customer!.id,
      _order!.divisionId,
    );

    if (chatRoom != null && mounted) {
      context.push(RouteNames.employeeChatPath(chatRoom.id));
    } else {
      final allRooms = await dataService.getChatRooms();
      final divisionRoom = allRooms.firstWhere(
        (r) => r.divisionId == _order!.divisionId,
        orElse: () => allRooms.first,
      );
      if (mounted) {
        context.push(RouteNames.employeeChatPath(divisionRoom.id));
      }
    }
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String _formatDateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateString;
    }
  }
}