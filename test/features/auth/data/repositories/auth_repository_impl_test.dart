// import 'package:dartz/dartz.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// import 'package:makan_mate/core/errors/exceptions.dart';
// import 'package:makan_mate/core/errors/failures.dart';
// import 'package:makan_mate/core/network/network_info.dart';
// import 'package:makan_mate/features/auth/data/datasources/auth_local_datasource.dart';
// import 'package:makan_mate/features/auth/data/datasources/auth_remote_datasource.dart';
// import 'package:makan_mate/features/auth/data/models/user_model.dart';
// import 'package:makan_mate/features/auth/data/repositories/auth_repository_impl.dart';

// import 'auth_repository_impl_test.mocks.dart';

// @GenerateMocks([
//   AuthRemoteDataSource,
//   AuthLocalDataSource,
//   NetworkInfo,
// ])
// void main() {
//   late AuthRepositoryImpl repository;
//   late MockAuthRemoteDataSource mockRemoteDataSource;
//   late MockAuthLocalDataSource mockLocalDataSource;
//   late MockNetworkInfo mockNetworkInfo;

//   setUp(() {
//     mockRemoteDataSource = MockAuthRemoteDataSource();
//     mockLocalDataSource = MockAuthLocalDataSource();
//     mockNetworkInfo = MockNetworkInfo();
//     repository = AuthRepositoryImpl(
//       remoteDataSource: mockRemoteDataSource,
//       localDataSource: mockLocalDataSource,
//       networkInfo: mockNetworkInfo,
//     );
//   });

//   const tEmail = 'test@example.com';
//   const tPassword = 'password123';
//   const tUserModel = UserModel(
//     id: '1',
//     email: tEmail,
//     displayName: 'Test User',
//   );

//   group('signInWithEmailPassword', () {
//     test(
//       'should check if device is online',
//       () async {
//         // Arrange
//         when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
//         when(mockRemoteDataSource.signInWithEmailPassword(any, any))
//             .thenAnswer((_) async => tUserModel);
//         when(mockLocalDataSource.cacheUser(any)).thenAnswer((_) async => {});

//         // Act
//         await repository.signInWithEmailPassword(
//           email: tEmail,
//           password: tPassword,
//         );

//         // Assert
//         verify(mockNetworkInfo.isConnected);
//       },
//     );

//     test(
//       'should return NetworkFailure when device is offline',
//       () async {
//         // Arrange
//         when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

//         // Act
//         final result = await repository.signInWithEmailPassword(
//           email: tEmail,
//           password: tPassword,
//         );

//         // Assert
//         expect(result, equals(const Left(NetworkFailure('No internet connection'))));
//         verifyZeroInteractions(mockRemoteDataSource);
//       },
//     );

//     test(
//       'should return UserEntity when sign in succeeds',
//       () async {
//         // Arrange
//         when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
//         when(mockRemoteDataSource.signInWithEmailPassword(any, any))
//             .thenAnswer((_) async => tUserModel);
//         when(mockLocalDataSource.cacheUser(any)).thenAnswer((_) async => {});

//         // Act
//         final result = await repository.signInWithEmailPassword(
//           email: tEmail,
//           password: tPassword,
//         );

//         // Assert
//         expect(result, equals(const Right(tUserModel)));
//         verify(mockRemoteDataSource.signInWithEmailPassword(tEmail, tPassword));
//         verify(mockLocalDataSource.cacheUser(tUserModel));
//       },
//     );

//     test(
//       'should return AuthFailure when sign in fails',
//       () async {
//         // Arrange
//         when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
//         when(mockRemoteDataSource.signInWithEmailPassword(any, any))
//             .thenThrow(AuthException('Invalid credentials'));

//         // Act
//         final result = await repository.signInWithEmailPassword(
//           email: tEmail,
//           password: tPassword,
//         );

//         // Assert
//         expect(result, equals(const Left(AuthFailure('Invalid credentials'))));
//       },
//     );
//   });
// }