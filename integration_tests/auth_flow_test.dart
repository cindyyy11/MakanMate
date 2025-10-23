import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:makan_mate/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow', () {
    testWidgets('complete sign up and sign in flow', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Should show login page
      expect(find.text('Welcome Back!'), findsOneWidget);

      // Navigate to sign up
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Fill sign up form
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Test User',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'password123',
      );
      await tester.enterText(
        find.byType(TextFormField).at(3),
        'password123',
      );

      // Submit sign up
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should navigate to home page
      expect(find.text('MakanMate'), findsOneWidget);

      // Sign out
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      // Should return to login page
      expect(find.text('Welcome Back!'), findsOneWidget);

      // Sign in with created account
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'password123',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should navigate to home page again
      expect(find.text('MakanMate'), findsOneWidget);
    });
  });
}