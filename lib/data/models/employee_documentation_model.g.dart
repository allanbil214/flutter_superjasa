// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_documentation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployeeDocumentationModel _$EmployeeDocumentationModelFromJson(
  Map<String, dynamic> json,
) => EmployeeDocumentationModel(
  id: (json['id'] as num).toInt(),
  orderId: (json['order_id'] as num).toInt(),
  employeeId: (json['employee_id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String?,
  stage: $enumDecode(_$DocumentationStageEnumMap, json['stage']),
  media: (json['media'] as List<dynamic>).map((e) => e as String).toList(),
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$EmployeeDocumentationModelToJson(
  EmployeeDocumentationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'order_id': instance.orderId,
  'employee_id': instance.employeeId,
  'title': instance.title,
  'description': instance.description,
  'stage': _$DocumentationStageEnumMap[instance.stage]!,
  'media': instance.media,
  'created_at': instance.createdAt,
};

const _$DocumentationStageEnumMap = {
  DocumentationStage.before: 'before',
  DocumentationStage.during: 'during',
  DocumentationStage.after: 'after',
};
