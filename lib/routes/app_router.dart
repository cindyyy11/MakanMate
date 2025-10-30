import 'package:flutter/material.dart';
import 'package:makan_mate/features/auth/presentation/pages/auth_wrapper.dart';
import 'package:makan_mate/features/auth/presentation/pages/login_page.dart';
import 'package:makan_mate/features/auth/presentation/pages/signup_page.dart';
import 'package:makan_mate/features/home/presentation/pages/home_page.dart';


class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const AuthWrapper(),
        );
        
      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
        
      case '/signup':
        return MaterialPageRoute(
          builder: (_) => const SignUpPage(),
        );
        
      case '/home':
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );
        
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}