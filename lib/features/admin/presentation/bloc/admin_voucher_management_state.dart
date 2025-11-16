import 'package:equatable/equatable.dart';
import 'package:makan_mate/features/admin/data/datasources/admin_voucher_management_datasource.dart';

abstract class AdminVoucherManagementState extends Equatable {
  const AdminVoucherManagementState();

  @override
  List<Object?> get props => [];
}

class AdminVoucherManagementInitial extends AdminVoucherManagementState {
  const AdminVoucherManagementInitial();
}

class AdminVoucherManagementLoading extends AdminVoucherManagementState {
  const AdminVoucherManagementLoading();
}

class VouchersLoaded extends AdminVoucherManagementState {
  final List<PromotionWithVendorInfo> vouchers;

  const VouchersLoaded(this.vouchers);

  @override
  List<Object?> get props => [vouchers];
}

class AdminVoucherManagementError extends AdminVoucherManagementState {
  final String message;

  const AdminVoucherManagementError(this.message);

  @override
  List<Object?> get props => [message];
}

class VoucherOperationSuccess extends AdminVoucherManagementState {
  final String message;

  const VoucherOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

