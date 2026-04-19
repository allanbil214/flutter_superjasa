import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'employee_documentation_model.g.dart';

enum DocumentationStage {
  @JsonValue('before')
  before,
  @JsonValue('during')
  during,
  @JsonValue('after')
  after,
}

@JsonSerializable()
class EmployeeDocumentationModel extends Equatable {
  final int id;
  @JsonKey(name: 'order_id')
  final int orderId;
  @JsonKey(name: 'employee_id')
  final int employeeId;
  final String title;
  final String? description;
  final DocumentationStage stage;
  final List<String> media;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const EmployeeDocumentationModel({
    required this.id,
    required this.orderId,
    required this.employeeId,
    required this.title,
    this.description,
    required this.stage,
    required this.media,
    required this.createdAt,
  });

  factory EmployeeDocumentationModel.fromJson(Map<String, dynamic> json) => _$EmployeeDocumentationModelFromJson(json);
  Map<String, dynamic> toJson() => _$EmployeeDocumentationModelToJson(this);

  String get displayStage {
    switch (stage) {
      case DocumentationStage.before:
        return 'Sebelum';
      case DocumentationStage.during:
        return 'Saat Pengerjaan';
      case DocumentationStage.after:
        return 'Setelah';
    }
  }

  @override
  List<Object?> get props => [id, orderId, employeeId, stage];
}