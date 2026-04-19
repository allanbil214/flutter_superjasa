import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_model.g.dart';

enum PaymentMethod {
  @JsonValue('transfer_bank')
  transferBank,
  @JsonValue('e_wallet')
  eWallet,
  @JsonValue('cash')
  cash,
  @JsonValue('other')
  other,
}

enum PaymentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('uploaded')
  uploaded,
  @JsonValue('verified')
  verified,
  @JsonValue('rejected')
  rejected,
}

@JsonSerializable()
class PaymentModel extends Equatable {
  final int id;
  @JsonKey(name: 'order_id')
  final int orderId;
  final double amount;
  @JsonKey(name: 'payment_method')
  final PaymentMethod paymentMethod;
  @JsonKey(name: 'payment_channel')
  final String? paymentChannel;
  final PaymentStatus status;
  @JsonKey(name: 'proof_image')
  final String? proofImage;
  @JsonKey(name: 'customer_note')
  final String? customerNote;
  @JsonKey(name: 'admin_note')
  final String? adminNote;
  @JsonKey(name: 'verified_by')
  final int? verifiedBy;
  @JsonKey(name: 'verified_at')
  final String? verifiedAt;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const PaymentModel({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    this.paymentChannel,
    required this.status,
    this.proofImage,
    this.customerNote,
    this.adminNote,
    this.verifiedBy,
    this.verifiedAt,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => _$PaymentModelFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);

  String get displayMethod {
    switch (paymentMethod) {
      case PaymentMethod.transferBank:
        return 'Transfer Bank';
      case PaymentMethod.eWallet:
        return 'E-Wallet';
      case PaymentMethod.cash:
        return 'Tunai';
      case PaymentMethod.other:
        return 'Lainnya';
    }
  }

  String get displayStatus {
    switch (status) {
      case PaymentStatus.pending:
        return 'Menunggu';
      case PaymentStatus.uploaded:
        return 'Menunggu Verifikasi';
      case PaymentStatus.verified:
        return 'Terverifikasi';
      case PaymentStatus.rejected:
        return 'Ditolak';
    }
  }

  String get formattedAmount {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  List<Object?> get props => [id, orderId, amount, status];
}