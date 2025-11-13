// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// import 'package:makan_mate/features/auth/presentation/bloc/auth_bloc.dart';
// import 'package:makan_mate/features/auth/presentation/bloc/auth_event.dart';
// import 'package:makan_mate/features/auth/presentation/bloc/auth_state.dart';
// import 'package:makan_mate/features/auth/presentation/pages/login_page.dart';

// import 'login_page_test.mocks.dart';

// @GenerateMocks([AuthBloc])
// void main() {
//   late MockAuthBloc mockAuthBloc;

//   setUp(() {
//     mockAuthBloc = MockAuthBloc();
//   });

//   Widget makeTestableWidget(Widget child) {
//     return BlocProvider<AuthBloc>.value(
//       value: mockAuthBloc,
//       child: MaterialApp(
//         home: child,
//       ),
//     );
//   }

//   testWidgets('should display login form with all required fields',
//       (WidgetTester tester) async {
//     // Arrange
//     when(mockAuthBloc.state).thenReturn(Unauthenticated());
//     when(mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

//     // Act
//     await tester.pumpWidget(makeTestableWidget(const LoginPage()));

//     // Assert
//     expect(find.text('Welcome Back!'), findsOneWidget);
//     expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password
//     expect(find.text('Sign In'), findsWidgets);
//     expect(find.text('Continue with Google'), findsOneWidget);
//   });

//   testWidgets('should show loading indicator when state is AuthLoading',
//       (WidgetTester tester) async {
//     // Arrange
//     when(mockAuthBloc.state).thenReturn(AuthLoading());
//     when(mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

//     // Act
//     await tester.pumpWidget(makeTestableWidget(const LoginPage()));

//     // Assert
//     expect(find.byType(CircularProgressIndicator), findsOneWidget);
//   });

//   testWidgets('should show error message when state is AuthError',
//       (WidgetTester tester) async {
//     // Arrange
//     const errorMessage = 'Invalid credentials';
//     when(mockAuthBloc.state).thenReturn(Unauthenticated());
//     when(mockAuthBloc.stream).thenAnswer(
//       (_) => Stream.value(const AuthError(errorMessage)),
//     );

//     // Act
//     await tester.pumpWidget(makeTestableWidget(const LoginPage()));
//     await tester.pump();

//     // Assert
//     expect(find.text(errorMessage), findsOneWidget);
//   });

//   testWidgets('should call SignInRequested when sign in button is tapped',
//       (WidgetTester tester) async {
//     // Arrange
//     when(mockAuthBloc.state).thenReturn(Unauthenticated());
//     when(mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

//     // Act
//     await tester.pumpWidget(makeTestableWidget(const LoginPage()));

//     // Enter email and password
//     await tester.enterText(
//       find.byType(TextFormField).first,
//       'test@example.com',
//     );
//     await tester.enterText(
//       find.byType(TextFormField).last,
//       'password123',
//     );

//     // Tap sign in button
//     await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
//     await tester.pump();

//     // Assert
//     verify(mockAuthBloc.add(const SignInRequested(
//       email: 'test@example.com',
//       password: 'password123',
//     ))).called(1);
//   });

//   testWidgets('should validate email format',
//       (WidgetTester tester) async {
//     // Arrange
//     when(mockAuthBloc.state).thenReturn(Unauthenticated());
//     when(mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

//     // Act
//     await tester.pumpWidget(makeTestableWidget(const LoginPage()));

//     // Enter invalid email
//     await tester.enterText(
//       find.byType(TextFormField).first,
//       'invalid-email',
//     );
//     await tester.enterText(
//       find.byType(TextFormField).last,
//       'password123',
//     );

//     // Tap sign in button
//     await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
//     await tester.pump();

//     // Assert
//     expect(find.text('Enter a valid email address'), findsOneWidget);
//   });
// }