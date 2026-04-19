import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

enum OrderStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('assigned')
  assigned,
  @JsonValue('on_the_way')
  onTheWay,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('done')
  done,
  @JsonValue('reviewed')
  reviewed,
  @JsonValue('cancelled')
  cancelled;

  String get displayStatus {
    switch (this) {
      case OrderStatus.pending:    return 'Menunggu';
      case OrderStatus.confirmed:  return 'Dikonfirmasi';
      case OrderStatus.assigned:   return 'Ditugaskan';
      case OrderStatus.onTheWay:   return 'Dalam Perjalanan';
      case OrderStatus.inProgress: return 'Sedang Dikerjakan';
      case OrderStatus.done:       return 'Selesai';
      case OrderStatus.reviewed:   return 'Sudah Diulas';
      case OrderStatus.cancelled:  return 'Dibatalkan';
    }
  }
}

@JsonSerializable()
class OrderModel extends Equatable {
  final int id;
  @JsonKey(name: 'order_code')
  final String orderCode;
  @JsonKey(name: 'customer_id')
  final int customerId;
  @JsonKey(name: 'service_id')
  final int serviceId;
  @JsonKey(name: 'division_id')
  final int divisionId;
  @JsonKey(name: 'assigned_to')
  final int? assignedTo;
  final OrderStatus status;
  final String address;
  final String? notes;
  @JsonKey(name: 'scheduled_at')
  final String? scheduledAt;
  @JsonKey(name: 'confirmed_at')
  final String? confirmedAt;
  @JsonKey(name: 'assigned_at')
  final String? assignedAt;
  @JsonKey(name: 'on_the_way_at')
  final String? onTheWayAt;
  @JsonKey(name: 'in_progress_at')
  final String? inProgressAt;
  @JsonKey(name: 'done_at')
  final String? doneAt;
  @JsonKey(name: 'cancelled_at')
  final String? cancelledAt;
  @JsonKey(name: 'cancel_reason')
  final String? cancelReason;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const OrderModel({
    required this.id,
    required this.orderCode,
    required this.customerId,
    required this.serviceId,
    required this.divisionId,
    this.assignedTo,
    required this.status,
    required this.address,
    this.notes,
    this.scheduledAt,
    this.confirmedAt,
    this.assignedAt,
    this.onTheWayAt,
    this.inProgressAt,
    this.doneAt,
    this.cancelledAt,
    this.cancelReason,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  String get displayStatus => status.displayStatus;

  int get statusIndex {
    switch (status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.assigned:
        return 2;
      case OrderStatus.onTheWay:
        return 3;
      case OrderStatus.inProgress:
        return 4;
      case OrderStatus.done:
        return 5;
      case OrderStatus.reviewed:
        return 6;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  bool get isCompleted => status == OrderStatus.done || status == OrderStatus.reviewed;
  bool get isCancelled => status == OrderStatus.cancelled;
  bool get isActive => !isCompleted && !isCancelled;

  @override
  List<Object?> get props => [id, orderCode, customerId, status];
}