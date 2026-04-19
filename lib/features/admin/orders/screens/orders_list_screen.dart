import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/order_card.dart';
import '../../../../providers/app_state.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../data/models/order_model.dart';
import '../../../../core/routing/route_names.dart';
import '../../scaffold/admin_scaffold.dart';

class AdminOrdersListScreen extends StatefulWidget {
  const AdminOrdersListScreen({super.key});

  @override
  State<AdminOrdersListScreen> createState() => _AdminOrdersListScreenState();
}

class _AdminOrdersListScreenState extends State<AdminOrdersListScreen> {
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  OrderStatus? _statusFilter;
  String _searchQuery = '';

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
      
      final divisions = await dataService.getDivisions();
      final adminDivision = divisions.firstWhere(
        (d) => d.adminIds.contains(currentUser.id),
        orElse: () => divisions.first,
      );
      
      _orders = await dataService.getOrdersByDivision(adminDivision.id);
      _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<OrderModel> get _filteredOrders {
    var filtered = _orders;
    
    if (_statusFilter != null) {
      filtered = filtered.where((o) => o.status == _statusFilter).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((o) => 
        o.orderCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        o.address.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      appBar: AppAppBar(
        title: 'Daftar Pesanan',
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
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari pesanan...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        
        // Filter Chips
        if (_statusFilter != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            child: Row(
              children: [
                Chip(
                  label: Text(_statusFilter!.displayStatus),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => setState(() => _statusFilter = null),
                ),
              ],
            ),
          ),
        
        // Orders List
        Expanded(
          child: _filteredOrders.isEmpty
              ? EmptyState(
                  icon: Icons.assignment_outlined,
                  title: 'Tidak ada pesanan',
                  subtitle: _statusFilter != null
                      ? 'Tidak ada pesanan dengan status ini'
                      : 'Pesanan akan muncul di sini',
                  buttonText: _statusFilter != null ? 'Reset Filter' : null,
                  onButtonPressed: _statusFilter != null
                      ? () => setState(() => _statusFilter = null)
                      : null,
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: OrderCard(
                          order: order,
                          onTap: () => context.push(
                            RouteNames.adminOrderDetailPath(order.id),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
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
                  children: OrderStatus.values.map((status) {
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
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
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