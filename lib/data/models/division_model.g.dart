// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'division_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DivisionModel _$DivisionModelFromJson(Map<String, dynamic> json) =>
    DivisionModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      isActive: json['is_active'] as bool,
      adminIds: (json['admin_ids'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      employeeIds: (json['employee_ids'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$DivisionModelToJson(DivisionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'icon': instance.icon,
      'is_active': instance.isActive,
      'admin_ids': instance.adminIds,
      'employee_ids': instance.employeeIds,
      'created_at': instance.createdAt,
    };
