import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

enum UserRole {
  @JsonValue('customer')
  customer,
  @JsonValue('employee')
  employee,
  @JsonValue('admin')
  admin,
  @JsonValue('super_admin')
  superAdmin,
}

@JsonSerializable()
class UserModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;
  final String? avatar;
  final String? address;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.avatar,
    this.address,
    required this.isActive,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  String get displayRole {
    switch (role) {
      case UserRole.customer:
        return 'Pelanggan';
      case UserRole.employee:
        return 'Teknisi';
      case UserRole.admin:
        return 'Admin';
      case UserRole.superAdmin:
        return 'Super Admin';
    }
  }

  @override
  List<Object?> get props => [id, name, email, role, isActive];
}