import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../providers/app_state.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../data/models/service_model.dart';
import '../../../../data/models/division_model.dart';
import '../../../../data/models/chat_room_model.dart';
import '../../../../core/routing/route_names.dart';

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId;

  const ServiceDetailScreen({
    super.key,
    required this.serviceId,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  ServiceModel? _service;
  DivisionModel? _division;
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
      _service = await dataService.getServiceById(widget.serviceId);
      
      if (_service != null) {
        _division = await dataService.getDivisionById(_service!.divisionId);
      }
    } catch (e) {
      _error = 'Gagal memuat detail layanan';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        title: _service?.name ?? 'Detail Layanan',
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat detail layanan...')
          : _error != null
              ? ErrorView(message: _error!, onRetry: _loadData)
              : _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    if (_service == null) {
      return const ErrorView(message: 'Layanan tidak ditemukan');
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Image/Icon
          _buildHeader(),
          
          // Service Info
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),
                
                // Division Badge
                if (_division != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _getDivisionColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _division!.name,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: _getDivisionColor(),
                      ),
                    ),
                  ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Description
                if (_service!.description != null) ...[
                  Text(
                    'Deskripsi',
                    style: AppTextStyles.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _service!.description!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                
                // Price Card
                _buildPriceCard(),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Duration & Info
                _buildInfoCard(),
                
                const SizedBox(height: AppSpacing.lg),
                
                // What's Included
                _buildWhatsIncluded(),
                
                const SizedBox(height: AppSpacing.lg),
                
                // FAQ / Common Questions
                _buildFAQ(),
                
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xxxl,
        horizontal: AppSpacing.screenHorizontal,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getDivisionColor(),
            _getDivisionColor().withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getDivisionIcon(),
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _service!.name,
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Harga Layanan',
                  style: AppTextStyles.titleSmall,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Mulai dari',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _service!.formattedPrice,
              style: AppTextStyles.displaySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_service!.priceNote != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.warning.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _service!.priceNote!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardHorizontal),
        child: Column(
          children: [
            _buildInfoRow(
              icon: Icons.access_time,
              label: 'Estimasi Pengerjaan',
              value: _service!.durationEst ?? '1-2 jam',
            ),
            const Divider(height: AppSpacing.lg),
            _buildInfoRow(
              icon: Icons.verified_outlined,
              label: 'Garansi Servis',
              value: '7 Hari',
            ),
            const Divider(height: AppSpacing.lg),
            _buildInfoRow(
              icon: Icons.payments_outlined,
              label: 'Metode Pembayaran',
              value: 'Transfer Bank, E-Wallet, Tunai',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWhatsIncluded() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yang Termasuk dalam Layanan',
          style: AppTextStyles.titleSmall,
        ),
        const SizedBox(height: AppSpacing.md),
        ..._getIncludedItems().map((item) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle,
                size: 20,
                color: AppColors.success,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  item,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  List<String> _getIncludedItems() {
    // Default items based on service type
    switch (_service!.divisionId) {
      case 1: // AC
        return [
          'Pengecekan kondisi AC',
          'Pembersihan filter dan unit',
          'Pengecekan freon',
          'Konsultasi perawatan',
        ];
      case 2: // HP
        return [
          'Diagnosa kerusakan',
          'Penggantian komponen (jika perlu)',
          'Testing fungsional',
          'Garansi sparepart',
        ];
      default:
        return [
          'Diagnosa masalah',
          'Perbaikan oleh teknisi profesional',
          'Testing hasil perbaikan',
          'Konsultasi perawatan',
        ];
    }
  }

  Widget _buildFAQ() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pertanyaan Umum',
          style: AppTextStyles.titleSmall,
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              title: Text(
                'Apakah teknisi datang ke lokasi?',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'Ya, teknisi kami akan datang ke lokasi Anda sesuai dengan jadwal yang telah disepakati.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              title: Text(
                'Berapa lama garansi servis?',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'Kami memberikan garansi servis selama 7 hari setelah pengerjaan. Jika ada masalah terkait servis yang sama, kami akan kembali tanpa biaya tambahan.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              title: Text(
                'Bagaimana cara pembayaran?',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'Anda dapat membayar melalui transfer bank (BCA, Mandiri, BNI, BRI), e-wallet (GoPay, OVO, Dana), atau tunai langsung ke teknisi setelah servis selesai.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _navigateToChat,
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Chat'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _navigateToOrder,
                icon: const Icon(Icons.shopping_cart_outlined),
                label: const Text('Pesan Sekarang'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDivisionIcon() {
    switch (_service!.divisionId) {
      case 1: return Icons.ac_unit;
      case 2: return Icons.phone_android;
      case 3: return Icons.tv;
      case 4: return Icons.computer;
      case 5: return Icons.local_laundry_service;
      case 6: return Icons.wifi;
      case 7: return Icons.print;
      default: return Icons.build;
    }
  }

  Color _getDivisionColor() {
    switch (_service!.divisionId) {
      case 1: return const Color(0xFF00BCD4);
      case 2: return const Color(0xFF4CAF50);
      case 3: return const Color(0xFFFF9800);
      case 4: return const Color(0xFF2196F3);
      case 5: return const Color(0xFF9C27B0);
      case 6: return const Color(0xFFF44336);
      case 7: return const Color(0xFF607D8B);
      default: return AppColors.primary;
    }
  }

  void _navigateToChat() async {
    final dataService = MockDataService();
    final appState = Provider.of<AppState>(context, listen: false);
    final currentUser = appState.currentUser;

    if (currentUser == null || _service == null) return;

    ChatRoomModel? chatRoom = await dataService.getChatRoom(
      currentUser.id,
      _service!.divisionId,
    );

    if (chatRoom != null && mounted) {
      context.push(RouteNames.customerChatPath(chatRoom.id));
    } else {
      final allRooms = await dataService.getChatRooms();
      final divisionRoom = allRooms.firstWhere(
        (r) => r.divisionId == _service!.divisionId,
        orElse: () => allRooms.first,
      );
      if (mounted) {
        context.push(RouteNames.customerChatPath(divisionRoom.id));
      }
    }
  }

  void _navigateToOrder() {
    context.push(
      RouteNames.customerCreateOrder,
      extra: {
        'serviceId': _service!.id,
        'divisionId': _service!.divisionId,
      },
    );
  }
}