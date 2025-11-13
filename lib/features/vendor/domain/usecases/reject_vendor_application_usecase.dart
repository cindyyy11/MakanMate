// import 'package:dartz/dartz.dart';
// import 'package:equatable/equatable.dart';
// import 'package:makan_mate/core/errors/failures.dart';
// import 'package:makan_mate/features/vendor/domain/repositories/vendor_repository.dart';
//
// /// Use case for rejecting a vendor application (admin operation)
// class RejectVendorApplicationUseCase {
//   final VendorRepository repository;
//
//   RejectVendorApplicationUseCase(this.repository);
//
//   Future<Either<Failure, void>> call(RejectVendorApplicationParams params) async {
//     return await repository.rejectVendorApplication(
//       applicationId: params.applicationId,
//       reason: params.reason,
//     );
//   }
// }
//
// /// Parameters for rejecting a vendor application
// class RejectVendorApplicationParams extends Equatable {
//   final String applicationId;
//   final String reason;
//
//   const RejectVendorApplicationParams({
//     required this.applicationId,
//     required this.reason,
//   });
//
//   @override
//   List<Object> get props => [applicationId, reason];
// }
//
