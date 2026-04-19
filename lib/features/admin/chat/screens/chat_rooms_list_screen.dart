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
import '../../../../data/models/chat_room_model.dart';
import '../../../../data/models/chat_message_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../core/routing/route_names.dart';
import '../../scaffold/admin_scaffold.dart';

class AdminChatRoomsScreen extends StatefulWidget {
  const AdminChatRoomsScreen({super.key});

  @override
  State<AdminChatRoomsScreen> createState() => _AdminChatRoomsScreenState();
}

class _AdminChatRoomsScreenState extends State<AdminChatRoomsScreen> {
  List<ChatRoomWithCustomer> _chatRooms = [];
  bool _isLoading = true;
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
      
      final rooms = await dataService.getChatRoomsByDivision(adminDivision.id);
      final users = await dataService.getUsers();
      
      List<ChatRoomWithCustomer> roomsWithDetails = [];
      
      for (final room in rooms) {
        final customer = users.firstWhere(
          (u) => u.id == room.customerId,
          orElse: () => users.first,
        );
        
        final messages = await dataService.getMessagesByRoom(room.id);
        final lastMessage = messages.isNotEmpty ? messages.last : null;
        final unreadCount = messages.where((m) => !m.isRead && m.senderId != null).length;
        
        roomsWithDetails.add(ChatRoomWithCustomer(
          room: room,
          customer: customer,
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

  List<ChatRoomWithCustomer> get _filteredRooms {
    if (_searchQuery.isEmpty) return _chatRooms;
    return _chatRooms.where((room) => 
      room.customer.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      appBar: AppAppBar(
        title: 'Chat Pelanggan',
        showBackButton: false,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat chat...')
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
              hintText: 'Cari pelanggan...',
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
        
        // Chat List
        Expanded(
          child: _filteredRooms.isEmpty
              ? EmptyState(
                  icon: Icons.chat_bubble_outline,
                  title: 'Belum ada chat',
                  subtitle: _searchQuery.isNotEmpty
                      ? 'Tidak ada chat yang cocok'
                      : 'Chat dari pelanggan akan muncul di sini',
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    itemCount: _filteredRooms.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
                    itemBuilder: (context, index) {
                      final roomData = _filteredRooms[index];
                      return _buildChatTile(roomData);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildChatTile(ChatRoomWithCustomer roomData) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.sm,
      ),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              roomData.customer.name.substring(0, 1).toUpperCase(),
              style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
            ),
          ),
          if (roomData.unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    roomData.unreadCount > 9 ? '9+' : '${roomData.unreadCount}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              roomData.customer.name,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: roomData.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
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
      subtitle: Text(
        roomData.lastMessage?.content ?? 'Mulai percakapan...',
        style: AppTextStyles.bodySmall.copyWith(
          color: roomData.unreadCount > 0
              ? AppColors.textPrimary
              : AppColors.textSecondary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        context.push(RouteNames.adminChatPath(roomData.room.id));
      },
    );
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

class ChatRoomWithCustomer {
  final ChatRoomModel room;
  final UserModel customer;
  final ChatMessageModel? lastMessage;
  final int unreadCount;

  ChatRoomWithCustomer({
    required this.room,
    required this.customer,
    this.lastMessage,
    required this.unreadCount,
  });
}