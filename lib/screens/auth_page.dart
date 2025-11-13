import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/core/utils/role_router.dart';
import 'package:makan_mate/features/admin/presentation/pages/admin_promotion_approval_page.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_event.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_state.dart';
import 'package:makan_mate/features/vendor/presentation/bloc/vendor_bloc.dart';
import 'package:makan_mate/features/vendor/presentation/pages/pending_approval_page.dart';
import 'package:makan_mate/features/vendor/presentation/pages/vendor_navigation_wrapper.dart';
import 'package:makan_mate/screens/home_screen.dart';
import 'login_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading || state is AuthInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AuthBlocked) {
            final lowerMessage = state.message.toLowerCase();
            final isRejected = lowerMessage.contains('rejected');

            if (isRejected) {
              return _RejectedAccountView(
                message: state.message,
                onBack: () => context.read<AuthBloc>().add(AuthResetRequested()),
              );
            }

            return PendingApprovalPage(
              message: state.message,
              onBackToLogin: () =>
                  context.read<AuthBloc>().add(AuthResetRequested()),
            );
          }

          if (state is Authenticated) {
            final user = state.user;
            return FutureBuilder<String?>(
              future: RoleRouter.getUserRole(user.uid),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final role = roleSnapshot.data ?? 'customer';

                if (role == 'vendor') {
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: context.read<VendorBloc>()),
                    ],
                    child: const VendorNavigationWrapper(),
                  );
                } else if (role == 'admin') {
                  return const AdminPromotionApprovalPage();
                } else {
                  return const HomeScreen();
                }
              },
            );
          }

          if (state is Unauthenticated || state is AuthError) {
            return const LoginPage();
          }

          return const LoginPage();
        },
      ),
    );
  }
}

class _RejectedAccountView extends StatelessWidget {
  const _RejectedAccountView({
    required this.message,
    required this.onBack,
  });

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.block, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please contact support for further assistance.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onBack,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}