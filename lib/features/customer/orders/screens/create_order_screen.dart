import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../providers/app_state.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../data/models/service_model.dart';
import '../../../../data/models/division_model.dart';
import '../../../../core/routing/route_names.dart';

class CreateOrderScreen extends StatefulWidget {
  final int? serviceId;
  final int? divisionId;

  const CreateOrderScreen({
    super.key,
    this.serviceId,
    this.divisionId,
  });

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  
  ServiceModel? _selectedService;
  DivisionModel? _selectedDivision;
  List<ServiceModel> _services = [];
  List<DivisionModel> _divisions = [];
  DateTime? _scheduledDate;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final dataService = MockDataService();
      final appState = Provider.of<AppState>(context, listen: false);
      
      _divisions = await dataService.getDivisions();
      
      if (widget.divisionId != null) {
        _selectedDivision = _divisions.firstWhere((d) => d.id == widget.divisionId);
        _services = await dataService.getServicesByDivision(widget.divisionId!);
      } else {
        _services = await dataService.getServices();
      }
      
      if (widget.serviceId != null) {
        _selectedService = _services.firstWhere((s) => s.id == widget.serviceId);
      }
      
      // Pre-fill address from user profile
      if (appState.currentUser?.address != null) {
        _addressController.text = appState.currentUser!.address!;
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        title: 'Buat Pesanan',
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat...')
          : _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            
            // Division Selector (if not pre-selected)
            if (widget.divisionId == null) ...[
              _buildDivisionSelector(),
              const SizedBox(height: AppSpacing.lg),
            ],
            
            // Service Selector
            _buildServiceSelector(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Schedule Picker
            _buildSchedulePicker(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Address Field
            _buildAddressField(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Notes Field
            _buildNotesField(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Order Summary
            _buildOrderSummary(),
            
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildDivisionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Divisi',
          style: AppTextStyles.titleSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppSpacing.buttonBorderRadius),
          ),
          child: DropdownButtonFormField<DivisionModel>(
            value: _selectedDivision,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
            items: _divisions.map((division) {
              return DropdownMenuItem(
                value: division,
                child: Text(division.name),
              );
            }).toList(),
            onChanged: (value) async {
              setState(() {
                _selectedDivision = value;
                _selectedService = null;
              });
              if (value != null) {
                final dataService = MockDataService();
                _services = await dataService.getServicesByDivision(value.id);
                setState(() {});
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Layanan',
          style: AppTextStyles.titleSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppSpacing.buttonBorderRadius),
          ),
          child: DropdownButtonFormField<ServiceModel>(
            value: _selectedService,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
            items: _services.map((service) {
              return DropdownMenuItem(
                value: service,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.name),
                    Text(
                      service.formattedPrice,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedService = value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSchedulePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jadwal Servis',
          style: AppTextStyles.titleSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: _pickSchedule,
          borderRadius: BorderRadius.circular(AppSpacing.buttonBorderRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppSpacing.buttonBorderRadius),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    _scheduledDate != null
                        ? _formatDateTime(_scheduledDate!)
                        : 'Pilih tanggal dan waktu',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _scheduledDate != null
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
                if (_scheduledDate != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      setState(() => _scheduledDate = null);
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alamat Servis',
          style: AppTextStyles.titleSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _addressController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Masukkan alamat lengkap',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Alamat harus diisi';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catatan (Opsional)',
          style: AppTextStyles.titleSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Contoh: AC tidak dingin, pintu rumah warna biru, dll.',
            prefixIcon: Icon(Icons.note_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    if (_selectedService == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Pesanan',
              style: AppTextStyles.titleSmall,
            ),
            const Divider(height: AppSpacing.xl),
            _buildSummaryRow('Layanan', _selectedService!.name),
            const SizedBox(height: AppSpacing.sm),
            _buildSummaryRow('Harga', _selectedService!.formattedPrice),
            const SizedBox(height: AppSpacing.sm),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            _buildSummaryRow(
              'Total',
              _selectedService!.formattedPrice,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.titleSmall
              : AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
        ),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.titleSmall.copyWith(color: AppColors.primary)
              : AppTextStyles.bodyMedium,
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
        child: SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitOrder,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Buat Pesanan'),
          ),
        ),
      ),
    );
  }

  Future<void> _pickSchedule() async {
    final now = DateTime.now();
    final initialDate = _scheduledDate ?? now.add(const Duration(days: 1));
    
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    
    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );
      
      if (time != null) {
        setState(() {
          _scheduledDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih layanan terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isSubmitting = false);
      
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: 48,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pesanan Berhasil Dibuat!',
                style: AppTextStyles.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Admin akan segera mengkonfirmasi pesanan Anda. Silakan lanjutkan ke pembayaran.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go(RouteNames.customerOrders);
              },
              child: const Text('Lihat Pesanan'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to payment with new order ID (mock)
                context.push(RouteNames.customerUploadPaymentPath(999));
              },
              child: const Text('Bayar Sekarang'),
            ),
          ],
        ),
      );
    }
  }
}