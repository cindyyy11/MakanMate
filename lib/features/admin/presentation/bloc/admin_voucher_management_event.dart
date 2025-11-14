import 'package:equatable/equatable.dart';

abstract class AdminVoucherManagementEvent extends Equatable {
  const AdminVoucherManagementEvent();

  @override
  List<Object?> get props => [];
}

class LoadPendingVouchers extends AdminVoucherManagementEvent {
  const LoadPendingVouchers();
}

class ApproveVoucher extends AdminVoucherManagementEvent {
  final String vendorId;
  final String voucherId;
  final String? reason;

  const ApproveVoucher({
    required this.vendorId,
    required this.voucherId,
    this.reason,
  });

  @override
  List<Object?> get props => [vendorId, voucherId, reason];
}

class RejectVoucher extends AdminVoucherManagementEvent {
  final String vendorId;
  final String voucherId;
  final String reason;

  const RejectVoucher({
    required this.vendorId,
    required this.voucherId,
    required this.reason,
  });

  @override
  List<Object?> get props => [vendorId, voucherId, reason];
}

class RefreshVouchers extends AdminVoucherManagementEvent {
  const RefreshVouchers();
}

