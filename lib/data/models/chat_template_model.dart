import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_template_model.g.dart';

enum TemplateForRole {
  @JsonValue('customer')
  customer,
  @JsonValue('admin')
  admin,
  @JsonValue('employee')
  employee,
}

@JsonSerializable()
class ChatTemplateModel extends Equatable {
  final int id;
  @JsonKey(name: 'division_id')
  final int? divisionId;
  @JsonKey(name: 'for_role')
  final TemplateForRole forRole;
  final String label;
  final String content;
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @JsonKey(name: 'is_active')
  final bool isActive;

  const ChatTemplateModel({
    required this.id,
    this.divisionId,
    required this.forRole,
    required this.label,
    required this.content,
    required this.sortOrder,
    required this.isActive,
  });

  factory ChatTemplateModel.fromJson(Map<String, dynamic> json) => _$ChatTemplateModelFromJson(json);
  Map<String, dynamic> toJson() => _$ChatTemplateModelToJson(this);

  @override
  List<Object?> get props => [id, divisionId, forRole, label, sortOrder];
}