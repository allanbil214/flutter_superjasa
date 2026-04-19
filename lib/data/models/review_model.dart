import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_model.g.dart';

@JsonSerializable()
class ReviewModel extends Equatable {
  final int id;
  @JsonKey(name: 'order_id')
  final int orderId;
  @JsonKey(name: 'customer_id')
  final int customerId;
  @JsonKey(name: 'employee_id')
  final int? employeeId;
  @JsonKey(name: 'division_id')
  final int divisionId;
  final int rating;
  final String? comment;
  @JsonKey(name: 'is_published')
  final bool isPublished;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const ReviewModel({
    required this.id,
    required this.orderId,
    required this.customerId,
    this.employeeId,
    required this.divisionId,
    required this.rating,
    this.comment,
    required this.isPublished,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => _$ReviewModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);

  @override
  List<Object?> get props => [id, orderId, customerId, rating];
}