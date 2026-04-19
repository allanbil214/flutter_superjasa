// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bot_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BotResponseModel _$BotResponseModelFromJson(Map<String, dynamic> json) =>
    BotResponseModel(
      id: (json['id'] as num).toInt(),
      divisionId: (json['division_id'] as num?)?.toInt(),
      keyword: json['keyword'] as String,
      response: json['response'] as String,
      sortOrder: (json['sort_order'] as num).toInt(),
      isActive: json['is_active'] as bool,
    );

Map<String, dynamic> _$BotResponseModelToJson(BotResponseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'division_id': instance.divisionId,
      'keyword': instance.keyword,
      'response': instance.response,
      'sort_order': instance.sortOrder,
      'is_active': instance.isActive,
    };
