import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/chat_bubble.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../providers/app_state.dart';
import '../../../../data/services/mock_data_service.dart';
import '../../../../data/models/chat_message_model.dart';
import '../../../../data/models/chat_room_model.dart';
import '../../../../data/models/division_model.dart';
import '../../../../data/models/chat_template_model.dart';
import '../../../../data/models/bot_response_model.dart';

class CustomerChatScreen extends StatefulWidget {
  final int roomId;

  const CustomerChatScreen({
    super.key,
    required this.roomId,
  });

  @override
  State<CustomerChatScreen> createState() => _CustomerChatScreenState();
}

class _CustomerChatScreenState extends State<CustomerChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  ChatRoomModel? _room;
  DivisionModel? _division;
  List<ChatMessageModel> _messages = [];
  List<ChatTemplateModel> _templates = [];
  List<BotResponseModel> _botResponses = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final dataService = MockDataService();
      
      final rooms = await dataService.getChatRooms();
      _room = rooms.firstWhere((r) => r.id == widget.roomId);
      
      _division = await dataService.getDivisionById(_room!.divisionId);
      _messages = await dataService.getMessagesByRoom(widget.roomId);
      _templates = await dataService.getTemplates(
        forRole: TemplateForRole.customer,
        divisionId: _division?.id,
      );
      _botResponses = await dataService.getBotResponses();
      
      _scrollToBottom();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    return Scaffold(
      appBar: AppAppBar(
        title: _division?.name ?? 'Chat',
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined),
            onPressed: () {
              // TODO: Call admin
            },
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat pesan...')
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return ChatBubble(
                        message: _messages[index],
                        currentUser: appState.currentUser,
                      );
                    },
                  ),
                ),
                _buildMessageInput(),
              ],
            ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.message_outlined),
              onPressed: _showTemplateSheet,
              tooltip: 'Template Pesan',
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Ketik pesan...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
                onPressed: _isSending ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTemplateSheet() {
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
                      'Template Pesan',
                      style: AppTextStyles.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _templates.length,
                  itemBuilder: (context, index) {
                    final template = _templates[index];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.message_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(template.label),
                      subtitle: Text(
                        template.content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _messageController.text = template.content;
                        _sendMessage();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() => _isSending = true);

    final appState = Provider.of<AppState>(context, listen: false);
    
    // Add user message
    final userMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch,
      roomId: widget.roomId,
      senderId: appState.currentUserId,
      orderId: null,
      type: MessageType.text,
      content: message,
      attachment: null,
      isRead: true,
      createdAt: DateTime.now().toIso8601String(),
    );

    setState(() {
      _messages.add(userMessage);
      _messageController.clear();
    });

    _scrollToBottom();

    // Check for bot response
    final botResponse = await MockDataService().findBotResponse(
      message,
      divisionId: _division?.id,
    );

    if (botResponse != null) {
      await Future.delayed(const Duration(seconds: 1));
      
      final botMessage = ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch + 1,
        roomId: widget.roomId,
        senderId: null,
        orderId: null,
        type: MessageType.bot,
        content: botResponse.response,
        attachment: null,
        isRead: true,
        createdAt: DateTime.now().toIso8601String(),
      );

      setState(() {
        _messages.add(botMessage);
      });
      
      _scrollToBottom();
    }

    setState(() => _isSending = false);
  }
}