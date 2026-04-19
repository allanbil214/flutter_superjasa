// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_template_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatTemplateModel _$ChatTemplateModelFromJson(Map<String, dynamic> json) =>
    ChatTemplateModel(
      id: (json['id'] as num).toInt(),
      divisionId: (json['division_id'] as num?)?.toInt(),
      forRole: $enumDecode(_$TemplateForRoleEnumMap, json['for_role']),
      label: json['label'] as String,
      content: json['content'] as String,
      sortOrder: (json['sort_order'] as num).toInt(),
      isActive: json['is_active'] as bool,
    );

Map<String, dynamic> _$ChatTemplateModelToJson(ChatTemplateModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'division_id': instance.divisionId,
      'for_role': _$TemplateForRoleEnumMap[instance.forRole]!,
      'label': instance.label,
      'content': instance.content,
      'sort_order': instance.sortOrder,
      'is_active': instance.isActive,
    };

const _$TemplateForRoleEnumMap = {
  TemplateForRole.customer: 'customer',
  TemplateForRole.admin: 'admin',
  TemplateForRole.employee: 'employee',
};
