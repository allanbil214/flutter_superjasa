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
import '../../../../data/models/order_model.dart';
import '../../../../data/models/service_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/chat_room_model.dart';
import '../../../../core/routing/route_names.dart';
import '../../scaffold/employee_scaffold.dart';

class EmployeeTasksListScreen extends StatefulWidget {
  const EmployeeTasksListScreen({super.key});

  @override
  State<EmployeeTasksListScreen> createState() => _EmployeeTasksListScreenState();
}

class _EmployeeTasksListScreenState extends State<EmployeeTasksListScreen> {
  List<TaskWithDetails> _tasks = [];
  bool _isLoading = true;
  String _activeFilter = 'semua';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final dataService = MockDataService();
      final currentUser = appState.currentUser;
      
      if (currentUser == null) return;
      
      final orders = await dataService.getOrdersByEmployee(currentUser.id);
      final customers = await dataService.getUsers();
      
      List<TaskWithDetails> tasks = [];
      
      for (final order in orders) {
        final service = await dataService.getServiceById(order.serviceId);
        final customer = customers.firstWhere((c) => c.id == order.customerId);
        
        tasks.add(TaskWithDetails(
          order: order,
          service: service,
          customer: customer,
        ));
      }
      
      tasks.sort((a, b) {
        // Active tasks first
        if (a.order.isActive && !b.order.isActive) return -1;
        if (!a.order.isActive && b.order.isActive) return 1;
        
        // Then by scheduled date
        if (a.order.scheduledAt != null && b.order.scheduledAt != null) {
          return a.order.scheduledAt!.compareTo(b.order.scheduledAt!);
        }
        
        return b.order.createdAt.compareTo(a.order.createdAt);
      });
      
      setState(() => _tasks = tasks);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<TaskWithDetails> get _filteredTasks {
    if (_activeFilter == 'aktif') {
      return _tasks.where((t) => t.order.isActive).toList();
    } else if (_activeFilter == 'selesai') {
      return _tasks.where((t) => t.order.isCompleted).toList();
    }
    return _tasks;
  }

  int get _todayTasks {
    final today = DateTime.now();
    return _tasks.where((t) {
      if (t.order.scheduledAt == null) return false;
      final scheduled = DateTime.parse(t.order.scheduledAt!);
      return scheduled.year == today.year &&
             scheduled.month == today.month &&
             scheduled.day == today.day;
    }).length;
  }

  int get _activeTasks => _tasks.where((t) => t.order.isActive).length;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    return EmployeeScaffold(
      appBar: AppAppBar(
        title: 'Tugas Saya',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(RouteNames.employeeNotifications),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat tugas...')
          : _buildBody(appState),
    );
  }

  Widget _buildBody(AppState appState) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            
            // Welcome Card
            _buildWelcomeCard(appState),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Stats Cards
            _buildStatsCards(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Filter Chips
            _buildFilterChips(),
            
            const SizedBox(height: AppSpacing.md),
            
            // Tasks List
            _buildTasksList(),
            
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary,
            AppColors.secondaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  appState.currentUser?.name.substring(0, 1).toUpperCase() ?? 'E',
                  style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo,',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      appState.currentUser?.name ?? 'Teknisi',
                      style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.white.withOpacity(0.8)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '$_todayTasks tugas hari ini',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Tugas Aktif',
            value: _activeTasks.toString(),
            icon: Icons.pending_actions,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            title: 'Selesai',
            value: _tasks.where((t) => t.order.isCompleted).length.toString(),
            icon: Icons.check_circle_outline,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTextStyles.headlineSmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Row(
      children: [
        _buildFilterChip('Semua', 'semua'),
        const SizedBox(width: AppSpacing.sm),
        _buildFilterChip('Aktif', 'aktif'),
        const SizedBox(width: AppSpacing.sm),
        _buildFilterChip('Selesai', 'selesai'),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _activeFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _activeFilter = value),
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary.withOpacity(0.1),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildTasksList() {
    if (_filteredTasks.isEmpty) {
      return EmptyState(
        icon: Icons.assignment_outlined,
        title: 'Tidak ada tugas',
        subtitle: _activeFilter == 'semua'
            ? 'Belum ada tugas yang ditugaskan'
            : 'Tidak ada tugas dengan filter ini',
      );
    }

    return Column(
      children: _filteredTasks.map((task) => _buildTaskCard(task)).toList(),
    );
  }

  Widget _buildTaskCard(TaskWithDetails task) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {
          context.push(RouteNames.employeeTaskDetailPath(task.order.id));
        },
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.order.orderCode,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(task.order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      task.order.displayStatus,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: _getStatusColor(task.order.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                task.service?.name ?? 'Layanan #${task.order.serviceId}',
                style: AppTextStyles.titleSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    task.customer.name,
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      task.order.address,
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (task.order.scheduledAt != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(task.order.scheduledAt!),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (task.order.status == OrderStatus.assigned)
                    ElevatedButton.icon(
                      onPressed: () => _updateStatus(task.order, OrderStatus.onTheWay),
                      icon: const Icon(Icons.directions_bike, size: 18),
                      label: const Text('OTW'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                      ),
                    ),
                  if (task.order.status == OrderStatus.onTheWay)
                    ElevatedButton.icon(
                      onPressed: () => _updateStatus(task.order, OrderStatus.inProgress),
                      icon: const Icon(Icons.build, size: 18),
                      label: const Text('Mulai Kerja'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                      ),
                    ),
                  if (task.order.status == OrderStatus.inProgress)
                    ElevatedButton.icon(
                      onPressed: () => _updateStatus(task.order, OrderStatus.done),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Selesai'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                      ),
                    ),
                  const SizedBox(width: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () => _navigateToChat(task),
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('Chat'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
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

  Future<void> _navigateToChat(TaskWithDetails task) async {
    final dataService = MockDataService();
    ChatRoomModel? chatRoom = await dataService.getChatRoom(
      task.customer.id,
      task.order.divisionId,
    );

    if (chatRoom != null && mounted) {
      context.push(RouteNames.employeeChatPath(chatRoom.id));
    } else {
      final allRooms = await dataService.getChatRooms();
      final divisionRoom = allRooms.firstWhere(
        (r) => r.divisionId == task.order.divisionId,
        orElse: () => allRooms.first,
      );
      if (mounted) {
        context.push(RouteNames.employeeChatPath(divisionRoom.id));
      }
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
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

  Future<void> _updateStatus(OrderModel order, OrderStatus newStatus) async {
    setState(() {
      final taskIndex = _tasks.indexWhere((t) => t.order.id == order.id);
      if (taskIndex >= 0) {
        final updatedOrder = OrderModel(
          id: order.id,
          orderCode: order.orderCode,
          customerId: order.customerId,
          serviceId: order.serviceId,
          divisionId: order.divisionId,
          assignedTo: order.assignedTo,
          status: newStatus,
          address: order.address,
          notes: order.notes,
          scheduledAt: order.scheduledAt,
          confirmedAt: order.confirmedAt,
          assignedAt: order.assignedAt,
          onTheWayAt: newStatus == OrderStatus.onTheWay ? DateTime.now().toIso8601String() : order.onTheWayAt,
          inProgressAt: newStatus == OrderStatus.inProgress ? DateTime.now().toIso8601String() : order.inProgressAt,
          doneAt: newStatus == OrderStatus.done ? DateTime.now().toIso8601String() : order.doneAt,
          cancelledAt: order.cancelledAt,
          cancelReason: order.cancelReason,
          createdAt: order.createdAt,
        );
        
        _tasks[taskIndex] = TaskWithDetails(
          order: updatedOrder,
          service: _tasks[taskIndex].service,
          customer: _tasks[taskIndex].customer,
        );
      }
    });
    
    String message;
    switch (newStatus) {
      case OrderStatus.onTheWay:
        message = 'Anda dalam perjalanan ke lokasi customer';
        break;
      case OrderStatus.inProgress:
        message = 'Pengerjaan dimulai';
        break;
      case OrderStatus.done:
        message = 'Pesanan selesai! Jangan lupa tambahkan dokumentasi';
        break;
      default:
        message = 'Status diperbarui';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  String _formatDateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateString;
    }
  }
}

class TaskWithDetails {
  final OrderModel order;
  final ServiceModel? service;
  final UserModel customer;

  TaskWithDetails({
    required this.order,
    this.service,
    required this.customer,
  });
}