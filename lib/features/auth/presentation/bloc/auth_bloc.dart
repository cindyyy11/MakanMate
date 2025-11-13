import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../services/auth_service.dart';
import '../../../vendor/domain/repositories/vendor_profile_repository.dart';
import '../../../vendor/domain/entities/vendor_profile_entity.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final VendorProfileRepository _vendorProfileRepository;

  AuthBloc({
    AuthService? authService,
    required VendorProfileRepository vendorProfileRepository,
  })  : _authService = authService ?? AuthService(),
        _vendorProfileRepository = vendorProfileRepository,
        super(AuthInitial()) {
    // Check user state at startup
    on<AppStarted>((event, emit) async {
      final user = _authService.currentUser;
      if (user != null) {
        await _handlePostLogin(user, emit);
      } else {
        emit(Unauthenticated());
      }
    });

    // Email / Password login
    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final userCred = await _authService.signInWithEmail(
          email: event.email,
          password: event.password,
        );
        if (userCred?.user != null) {
          await _handlePostLogin(userCred!.user!, emit);
        } else {
          emit(Unauthenticated());
        }
      } catch (e) {
        emit(AuthError('Failed to sign in: $e'));
        emit(Unauthenticated());
      }
    });

    // Google Sign-In
    on<GoogleSignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final userCred = await _authService.signInWithGoogle();
        if (userCred?.user != null) {
          await _handlePostLogin(userCred!.user!, emit);
        } else {
          emit(Unauthenticated());
        }
      } catch (e) {
        emit(AuthError('Google sign in failed: $e'));
        emit(Unauthenticated());
      }
    });

    // Sign out
    on<SignOutRequested>((event, emit) async {
      emit(AuthLoading());
      await _authService.signOut();
      emit(Unauthenticated());
    });

    on<AuthResetRequested>((event, emit) {
      emit(Unauthenticated());
    });
  }

  Future<void> _handlePostLogin(User user, Emitter<AuthState> emit) async {
    try {
      final VendorProfileEntity? profile =
          await _vendorProfileRepository.getVendorProfile();

      final status = profile?.approvalStatus ?? 'pending';

      if (status == 'approved') {
        emit(Authenticated(user));
      } else if (status == 'rejected') {
        await _authService.signOut();
        emit(AuthBlocked(
            'Your account was rejected. Please contact support for assistance.'));
      } else {
        await _authService.signOut();
        emit(AuthBlocked(
            'Your account is pending admin approval. Please check back soon.'));
      }
    } catch (e) {
      emit(AuthError('Failed to verify approval status: $e'));
      emit(Unauthenticated());
    }
  }
}
