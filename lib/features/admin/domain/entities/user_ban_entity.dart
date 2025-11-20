import 'package:equatable/equatable.dart';

/// Entity representing a user ban or warning
class UserBanEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? userEmail;
  final String? userProfileImageUrl;
  final String type; // 'ban' or 'warning'
  final String reason;
  final String? details;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isActive;
  final String adminId;
  final String? adminName;
  
  const UserBanEntity({
    required this.id,
    required this.userId,
    required this.userName,
    this.userEmail,
    this.userProfileImageUrl,
    required this.type,
    required this.reason,
    this.details,
    required this.createdAt,
    this.expiresAt,
    required this.isActive,
    required this.adminId,
    this.adminName,
  });
  
  bool get isPermanent => expiresAt == null;
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isBan => type == 'ban';
  bool get isWarning => type == 'warning';
  
  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    userEmail,
    userProfileImageUrl,
    type,
    reason,
    details,
    createdAt,
    expiresAt,
    isActive,
    adminId,
    adminName,
  ];
}






