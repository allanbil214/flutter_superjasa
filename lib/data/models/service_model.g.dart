// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceModel _$ServiceModelFromJson(Map<String, dynamic> json) => ServiceModel(
  id: (json['id'] as num).toInt(),
  divisionId: (json['division_id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  basePrice: (json['base_price'] as num).toDouble(),
  priceNote: json['price_note'] as String?,
  durationEst: json['duration_est'] as String?,
  isActive: json['is_active'] as bool,
);

Map<String, dynamic> _$ServiceModelToJson(ServiceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'division_id': instance.divisionId,
      'name': instance.name,
      'description': instance.description,
      'base_price': instance.basePrice,
      'price_note': instance.priceNote,
      'duration_est': instance.durationEst,
      'is_active': instance.isActive,
    };
