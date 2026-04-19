import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/employee_documentation_model.dart';
import '../../../../core/routing/route_names.dart';
import '../../scaffold/employee_scaffold.dart';

class OrderDocumentationsScreen extends StatefulWidget {
  final int orderId;

  const OrderDocumentationsScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDocumentationsScreen> createState() => _OrderDocumentationsScreenState();
}

class _OrderDocumentationsScreenState extends State<OrderDocumentationsScreen> {
  OrderModel? _order;
  List<EmployeeDocumentationModel> _documentations = [];
  bool _isLoading = true;
  DocumentationStage? _selectedStage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final dataService = MockDataService();
      final orders = await dataService.getOrders();
      _order = orders.firstWhere((o) => o.id == widget.orderId);
      _documentations = await dataService.getDocumentationsByOrder(widget.orderId);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<EmployeeDocumentationModel> get _filteredDocs {
    if (_selectedStage == null) return _documentations;
    return _documentations.where((d) => d.stage == _selectedStage).toList();
  }

  @override
  Widget build(BuildContext context) {
    return EmployeeScaffold(
      appBar: AppAppBar(
        title: _order?.orderCode ?? 'Dokumentasi',
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat dokumentasi...')
          : _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(RouteNames.employeeAddDocumentationPath(widget.orderId));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Stage Filter
        Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStageChip('Semua', null),
                const SizedBox(width: AppSpacing.sm),
                _buildStageChip('Sebelum', DocumentationStage.before),
                const SizedBox(width: AppSpacing.sm),
                _buildStageChip('Saat', DocumentationStage.during),
                const SizedBox(width: AppSpacing.sm),
                _buildStageChip('Setelah', DocumentationStage.after),
              ],
            ),
          ),
        ),
        
        // Documentation List
        Expanded(
          child: _filteredDocs.isEmpty
              ? EmptyState(
                  icon: Icons.photo_camera_outlined,
                  title: 'Belum ada dokumentasi',
                  subtitle: _selectedStage != null
                      ? 'Tidak ada dokumentasi untuk tahap ini'
                      : 'Tambahkan dokumentasi dengan tombol +',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  itemCount: _filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = _filteredDocs[index];
                    return _buildDocumentationCard(doc);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStageChip(String label, DocumentationStage? stage) {
    final isSelected = _selectedStage == stage;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedStage = stage),
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary.withOpacity(0.1),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildDocumentationCard(EmployeeDocumentationModel doc) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStageColor(doc.stage).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    doc.displayStage,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: _getStageColor(doc.stage),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(doc.createdAt),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              doc.title,
              style: AppTextStyles.titleSmall,
            ),
            if (doc.description != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                doc.description!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            
            // Media Preview
            if (doc.media.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: doc.media.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStageColor(DocumentationStage stage) {
    switch (stage) {
      case DocumentationStage.before:
        return AppColors.info;
      case DocumentationStage.during:
        return AppColors.warning;
      case DocumentationStage.after:
        return AppColors.success;
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