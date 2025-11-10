import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/core/utils/role_router.dart';
import 'package:makan_mate/core/di/injection_container.dart' as di;
import 'package:makan_mate/features/vendor/presentation/pages/vendor_navigation_wrapper.dart';
import 'package:makan_mate/features/vendor/presentation/bloc/vendor_bloc.dart';
import 'package:makan_mate/features/vendor/presentation/bloc/promotion_bloc.dart';
import 'package:makan_mate/features/vendor/presentation/bloc/promotion_event.dart';
import 'package:makan_mate/screens/home_screen.dart';
import '../screens/login_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // User is logged in - route based on role
          if (snapshot.hasData) {
            return FutureBuilder<String?>(
              future: RoleRouter.getUserRole(snapshot.data!.uid),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                
                final role = roleSnapshot.data ?? 'customer';
                
                // Route to appropriate page based on role
                if (role == 'vendor') {
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: context.read<VendorBloc>()),
                      BlocProvider(
                        create: (_) => di.sl<PromotionBloc>()..add(LoadPromotionsEvent()),
                      ),
                    ],
                    child: const VendorNavigationWrapper(),
                  );
                } else {
                  return const HomeScreen();
                }
              },
            );
          }
          // User is NOT logged in - show login page
          else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}