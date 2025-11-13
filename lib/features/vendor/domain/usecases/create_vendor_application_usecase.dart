// import 'package:dartz/dartz.dart';
// import 'package:equatable/equatable.dart';
// import 'package:makan_mate/core/errors/failures.dart';
// import 'package:makan_mate/features/vendor/domain/entities/vendor_application_entity.dart';
// import 'package:makan_mate/features/vendor/domain/repositories/vendor_repository.dart';
//
// /// Use case for creating a vendor application
// class CreateVendorApplicationUseCase {
//   final VendorRepository repository;
//
//   CreateVendorApplicationUseCase(this.repository);
//
//   Future<Either<Failure, VendorApplicationEntity>> call(
//     CreateVendorApplicationParams params,
//   ) async {
//     return await repository.createVendorApplication(
//       userId: params.userId,
//       userName: params.userName,
//       email: params.email,
//       businessName: params.businessName,
//       businessType: params.businessType,
//       businessDescription: params.businessDescription,
//       phoneNumber: params.phoneNumber,
//       address: params.address,
//       additionalData: params.additionalData,
//     );
//   }
// }
//
// /// Parameters for creating a vendor application
// class CreateVendorApplicationParams extends Equatable {
//   final String userId;
//   final String userName;
//   final String email;
//   final String businessName;
//   final String businessType;
//   final String? businessDescription;
//   final String? phoneNumber;
//   final String? address;
//   final Map<String, dynamic>? additionalData;
//
//   const CreateVendorApplicationParams({
//     required this.userId,
//     required this.userName,
//     required this.email,
//     required this.businessName,
//     required this.businessType,
//     this.businessDescription,
//     this.phoneNumber,
//     this.address,
//     this.additionalData,
//   });
//
//   @override
//   List<Object?> get props => [
//     userId,
//     userName,
//     email,
//     businessName,
//     businessType,
//     businessDescription,
//     phoneNumber,
//     address,
//     additionalData,
//   ];
// }
