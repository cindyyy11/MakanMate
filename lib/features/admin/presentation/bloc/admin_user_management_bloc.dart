import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_user_repository.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_user_management_event.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_user_management_state.dart';

/// BLoC for admin user management
class AdminUserManagementBloc
    extends Bloc<AdminUserManagementEvent, AdminUserManagementState> {
  final AdminUserRepository repository;

  AdminUserManagementBloc({required this.repository})
    : super(const AdminUserManagementInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<LoadUserById>(_onLoadUserById);
    on<VerifyUser>(_onVerifyUser);
    on<BanUser>(_onBanUser);
    on<UnbanUser>(_onUnbanUser);
    on<WarnUser>(_onWarnUser);
    on<LoadUserViolationHistory>(_onLoadUserViolationHistory);
    on<DeleteUserData>(_onDeleteUserData);
    on<RefreshUsers>(_onRefreshUsers);
    on<LoadBansAndWarnings>(_onLoadBansAndWarnings);
    on<LiftBanOrWarning>(_onLiftBanOrWarning);
  }

  Future<void> _onLoadUsers(
    LoadUsers event,
    Emitter<AdminUserManagementState> emit,
  ) async {
    emit(const AdminUserManagementLoading());
    final result = await repository.getUsers(
      role: event.role,
      isVerified: event.isVerified,
      limit: event.limit,
    );
    result.fold(
      (failure) => emit(AdminUserManagementError(failure.message)),
      (users) => emit(UsersLoaded(users)),
    );
  }

  Future<void> _onLoadUserById(
    LoadUserById event,
    Emitter<AdminUserManagementState> emit,
  ) async {
    emit(const AdminUserManagementLoading());
    final result = await repository.getUserById(event.userId);
    result.fold((failure) => emit(AdminUserManagementError(failure.message)), (
      user,
    ) {
      if (user != null) {
        emit(UserLoaded(user));
      } else {
        emit(const AdminUserManagementError('User not found'));
      }
    });
  }

  Future<void> _onVerifyUser(
    VerifyUser event,
    Emitter<AdminUserManagementState> emit,
  ) async {
    emit(const AdminUserManagementLoading());
    final result = await repository.verifyUser(
      userId: event.userId,
      reason: event.reason,
    );
    result.fold((failure) => emit(AdminUserManagementError(failure.message)), (
      _,
    ) {
      emit(const UserOperationSuccess('User verified successfully'));
    });
  }

  Future<void> _onBanUser(
    BanUser event,
    Emitter<AdminUserManagementState> emit,
  ) async {
    emit(const AdminUserManagementLoading());
    final result = await repository.banUser(
      userId: event.userId,
      reason: event.reason,
      banUntil: event.banUntil,
    );
    result.fold((failure) => emit(AdminUserManagementError(failure.message)), (
      _,
    ) {
      emit(const UserOperationSuccess('User banned successfully'));
    });
  }

  Future<void> _onUnbanUser(
    UnbanUser event,
    Emitter<AdminUserManagementState> emit,
  ) async {
    emit(const AdminUserManagementLoading());
    final result = await repository.unbanUser(
      userId: event.userId,
      reason: event.reason,
    );
    result.fold((failure) => emit(AdminUserManagementError(failure.message)), (
      _,
    ) {
      emit(const UserOperationSuccess('User unbanned successfully'));
    });
  }

  Future<void> _onWarnUser(
    WarnUser event,
    Emitter<AdminUserManagementState> emit,
  ) async {
    emit(const AdminUserManagementLoading());
    final result = await repository.warnUser(
      userId: event.userId,
      reason: event.reason,
    );
    result.fold((failure) => emit(AdminUserManagementError(failure.message)), (
      _,
    ) {
      emit(const UserOperationSuccess('User warned successfully'));
    });
  }

  Future<void> _onLoadUserViolationHistory(
    LoadUserViolationHistory event,
    Emitter<AdminUserManagementState> emit,
  ) async {
    emit(const AdminUserManagementLoading());
    final result = await repository.getUserViolationHistory(event.userId);
    result.fold(
      (failure) => emit(AdminUserManagementError(failure.message)),
      (violations) => emit(UserViolationHistoryLoaded(violations)),
    );
  }

  Future<void> _onDeleteUserData(
    DeleteUserData event,
    Emitter<AdminUserManagementState> emit,
  ) async {
    emit(const AdminUserManagementLoading());
    final result = await repository.deleteUserData(
      userId: event.userId,
      reason: event.reason,
    );
    result.fold((failure) => emit(AdminUserManagementError(failure.message)), (
      _,
    ) {
      emit(const UserOperationSuccess('User data deleted successfully'));
    });
  }

  Future<void> _onRefreshUsers(
    RefreshUsers event,
    Emitter<AdminUserManagementState> emit,
  ) async {
    // Reload users with current filters
    // This assumes we keep track of last filters, but for simplicity,
    // we'll just reload all users
    add(const LoadUsers());
  }

  Future<void> _onLoadBansAndWarnings(
    LoadBansAndWarnings event,
    Emitter<AdminUserManagementState> emit,
  ) async {
    emit(const AdminUserManagementLoading());
    final result = await repository.getBansAndWarnings(
      type: event.type,
      isActive: event.isActive,
    );
    result.fold(
      (failure) => emit(AdminUserManagementError(failure.message)),
      (bansAndWarnings) => emit(BansAndWarningsLoaded(bansAndWarnings)),
    );
  }

  Future<void> _onLiftBanOrWarning(
    LiftBanOrWarning event,
    Emitter<AdminUserManagementState> emit,
  ) async {
    emit(const AdminUserManagementLoading());
    final result = await repository.liftBanOrWarning(
      banId: event.banId,
      reason: event.reason,
    );
    result.fold(
      (failure) => emit(AdminUserManagementError(failure.message)),
      (_) => emit(const UserOperationSuccess('Ban/Warning lifted successfully')),
    );
  }
}
