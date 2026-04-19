// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewModel _$ReviewModelFromJson(Map<String, dynamic> json) => ReviewModel(
  id: (json['id'] as num).toInt(),
  orderId: (json['order_id'] as num).toInt(),
  customerId: (json['customer_id'] as num).toInt(),
  employeeId: (json['employee_id'] as num?)?.toInt(),
  divisionId: (json['division_id'] as num).toInt(),
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String?,
  isPublished: json['is_published'] as bool,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$ReviewModelToJson(ReviewModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.orderId,
      'customer_id': instance.customerId,
      'employee_id': instance.employeeId,
      'division_id': instance.divisionId,
      'rating': instance.rating,
      'comment': instance.comment,
      'is_published': instance.isPublished,
      'created_at': instance.createdAt,
    };
