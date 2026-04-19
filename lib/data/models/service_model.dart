import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'service_model.g.dart';

@JsonSerializable()
class ServiceModel extends Equatable {
  final int id;
  @JsonKey(name: 'division_id')
  final int divisionId;
  final String name;
  final String? description;
  @JsonKey(name: 'base_price')
  final double basePrice;
  @JsonKey(name: 'price_note')
  final String? priceNote;
  @JsonKey(name: 'duration_est')
  final String? durationEst;
  @JsonKey(name: 'is_active')
  final bool isActive;

  const ServiceModel({
    required this.id,
    required this.divisionId,
    required this.name,
    this.description,
    required this.basePrice,
    this.priceNote,
    this.durationEst,
    required this.isActive,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) => _$ServiceModelFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceModelToJson(this);

  String get formattedPrice {
    return 'Rp ${basePrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  List<Object?> get props => [id, divisionId, name, basePrice, isActive];
}