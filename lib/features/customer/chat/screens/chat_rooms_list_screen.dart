import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../providers/app_state.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../data/models/chat_room_model.dart';
import '../../../../data/models/division_model.dart';
import '../../../../data/models/chat_message_model.dart';
import '../../../../core/routing/route_names.dart';
import '../../home/widgets/customer_scaffold.dart';

class CustomerChatRoomsScreen extends StatefulWidget {
  const CustomerChatRoomsScreen({super.key});

  @override
  State<CustomerChatRoomsScreen> createState() => _CustomerChatRoomsScreenState();
}

class _CustomerChatRoomsScreenState extends State<CustomerChatRoomsScreen> {
  List<ChatRoomWithDetails> _chatRooms = [];
  bool _isLoading = true;

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
      
      final rooms = await dataService.getChatRoomsByCustomer(appState.currentUserId);
      final divisions = await dataService.getDivisions();
      
      List<ChatRoomWithDetails> roomsWithDetails = [];
      
      for (final room in rooms) {
        final division = divisions.firstWhere(
          (d) => d.id == room.divisionId,
          orElse: () => divisions.first,
        );
        
        final messages = await dataService.getMessagesByRoom(room.id);
        final lastMessage = messages.isNotEmpty ? messages.last : null;
        final unreadCount = messages.where((m) => !m.isRead && m.senderId != appState.currentUserId).length;
        
        roomsWithDetails.add(ChatRoomWithDetails(
          room: room,
          division: division,
          lastMessage: lastMessage,
          unreadCount: unreadCount,
        ));
      }
      
      roomsWithDetails.sort((a, b) {
        if (a.lastMessage == null) return 1;
        if (b.lastMessage == null) return -1;
        return b.lastMessage!.createdAt.compareTo(a.lastMessage!.createdAt);
      });
      
      setState(() => _chatRooms = roomsWithDetails);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomerScaffold(
      appBar: AppAppBar(
        title: AppStrings.navChat,
        showBackButton: false,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat chat...')
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_chatRooms.isEmpty) {
      return EmptyState(
        icon: Icons.chat_bubble_outline,
        title: 'Belum ada chat',
        subtitle: 'Pilih layanan dan mulai chat dengan admin',
        buttonText: 'Lihat Layanan',
        onButtonPressed: () {
          context.go(RouteNames.customerHome);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        itemCount: _chatRooms.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
        itemBuilder: (context, index) {
          final roomData = _chatRooms[index];
          return _buildChatRoomTile(roomData);
        },
      ),
    );
  }

  Widget _buildChatRoomTile(ChatRoomWithDetails roomData) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.sm,
      ),
      leading: _buildAvatar(roomData),
      title: Row(
        children: [
          Expanded(
            child: Text(
              roomData.division.name,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (roomData.lastMessage != null)
            Text(
              _formatTime(roomData.lastMessage!.createdAt),
              style: AppTextStyles.caption,
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            roomData.lastMessage?.content ?? 'Mulai percakapan...',
            style: AppTextStyles.bodySmall.copyWith(
              color: roomData.unreadCount > 0
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: roomData.unreadCount > 0
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing: roomData.unreadCount > 0
          ? Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  roomData.unreadCount > 9 ? '9+' : '${roomData.unreadCount}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          : null,
      onTap: () {
        context.push(RouteNames.customerChatPath(roomData.room.id));
      },
    );
  }

  Widget _buildAvatar(ChatRoomWithDetails roomData) {
    return Stack(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _getDivisionColor(roomData.division.id).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getDivisionIcon(roomData.division.id),
            color: _getDivisionColor(roomData.division.id),
            size: 28,
          ),
        ),
        if (roomData.unreadCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  IconData _getDivisionIcon(int id) {
    switch (id) {
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

  Color _getDivisionColor(int id) {
    switch (id) {
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

  String _formatTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 7) {
        return '${date.day}/${date.month}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}h';
      } else {
        return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      }
    } catch (_) {
      return '';
    }
  }

}

class ChatRoomWithDetails {
  final ChatRoomModel room;
  final DivisionModel division;
  final ChatMessageModel? lastMessage;
  final int unreadCount;

  ChatRoomWithDetails({
    required this.room,
    required this.division,
    this.lastMessage,
    required this.unreadCount,
  });
}