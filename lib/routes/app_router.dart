import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:makan_mate/features/auth/presentation/pages/auth_wrapper.dart';
import 'package:makan_mate/features/auth/presentation/pages/login_page.dart';
import 'package:makan_mate/features/auth/presentation/pages/signup_page.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';
import 'package:makan_mate/features/home/presentation/pages/home_page.dart';
import 'package:makan_mate/features/home/presentation/pages/restaurant_detail_screen.dart';
import 'package:makan_mate/features/recommendations/presentation/pages/recommendations_page.dart';
import 'package:makan_mate/features/recommendations/presentation/bloc/recommendation_bloc.dart';
import 'package:makan_mate/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:makan_mate/features/admin/presentation/pages/admin_main_page.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_event.dart';
import 'package:makan_mate/core/ml/model_testing_screen.dart';
import 'package:makan_mate/core/di/injection_container.dart' as di;

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const AuthWrapper());

      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignUpPage());

      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case '/recommendations':
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          return MaterialPageRoute(builder: (_) => const LoginPage());
        }
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => di.sl<RecommendationBloc>(),
            child: RecommendationsPage(userId: user.uid),
          ),
        );

      case '/admin':
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          return MaterialPageRoute(builder: (_) => const LoginPage());
        }
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => di.sl<AdminBloc>()..add(const LoadPlatformMetrics()),
            child: const AdminMainPage(),
          ),
        );

      case '/model-testing':
        return MaterialPageRoute(builder: (_) => const ModelTestingScreen());

      case '/restaurantDetail':
        final restaurant = settings.arguments as RestaurantEntity;
        return MaterialPageRoute(
          builder: (_) => RestaurantDetailScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
