import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/service_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../core/routing/route_names.dart';

class WriteReviewScreen extends StatefulWidget {
  final int orderId;

  const WriteReviewScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final TextEditingController _commentController = TextEditingController();
  
  OrderModel? _order;
  ServiceModel? _service;
  UserModel? _technician;
  double _rating = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final dataService = MockDataService();
      final orders = await dataService.getOrders();
      _order = orders.firstWhere((o) => o.id == widget.orderId);
      
      if (_order != null) {
        _service = await dataService.getServiceById(_order!.serviceId);
        if (_order!.assignedTo != null) {
          _technician = await dataService.getUserById(_order!.assignedTo!);
        }
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        title: 'Beri Ulasan',
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat...')
          : _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.xl),
          
          // Order Info
          _buildOrderInfo(),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Technician Info
          if (_technician != null) _buildTechnicianInfo(),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Rating
          Text(
            'Bagaimana pengalaman Anda?',
            style: AppTextStyles.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          RatingBar.builder(
            initialRating: _rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4),
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: AppColors.starActive,
            ),
            onRatingUpdate: (rating) {
              setState(() => _rating = rating);
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _getRatingText(_rating),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Comment
          Text(
            'Tulis ulasan Anda',
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _commentController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Ceritakan pengalaman Anda menggunakan layanan kami...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 32,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Pesanan Selesai',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _order?.orderCode ?? '-',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _service?.name ?? '-',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicianInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                _technician!.name.substring(0, 1).toUpperCase(),
                style: AppTextStyles.headlineSmall.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _technician!.name,
              style: AppTextStyles.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Teknisi',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
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
        child: SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed: _rating > 0 && !_isSubmitting ? _submitReview : null,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Kirim Ulasan'),
          ),
        ),
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating == 0) return 'Pilih rating';
    if (rating <= 1) return 'Sangat Tidak Puas';
    if (rating <= 2) return 'Tidak Puas';
    if (rating <= 3) return 'Cukup';
    if (rating <= 4) return 'Puas';
    return 'Sangat Puas';
  }

  Future<void> _submitReview() async {
    setState(() => _isSubmitting = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() => _isSubmitting = false);
      
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
                'Terima Kasih!',
                style: AppTextStyles.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Ulasan Anda sangat berarti bagi kami.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go(RouteNames.customerOrders);
              },
              child: const Text('Kembali ke Pesanan'),
            ),
          ],
        ),
      );
    }
  }
}