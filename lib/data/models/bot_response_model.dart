import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bot_response_model.g.dart';

@JsonSerializable()
class BotResponseModel extends Equatable {
  final int id;
  @JsonKey(name: 'division_id')
  final int? divisionId;
  final String keyword;
  final String response;
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @JsonKey(name: 'is_active')
  final bool isActive;

  const BotResponseModel({
    required this.id,
    this.divisionId,
    required this.keyword,
    required this.response,
    required this.sortOrder,
    required this.isActive,
  });

  factory BotResponseModel.fromJson(Map<String, dynamic> json) => _$BotResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$BotResponseModelToJson(this);

  @override
  List<Object?> get props => [id, divisionId, keyword, sortOrder];
}