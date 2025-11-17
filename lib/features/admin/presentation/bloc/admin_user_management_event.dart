import 'package:equatable/equatable.dart';

/// Base class for admin user management events
abstract class AdminUserManagementEvent extends Equatable {
  const AdminUserManagementEvent();

  @override
  List<Object?> get props => [];
}

/// Load all users
class LoadUsers extends AdminUserManagementEvent {
  final String? role;
  final bool? isVerified;
  final int? limit;

  const LoadUsers({
    this.role,
    this.isVerified,
    this.limit,
  });

  @override
  List<Object?> get props => [role, isVerified, limit];
}

/// Load a specific user by ID
class LoadUserById extends AdminUserManagementEvent {
  final String userId;

  const LoadUserById(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Verify a user account
class VerifyUser extends AdminUserManagementEvent {
  final String userId;
  final String? reason;

  const VerifyUser({
    required this.userId,
    this.reason,
  });

  @override
  List<Object?> get props => [userId, reason];
}

/// Ban a user
class BanUser extends AdminUserManagementEvent {
  final String userId;
  final String reason;
  final DateTime? banUntil;

  const BanUser({
    required this.userId,
    required this.reason,
    this.banUntil,
  });

  @override
  List<Object?> get props => [userId, reason, banUntil];
}

/// Unban a user
class UnbanUser extends AdminUserManagementEvent {
  final String userId;
  final String? reason;

  const UnbanUser({
    required this.userId,
    this.reason,
  });

  @override
  List<Object?> get props => [userId, reason];
}

/// Warn a user
class WarnUser extends AdminUserManagementEvent {
  final String userId;
  final String reason;

  const WarnUser({
    required this.userId,
    required this.reason,
  });

  @override
  List<Object?> get props => [userId, reason];
}

/// Load user violation history
class LoadUserViolationHistory extends AdminUserManagementEvent {
  final String userId;

  const LoadUserViolationHistory(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Delete user data (PDPA)
class DeleteUserData extends AdminUserManagementEvent {
  final String userId;
  final String reason;

  const DeleteUserData({
    required this.userId,
    required this.reason,
  });

  @override
  List<Object?> get props => [userId, reason];
}

/// Refresh users list
class RefreshUsers extends AdminUserManagementEvent {
  const RefreshUsers();
}

/// Load all bans and warnings
class LoadBansAndWarnings extends AdminUserManagementEvent {
  final String? type; // 'ban' or 'warning' or null for all
  final bool? isActive; // true for active, false for expired, null for all
  
  const LoadBansAndWarnings({
    this.type,
    this.isActive,
  });
  
  @override
  List<Object?> get props => [type, isActive];
}

/// Lift a ban or remove a warning
class LiftBanOrWarning extends AdminUserManagementEvent {
  final String banId;
  final String reason;
  
  const LiftBanOrWarning({
    required this.banId,
    required this.reason,
  });
  
  @override
  List<Object?> get props => [banId, reason];
}

/// Create a new admin account
class CreateAdminRequested extends AdminUserManagementEvent {
  final String email;
  final String password;
  final String displayName;

  const CreateAdminRequested({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}


