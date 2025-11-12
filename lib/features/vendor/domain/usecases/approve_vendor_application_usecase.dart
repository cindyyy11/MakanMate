import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/vendor/domain/repositories/vendor_repository.dart';

/// Use case for approving a vendor application (admin operation)
class ApproveVendorApplicationUseCase {
  final VendorRepository repository;

  ApproveVendorApplicationUseCase(this.repository);

  Future<Either<Failure, void>> call(ApproveVendorApplicationParams params) async {
    return await repository.approveVendorApplication(
      applicationId: params.applicationId,
      userId: params.userId,
    );
  }
}

/// Parameters for approving a vendor application
class ApproveVendorApplicationParams extends Equatable {
  final String applicationId;
  final String userId;

  const ApproveVendorApplicationParams({
    required this.applicationId,
    required this.userId,
  });

  @override
  List<Object> get props => [applicationId, userId];
}

