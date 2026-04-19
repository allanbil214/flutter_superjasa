import 'package:flutter/material.dart';
import 'package:jasafix_app/core/constants/app_text_styles.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/order_card.dart';
import '../../../../providers/app_state.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../data/models/order_model.dart';
import '../../../../core/routing/route_names.dart';
import '../../home/widgets/customer_scaffold.dart';

class CustomerOrdersListScreen extends StatefulWidget {
  const CustomerOrdersListScreen({super.key});

  @override
  State<CustomerOrdersListScreen> createState() => _CustomerOrdersListScreenState();
}

class _CustomerOrdersListScreenState extends State<CustomerOrdersListScreen> {
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  OrderStatus? _statusFilter;

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
      final allOrders = await dataService.getOrders();
      _orders = allOrders.where((o) => o.customerId == appState.currentUserId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<OrderModel> get _filteredOrders {
    if (_statusFilter == null) return _orders;
    return _orders.where((o) => o.status == _statusFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CustomerScaffold(
      appBar: AppAppBar(
        title: AppStrings.navOrders,
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat pesanan...')
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_filteredOrders.isEmpty) {
      return EmptyState(
        icon: Icons.assignment_outlined,
        title: 'Belum ada pesanan',
        subtitle: _statusFilter != null 
            ? 'Tidak ada pesanan dengan status ini'
            : 'Pesanan Anda akan muncul di sini',
        buttonText: _statusFilter != null ? 'Lihat Semua' : null,
        onButtonPressed: _statusFilter != null 
            ? () => setState(() => _statusFilter = null)
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        itemCount: _filteredOrders.length,
        itemBuilder: (context, index) {
          final order = _filteredOrders[index];
          return OrderCard(
            order: order,
            onTap: () => context.push(RouteNames.customerOrderDetailPath(order.id)),
          );
        },
      ),
    );
  }

  void _showFilterSheet() {
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Status',
                      style: AppTextStyles.titleMedium,
                    ),
                    if (_statusFilter != null)
                      TextButton(
                        onPressed: () {
                          setState(() => _statusFilter = null);
                          Navigator.pop(context);
                        },
                        child: const Text('Reset'),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: OrderStatus.values
                      .where((s) => s != OrderStatus.cancelled)
                      .map((status) {
                    final count = _orders.where((o) => o.status == status).length;
                    return ListTile(
                      leading: Radio<OrderStatus>(
                        value: status,
                        groupValue: _statusFilter,
                        onChanged: (value) {
                          setState(() => _statusFilter = value);
                          Navigator.pop(context);
                        },
                      ),
                      title: Text(status.displayStatus),
                      trailing: count > 0 
                          ? CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              child: Text(
                                '$count',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : null,
                      onTap: () {
                        setState(() => _statusFilter = status);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}