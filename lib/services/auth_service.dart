import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:makan_mate/services/base_service.dart';
import 'package:makan_mate/services/user_service.dart';
import '../models/user_models.dart';

class AuthService extends BaseService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  // Current user stream
  Stream<User?> get authStateChanges => BaseService.auth.authStateChanges();
  User? get currentUser => BaseService.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  // Email/Password Sign Up
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final UserCredential result = await BaseService.auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (result.user != null) {
        await result.user!.updateDisplayName(name);
        await _createUserProfile(result.user!, name);
      }

      return result;
    } catch (e) {
      BaseService.logger.e('Sign up error: $e');
      rethrow;
    }
  }

  // Email/Password Sign In
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await BaseService.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      BaseService.logger.e('Sign in error: $e');
      rethrow;
    }
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Signed in with google!');
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();
          print('Google authentication success: ${googleUser!.email}');
      if (googleUser == null) return null;

      print('Signed in with google 2!');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken, //unsure
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await BaseService.auth.signInWithCredential(
        credential,
      );

      if (result.user != null) {
        await _createOrUpdateUserProfile(result.user!);
      }

      return result;
    } catch (e) {
      BaseService.logger.e('Google sign in error: $e');
      rethrow;
    }
  }

  // Facebook Sign In
  Future<UserCredential?> signInWithFacebook() async {
    try {
      final LoginResult result = await _facebookAuth.login();

      if (result.status == LoginStatus.success) {
        final AccessToken? accessToken = result.accessToken;
        final AuthCredential credential = FacebookAuthProvider.credential(
          accessToken!.tokenString,
        );

        final UserCredential userCredential = await BaseService.auth
            .signInWithCredential(credential);

        if (userCredential.user != null) {
          await _createOrUpdateUserProfile(userCredential.user!);
        }

        return userCredential;
      }

      return null;
    } catch (e) {
      BaseService.logger.e('Facebook sign in error: $e');
      rethrow;
    }
  }

  // Guest Sign In (Anonymous)
  Future<UserCredential?> signInAsGuest() async {
    try {
      final UserCredential result = await BaseService.auth.signInAnonymously();
      
      if (result.user != null) {
        // Optionally create a guest user profile
        await _createGuestUserProfile(result.user!);
      }
      
      return result;
    } catch (e) {
      BaseService.logger.e('Guest sign in error: $e');
      rethrow;
    }
  }

  // Create guest user profile
  Future<void> _createGuestUserProfile(User user) async {
    final userModel = UserModel(
      id: user.uid,
      name: 'Guest User',
      email: 'guest@makanmate.app',
      currentLocation: Location(
        latitude: 3.1390,
        longitude: 101.6869,
      ), // Default to KL
      isGuest: true, // Important: mark as guest
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await UserService().createUser(userModel);
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await Future.wait([
        BaseService.auth.signOut(),
        _googleSignIn.signOut(),
        _facebookAuth.logOut(),
      ]);
    } catch (e) {
      BaseService.logger.e('Sign out error: $e');
      rethrow;
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await BaseService.auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      BaseService.logger.e('Reset password error: $e');
      rethrow;
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user != null) {
        await UserService().deleteUserData(user.uid);
        await user.delete();
      }
    } catch (e) {
      BaseService.logger.e('Delete account error: $e');
      rethrow;
    }
  }

  // Create user profile
  Future<void> _createUserProfile(User user, String displayName) async {
    final userModel = UserModel(
      id: user.uid,
      name: displayName,
      email: user.email ?? '',
      currentLocation: Location(
        latitude: 3.1390,
        longitude: 101.6869,
      ), // Default to KL
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await UserService().createUser(userModel);
  }

  // Create or update user profile
  Future<void> _createOrUpdateUserProfile(User user) async {
    final existingUser = await UserService().getUser(user.uid);

    if (existingUser == null) {
      await _createUserProfile(user, user.displayName ?? 'User');
    } else {
      await UserService().updateUser(
        existingUser.copyWith(updatedAt: DateTime.now()),
      );
    }
  }
}
