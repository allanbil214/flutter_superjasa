import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_room_model.g.dart';

@JsonSerializable()
class ChatRoomModel extends Equatable {
  final int id;
  @JsonKey(name: 'customer_id')
  final int customerId;
  @JsonKey(name: 'division_id')
  final int divisionId;
  @JsonKey(name: 'last_message_at')
  final String? lastMessageAt;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const ChatRoomModel({
    required this.id,
    required this.customerId,
    required this.divisionId,
    this.lastMessageAt,
    required this.createdAt,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) => _$ChatRoomModelFromJson(json);
  Map<String, dynamic> toJson() => _$ChatRoomModelToJson(this);

  @override
  List<Object?> get props => [id, customerId, divisionId];
}