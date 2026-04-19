import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/order_card.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/division_model.dart';
import '../../../../core/routing/route_names.dart';
import '../../scaffold/super_admin_scaffold.dart';

class SuperAdminOrdersListScreen extends StatefulWidget {
  const SuperAdminOrdersListScreen({super.key});

  @override
  State<SuperAdminOrdersListScreen> createState() => _SuperAdminOrdersListScreenState();
}

class _SuperAdminOrdersListScreenState extends State<SuperAdminOrdersListScreen> {
  List<OrderModel> _orders = [];
  List<DivisionModel> _divisions = [];
  bool _isLoading = true;
  OrderStatus? _statusFilter;
  int? _divisionFilter;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final dataService = MockDataService();
      _orders = await dataService.getOrders();
      _divisions = await dataService.getDivisions();
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
    
    if (_divisionFilter != null) {
      filtered = filtered.where((o) => o.divisionId == _divisionFilter).toList();
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
    return SuperAdminScaffold(
      appBar: AppAppBar(
        title: 'Semua Pesanan',
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
        
        // Active Filters
        if (_statusFilter != null || _divisionFilter != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                if (_statusFilter != null)
                  Chip(
                    label: Text(_statusFilter!.displayStatus),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => setState(() => _statusFilter = null),
                  ),
                if (_divisionFilter != null)
                  Chip(
                    label: Text(_getDivisionName(_divisionFilter!)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => setState(() => _divisionFilter = null),
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
                  subtitle: 'Coba ubah filter pencarian',
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: OrderCard(
                          order: order,
                          onTap: () => context.push(
                            RouteNames.superAdminOrderDetailPath(order.id),
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
                    Text('Filter', style: AppTextStyles.titleMedium),
                    if (_statusFilter != null || _divisionFilter != null)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _statusFilter = null;
                            _divisionFilter = null;
                          });
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
                  children: [
                    // Division Filter
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Text('Divisi', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    ..._divisions.map((division) {
                      final count = _orders.where((o) => o.divisionId == division.id).length;
                      return RadioListTile<int?>(
                        value: division.id,
                        groupValue: _divisionFilter,
                        onChanged: (value) {
                          setState(() => _divisionFilter = value);
                          Navigator.pop(context);
                        },
                        title: Text(division.name),
                        secondary: count > 0
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
                      );
                    }),
                    
                    const Divider(),
                    
                    // Status Filter
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    ...OrderStatus.values.map((status) {
                      final count = _orders.where((o) => o.status == status).length;
                      return RadioListTile<OrderStatus?>(
                        value: status,
                        groupValue: _statusFilter,
                        onChanged: (value) {
                          setState(() => _statusFilter = value);
                          Navigator.pop(context);
                        },
                        title: Text(status.displayStatus),
                        secondary: count > 0
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
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getDivisionName(int id) {
    return _divisions.firstWhere((d) => d.id == id).name;
  }
}