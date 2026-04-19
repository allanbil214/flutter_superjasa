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
import '../../../../data/models/division_model.dart';
import '../../../../data/models/service_model.dart';
import '../../../../data/models/chat_room_model.dart';
import '../../../../core/routing/route_names.dart';
import '../widgets/service_list_item.dart';

class CustomerDivisionDetailScreen extends StatefulWidget {
  final int divisionId;

  const CustomerDivisionDetailScreen({
    super.key,
    required this.divisionId,
  });

  @override
  State<CustomerDivisionDetailScreen> createState() => _CustomerDivisionDetailScreenState();
}

class _CustomerDivisionDetailScreenState extends State<CustomerDivisionDetailScreen> {
  DivisionModel? _division;
  List<ServiceModel> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final dataService = MockDataService();
      _division = await dataService.getDivisionById(widget.divisionId);
      _services = await dataService.getServicesByDivision(widget.divisionId);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        title: _division?.name ?? 'Detail Divisi',
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat layanan...')
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_division == null) {
      return const EmptyState(
        icon: Icons.error_outline,
        title: 'Divisi tidak ditemukan',
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          // Description
          if (_division!.description != null) ...[
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              child: Text(
                _division!.description!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
          // Services Title
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Layanan Tersedia',
                  style: AppTextStyles.titleMedium,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_services.length} layanan',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Services List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            itemCount: _services.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              return ServiceListItem(
                service: _services[index],
                onTap: () => _navigateToChat(context, _services[index]),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
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
          const SizedBox(height: AppSpacing.md),
          Text(
            _division!.name,
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getDivisionIcon() {
    switch (widget.divisionId) {
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
    switch (widget.divisionId) {
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

  void _navigateToChat(BuildContext context, ServiceModel service) async {
    final dataService = MockDataService();
    final appState = Provider.of<AppState>(context, listen: false);
    final currentUser = appState.currentUser;

    if (currentUser == null) return;

    ChatRoomModel? chatRoom = await dataService.getChatRoom(
      currentUser.id,
      widget.divisionId,
    );

    if (chatRoom != null && mounted) {
      context.push(RouteNames.customerChatPath(chatRoom.id));
    } else {
      final allRooms = await dataService.getChatRooms();
      final divisionRoom = allRooms.firstWhere(
        (r) => r.divisionId == widget.divisionId,
        orElse: () => allRooms.first,
      );
      if (mounted) {
        context.push(RouteNames.customerChatPath(divisionRoom.id));
      }
    }
  }
}