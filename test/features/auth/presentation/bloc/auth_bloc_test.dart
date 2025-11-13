// import 'package:bloc_test/bloc_test.dart';
// import 'package:dartz/dartz.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// import 'package:makan_mate/core/errors/failures.dart';
// import 'package:makan_mate/features/auth/domain/entities/user_entity.dart';
// import 'package:makan_mate/features/auth/domain/usecases/sign_in_usecase.dart';
// import 'package:makan_mate/features/auth/domain/usecases/sign_up_usecase.dart';
// import 'package:makan_mate/features/auth/domain/usecases/sign_out_usecase.dart';
// import 'package:makan_mate/features/auth/domain/usecases/google_sign_in_usecase.dart';
// import 'package:makan_mate/features/auth/presentation/bloc/auth_bloc.dart';
// import 'package:makan_mate/features/auth/presentation/bloc/auth_event.dart';
// import 'package:makan_mate/features/auth/presentation/bloc/auth_state.dart';

// import 'auth_bloc_test.mocks.dart';


// @GenerateMocks([
//   SignInUseCase,
//   SignUpUseCase,
//   SignOutUseCase,
//   GoogleSignInUseCase,
// ])
// void main() {
//   late AuthBloc authBloc;
//   late MockSignInUseCase mockSignInUseCase;
//   late MockSignUpUseCase mockSignUpUseCase;
//   late MockSignOutUseCase mockSignOutUseCase;
//   late MockGoogleSignInUseCase mockGoogleSignInUseCase;

//   setUp(() {
//     mockSignInUseCase = MockSignInUseCase();
//     mockSignUpUseCase = MockSignUpUseCase();
//     mockSignOutUseCase = MockSignOutUseCase();
//     mockGoogleSignInUseCase = MockGoogleSignInUseCase();

//     authBloc = AuthBloc(
//       signIn: mockSignInUseCase,
//       signUp: mockSignUpUseCase,
//       signOut: mockSignOutUseCase,
//       googleSignIn: mockGoogleSignInUseCase,
//     );
//   });

//   tearDown(() {
//     authBloc.close();
//   });

//   const tUser = UserEntity(
//     id: '1',
//     email: 'test@example.com',
//     displayName: 'Test User',
//   );

//   const tEmail = 'test@example.com';
//   const tPassword = 'password123';

//   group('SignInRequested', () {
//     blocTest<AuthBloc, AuthState>(
//       'should emit [AuthLoading, Authenticated] when sign in succeeds',
//       build: () {
//         when(mockSignInUseCase(email: anyNamed('email'), password: anyNamed('password')))
//             .thenAnswer((_) async => const Right(tUser));
//         return authBloc;
//       },
//       act: (bloc) => bloc.add(const SignInRequested(
//         email: tEmail,
//         password: tPassword,
//       )),
//       expect: () => [
//         AuthLoading(),
//         const Authenticated(tUser),
//       ],
//       verify: (_) {
//         verify(mockSignInUseCase(email: tEmail, password: tPassword));
//       },
//     );

//     blocTest<AuthBloc, AuthState>(
//       'should emit [AuthLoading, AuthError] when sign in fails',
//       build: () {
//         when(mockSignInUseCase(email: anyNamed('email'), password: anyNamed('password')))
//             .thenAnswer((_) async => const Left(AuthFailure('Invalid credentials')));
//         return authBloc;
//       },
//       act: (bloc) => bloc.add(const SignInRequested(
//         email: tEmail,
//         password: tPassword,
//       )),
//       expect: () => [
//         AuthLoading(),
//         const AuthError('Invalid credentials'),
//       ],
//     );
//   });

//   group('SignUpRequested', () {
//     const tDisplayName = 'Test User';

//     blocTest<AuthBloc, AuthState>(
//       'should emit [AuthLoading, Authenticated] when sign up succeeds',
//       build: () {
//         when(mockSignUpUseCase(
//           email: anyNamed('email'),
//           password: anyNamed('password'),
//           displayName: anyNamed('displayName'),
//         )).thenAnswer((_) async => const Right(tUser));
//         return authBloc;
//       },
//       act: (bloc) => bloc.add(const SignUpRequested(
//         email: tEmail,
//         password: tPassword,
//         displayName: tDisplayName,
//       )),
//       expect: () => [
//         AuthLoading(),
//         const Authenticated(tUser),
//       ],
//     );
//   });

//   group('GoogleSignInRequested', () {
//     blocTest<AuthBloc, AuthState>(
//       'should emit [AuthLoading, Authenticated] when Google sign in succeeds',
//       build: () {
//         when(mockGoogleSignInUseCase()).thenAnswer((_) async => const Right(tUser));
//         return authBloc;
//       },
//       act: (bloc) => bloc.add(GoogleSignInRequested()),
//       expect: () => [
//         AuthLoading(),
//         const Authenticated(tUser),
//       ],
//     );
//   });

//   group('SignOutRequested', () {
//     blocTest<AuthBloc, AuthState>(
//       'should emit [AuthLoading, Unauthenticated] when sign out succeeds',
//       build: () {
//         when(mockSignOutUseCase()).thenAnswer((_) async => const Right(null));
//         return authBloc;
//       },
//       act: (bloc) => bloc.add(SignOutRequested()),
//       expect: () => [
//         AuthLoading(),
//         Unauthenticated(),
//       ],
//     );
//   });
// }