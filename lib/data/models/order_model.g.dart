// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  id: (json['id'] as num).toInt(),
  orderCode: json['order_code'] as String,
  customerId: (json['customer_id'] as num).toInt(),
  serviceId: (json['service_id'] as num).toInt(),
  divisionId: (json['division_id'] as num).toInt(),
  assignedTo: (json['assigned_to'] as num?)?.toInt(),
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  address: json['address'] as String,
  notes: json['notes'] as String?,
  scheduledAt: json['scheduled_at'] as String?,
  confirmedAt: json['confirmed_at'] as String?,
  assignedAt: json['assigned_at'] as String?,
  onTheWayAt: json['on_the_way_at'] as String?,
  inProgressAt: json['in_progress_at'] as String?,
  doneAt: json['done_at'] as String?,
  cancelledAt: json['cancelled_at'] as String?,
  cancelReason: json['cancel_reason'] as String?,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_code': instance.orderCode,
      'customer_id': instance.customerId,
      'service_id': instance.serviceId,
      'division_id': instance.divisionId,
      'assigned_to': instance.assignedTo,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'address': instance.address,
      'notes': instance.notes,
      'scheduled_at': instance.scheduledAt,
      'confirmed_at': instance.confirmedAt,
      'assigned_at': instance.assignedAt,
      'on_the_way_at': instance.onTheWayAt,
      'in_progress_at': instance.inProgressAt,
      'done_at': instance.doneAt,
      'cancelled_at': instance.cancelledAt,
      'cancel_reason': instance.cancelReason,
      'created_at': instance.createdAt,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.confirmed: 'confirmed',
  OrderStatus.assigned: 'assigned',
  OrderStatus.onTheWay: 'on_the_way',
  OrderStatus.inProgress: 'in_progress',
  OrderStatus.done: 'done',
  OrderStatus.reviewed: 'reviewed',
  OrderStatus.cancelled: 'cancelled',
};
