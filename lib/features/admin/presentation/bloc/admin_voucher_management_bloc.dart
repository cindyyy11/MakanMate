import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_pending_vouchers_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/approve_voucher_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/reject_voucher_usecase.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_voucher_management_event.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_voucher_management_state.dart';

class AdminVoucherManagementBloc
    extends Bloc<AdminVoucherManagementEvent, AdminVoucherManagementState> {
  final GetPendingVouchersUseCase getPendingVouchersUseCase;
  final ApproveVoucherUseCase approveVoucherUseCase;
  final RejectVoucherUseCase rejectVoucherUseCase;

  AdminVoucherManagementBloc({
    required this.getPendingVouchersUseCase,
    required this.approveVoucherUseCase,
    required this.rejectVoucherUseCase,
  }) : super(const AdminVoucherManagementInitial()) {
    on<LoadPendingVouchers>(_onLoadPendingVouchers);
    on<ApproveVoucher>(_onApproveVoucher);
    on<RejectVoucher>(_onRejectVoucher);
    on<RefreshVouchers>(_onRefreshVouchers);
  }

  Future<void> _onLoadPendingVouchers(
    LoadPendingVouchers event,
    Emitter<AdminVoucherManagementState> emit,
  ) async {
    emit(const AdminVoucherManagementLoading());
    final result = await getPendingVouchersUseCase();
    result.fold(
      (failure) => emit(AdminVoucherManagementError(failure.message)),
      (vouchers) => emit(VouchersLoaded(vouchers)),
    );
  }

  Future<void> _onApproveVoucher(
    ApproveVoucher event,
    Emitter<AdminVoucherManagementState> emit,
  ) async {
    final result = await approveVoucherUseCase(
      ApproveVoucherParams(
        vendorId: event.vendorId,
        voucherId: event.voucherId,
        reason: event.reason,
      ),
    );
    result.fold(
      (failure) => emit(AdminVoucherManagementError(failure.message)),
      (_) {
        emit(VoucherOperationSuccess('Voucher approved successfully'));
        // Reload vouchers after approval
        add(const LoadPendingVouchers());
      },
    );
  }

  Future<void> _onRejectVoucher(
    RejectVoucher event,
    Emitter<AdminVoucherManagementState> emit,
  ) async {
    final result = await rejectVoucherUseCase(
      RejectVoucherParams(
        vendorId: event.vendorId,
        voucherId: event.voucherId,
        reason: event.reason,
      ),
    );
    result.fold(
      (failure) => emit(AdminVoucherManagementError(failure.message)),
      (_) {
        emit(VoucherOperationSuccess('Voucher rejected'));
        // Reload vouchers after rejection
        add(const LoadPendingVouchers());
      },
    );
  }

  Future<void> _onRefreshVouchers(
    RefreshVouchers event,
    Emitter<AdminVoucherManagementState> emit,
  ) async {
    add(const LoadPendingVouchers());
  }
}

