import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'division_model.g.dart';

@JsonSerializable()
class DivisionModel extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? icon;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'admin_ids')
  final List<int> adminIds;
  @JsonKey(name: 'employee_ids')
  final List<int> employeeIds;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const DivisionModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.icon,
    required this.isActive,
    required this.adminIds,
    required this.employeeIds,
    required this.createdAt,
  });

  factory DivisionModel.fromJson(Map<String, dynamic> json) => _$DivisionModelFromJson(json);
  Map<String, dynamic> toJson() => _$DivisionModelToJson(this);

  @override
  List<Object?> get props => [id, name, slug, isActive];
}