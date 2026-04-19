import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_item_model.g.dart';

@JsonSerializable()
class OrderItemModel extends Equatable {
  final int id;
  @JsonKey(name: 'order_id')
  final int orderId;
  @JsonKey(name: 'service_id')
  final int serviceId;
  final int qty;
  final double price;
  final double subtotal;
  final String? note;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.serviceId,
    required this.qty,
    required this.price,
    required this.subtotal,
    this.note,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => _$OrderItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);

  @override
  List<Object?> get props => [id, orderId, serviceId, qty, subtotal];
}