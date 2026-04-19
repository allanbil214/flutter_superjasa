// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentModel _$PaymentModelFromJson(Map<String, dynamic> json) => PaymentModel(
  id: (json['id'] as num).toInt(),
  orderId: (json['order_id'] as num).toInt(),
  amount: (json['amount'] as num).toDouble(),
  paymentMethod: $enumDecode(_$PaymentMethodEnumMap, json['payment_method']),
  paymentChannel: json['payment_channel'] as String?,
  status: $enumDecode(_$PaymentStatusEnumMap, json['status']),
  proofImage: json['proof_image'] as String?,
  customerNote: json['customer_note'] as String?,
  adminNote: json['admin_note'] as String?,
  verifiedBy: (json['verified_by'] as num?)?.toInt(),
  verifiedAt: json['verified_at'] as String?,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$PaymentModelToJson(PaymentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.orderId,
      'amount': instance.amount,
      'payment_method': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'payment_channel': instance.paymentChannel,
      'status': _$PaymentStatusEnumMap[instance.status]!,
      'proof_image': instance.proofImage,
      'customer_note': instance.customerNote,
      'admin_note': instance.adminNote,
      'verified_by': instance.verifiedBy,
      'verified_at': instance.verifiedAt,
      'created_at': instance.createdAt,
    };

const _$PaymentMethodEnumMap = {
  PaymentMethod.transferBank: 'transfer_bank',
  PaymentMethod.eWallet: 'e_wallet',
  PaymentMethod.cash: 'cash',
  PaymentMethod.other: 'other',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.uploaded: 'uploaded',
  PaymentStatus.verified: 'verified',
  PaymentStatus.rejected: 'rejected',
};
