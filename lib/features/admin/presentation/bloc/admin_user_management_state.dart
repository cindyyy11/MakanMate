import 'package:equatable/equatable.dart';
import 'package:makan_mate/features/user/domain/entities/user_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/user_ban_entity.dart';

/// Base class for admin user management states
abstract class AdminUserManagementState extends Equatable {
  const AdminUserManagementState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AdminUserManagementInitial extends AdminUserManagementState {
  const AdminUserManagementInitial();
}

/// Loading state
class AdminUserManagementLoading extends AdminUserManagementState {
  const AdminUserManagementLoading();
}

/// Users loaded successfully
class UsersLoaded extends AdminUserManagementState {
  final List<UserEntity> users;

  const UsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

/// User loaded successfully
class UserLoaded extends AdminUserManagementState {
  final UserEntity user;

  const UserLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

/// User violation history loaded
class UserViolationHistoryLoaded extends AdminUserManagementState {
  final List<Map<String, dynamic>> violations;

  const UserViolationHistoryLoaded(this.violations);

  @override
  List<Object?> get props => [violations];
}

/// Operation success (verify, ban, warn, etc.)
class UserOperationSuccess extends AdminUserManagementState {
  final String message;

  const UserOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error state
class AdminUserManagementError extends AdminUserManagementState {
  final String message;

  const AdminUserManagementError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Bans and warnings loaded
class BansAndWarningsLoaded extends AdminUserManagementState {
  final List<UserBanEntity> bansAndWarnings;

  const BansAndWarningsLoaded(this.bansAndWarnings);

  @override
  List<Object?> get props => [bansAndWarnings];
}

/// Admin account created successfully
class AdminCreated extends AdminUserManagementState {
  final String adminId;

  const AdminCreated(this.adminId);

  @override
  List<Object?> get props => [adminId];
}


