// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessageModel _$ChatMessageModelFromJson(Map<String, dynamic> json) =>
    ChatMessageModel(
      id: (json['id'] as num).toInt(),
      roomId: (json['room_id'] as num).toInt(),
      senderId: (json['sender_id'] as num?)?.toInt(),
      orderId: (json['order_id'] as num?)?.toInt(),
      type: $enumDecode(_$MessageTypeEnumMap, json['type']),
      content: json['content'] as String?,
      attachment: json['attachment'] as String?,
      isRead: json['is_read'] as bool,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$ChatMessageModelToJson(ChatMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'room_id': instance.roomId,
      'sender_id': instance.senderId,
      'order_id': instance.orderId,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'content': instance.content,
      'attachment': instance.attachment,
      'is_read': instance.isRead,
      'created_at': instance.createdAt,
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.orderCard: 'order_card',
  MessageType.bot: 'bot',
  MessageType.template: 'template',
};
