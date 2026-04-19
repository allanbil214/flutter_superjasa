// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRoomModel _$ChatRoomModelFromJson(Map<String, dynamic> json) =>
    ChatRoomModel(
      id: (json['id'] as num).toInt(),
      customerId: (json['customer_id'] as num).toInt(),
      divisionId: (json['division_id'] as num).toInt(),
      lastMessageAt: json['last_message_at'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$ChatRoomModelToJson(ChatRoomModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customerId,
      'division_id': instance.divisionId,
      'last_message_at': instance.lastMessageAt,
      'created_at': instance.createdAt,
    };
