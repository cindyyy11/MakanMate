import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:makan_mate/core/errors/exceptions.dart';
import 'package:makan_mate/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailPassword(String email, String password);
  Future<UserModel> signUpWithEmailPassword(
    String email,
    String password,
    String? displayName,
  );
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<void> sendPasswordResetEmail(String email);
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  @override
  Future<UserModel> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final cred = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) throw AuthException('Sign in failed');
      return UserModel.fromFirebase(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthCode(e));
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword(
    String email,
    String password,
    String? displayName,
  ) async {
    try {
      final cred = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) throw AuthException('Sign up failed');

      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
        await user.reload();
      }
      final refreshed = firebaseAuth.currentUser ?? user;
      return UserModel.fromFirebase(refreshed);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthCode(e));
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // WEB: use Firebase web popup/redirect flow
        final provider = GoogleAuthProvider();
        // Optional: provider.setCustomParameters({'prompt': 'select_account'});
        final cred = await firebaseAuth.signInWithPopup(provider);
        final user = cred.user;
        if (user == null) throw AuthException('Google sign-in failed');
        return UserModel.fromFirebase(user);
      } else {
        // MOBILE: google_sign_in v7 interactive auth → idToken → Firebase credential
        final account = await googleSignIn
            .authenticate(); // throws on cancel/fail
        final googleAuth = await account.authentication; 
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        final cred = await firebaseAuth.signInWithCredential(credential);
        final user = cred.user;
        if (user == null) throw AuthException('Google sign-in failed');
        return UserModel.fromFirebase(user);
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthCode(e));
    } on GoogleSignInException catch (e) {
      throw AuthException('Google sign-in ${e.code.name.toLowerCase()}');
    } catch (e) {
      throw AuthException('Google sign-in failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // On web, googleSignIn.signOut() is a no-op; firebaseAuth.signOut() is enough.
      await firebaseAuth.signOut();
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
    } catch (_) {
      throw AuthException('Sign out failed');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    return user == null ? null : UserModel.fromFirebase(user);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getPasswordResetErrorMessage(e));
    } catch (e) {
      throw AuthException('Failed to send password reset email');
    }
  }
  
  String _getPasswordResetErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address';
      case 'invalid-email':
        return 'Invalid email address';
      case 'too-many-requests':
        return 'Too many requests. Please try again later';
      default:
        return 'Failed to send reset email. Please try again';
    }
  }

  @override
  Stream<UserModel?> get authStateChanges => firebaseAuth
      .authStateChanges()
      .map((u) => u == null ? null : UserModel.fromFirebase(u));

  String _mapFirebaseAuthCode(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'weak-password':
        return 'Password is too weak';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      case 'network-request-failed':
        return 'Network error occurred';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      case 'requires-recent-login':
        return 'Please reauthenticate and try again';
      case 'account-exists-with-different-credential':
        return 'Account exists with a different sign-in method';
      default:
        return 'Authentication failed';
    }
  }
}
