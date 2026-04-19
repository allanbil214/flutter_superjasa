import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_message_model.g.dart';

enum MessageType {
  @JsonValue('text')
  text,
  @JsonValue('image')
  image,
  @JsonValue('order_card')
  orderCard,
  @JsonValue('bot')
  bot,
  @JsonValue('template')
  template,
}

@JsonSerializable()
class ChatMessageModel extends Equatable {
  final int id;
  @JsonKey(name: 'room_id')
  final int roomId;
  @JsonKey(name: 'sender_id')
  final int? senderId;
  @JsonKey(name: 'order_id')
  final int? orderId;
  final MessageType type;
  final String? content;
  final String? attachment;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const ChatMessageModel({
    required this.id,
    required this.roomId,
    this.senderId,
    this.orderId,
    required this.type,
    this.content,
    this.attachment,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => _$ChatMessageModelFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageModelToJson(this);

  bool get isFromBot => senderId == null;
  bool get isOrderCard => type == MessageType.orderCard;

  @override
  List<Object?> get props => [id, roomId, senderId, type, createdAt];
}