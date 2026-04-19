// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  avatar: json['avatar'] as String?,
  address: json['address'] as String?,
  isActive: json['is_active'] as bool,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'role': _$UserRoleEnumMap[instance.role]!,
  'avatar': instance.avatar,
  'address': instance.address,
  'is_active': instance.isActive,
  'created_at': instance.createdAt,
};

const _$UserRoleEnumMap = {
  UserRole.customer: 'customer',
  UserRole.employee: 'employee',
  UserRole.admin: 'admin',
  UserRole.superAdmin: 'super_admin',
};
