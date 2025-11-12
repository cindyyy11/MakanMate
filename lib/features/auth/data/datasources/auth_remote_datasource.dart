import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:makan_mate/core/errors/exceptions.dart';
import 'package:makan_mate/features/auth/data/models/user_models.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailPassword(String email, String password);
  Future<UserModel> signUpWithEmailPassword(
    String email,
    String password,
    String? displayName,
    String role,
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

  Future<UserModel> getUserFromFirestore(User firebaseUser) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    // If user document doesn't exist, create it (for existing Firebase Auth users)
    if (!userDoc.exists) {
      final userModel = UserModel.fromFirebase(firebaseUser);
      final userData = userModel.toJson();
      userData['createdAt'] = Timestamp.fromDate(userModel.createdAt);
      userData['updatedAt'] = Timestamp.fromDate(userModel.updatedAt);
      userData['lastActive'] = FieldValue.serverTimestamp();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userModel.id)
          .set(userData);

      return userModel;
    }

    final data = userDoc.data()!;

    // Update lastActive field
    await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .update({'lastActive': FieldValue.serverTimestamp()});

    return UserModel(
      id: firebaseUser.uid,
      name:
          data['name'] ??
          firebaseUser.displayName ??
          firebaseUser.email!.split('@').first,
      email: firebaseUser.email!,
      role: data['role'] ?? 'user',
      profileImageUrl: data['profileImageUrl'],
      dietaryRestrictions: List<String>.from(data['dietaryRestrictions'] ?? []),
      cuisinePreferences: Map<String, double>.from(
        data['cuisinePreferences'] ?? {},
      ),
      spiceTolerance: (data['spiceTolerance'] ?? 0.5).toDouble(),
      culturalBackground: data['culturalBackground'] ?? 'unknown',
      currentLocation: Location.fromJson(data['currentLocation']),
      behaviorPatterns: Map<String, double>.from(
        data['behaviorPatterns'] ?? {},
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

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
      return await getUserFromFirestore(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthCode(e));
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword(
    String email,
    String password,
    String? displayName,
    String role,
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

      // Create user model with role
      final userModel = UserModel.fromFirebase(refreshed, role: role);

      // Create user document in Firestore with lastActive field
      final userData = userModel.toJson();
      userData['createdAt'] = Timestamp.fromDate(userModel.createdAt);
      userData['updatedAt'] = Timestamp.fromDate(userModel.updatedAt);
      userData['lastActive'] = FieldValue.serverTimestamp();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userModel.id)
          .set(userData);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthCode(e));
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      User? user;
      if (kIsWeb) {
        // WEB: use Firebase web popup/redirect flow
        final provider = GoogleAuthProvider();
        // Optional: provider.setCustomParameters({'prompt': 'select_account'});
        final cred = await firebaseAuth.signInWithPopup(provider);
        user = cred.user;
        if (user == null) throw AuthException('Google sign-in failed');
      } else {
        // MOBILE: google_sign_in v7 interactive auth → idToken → Firebase credential
        final account = await googleSignIn
            .authenticate(); // throws on cancel/fail
        final googleAuth = account.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        final cred = await firebaseAuth.signInWithCredential(credential);
        user = cred.user;
        if (user == null) throw AuthException('Google sign-in failed');
      }

      // Check if user document exists, create if not
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        // Create user document if it doesn't exist
        final userModel = UserModel.fromFirebase(user);
        final userData = userModel.toJson();
        userData['createdAt'] = Timestamp.fromDate(userModel.createdAt);
        userData['updatedAt'] = Timestamp.fromDate(userModel.updatedAt);
        userData['lastActive'] = FieldValue.serverTimestamp();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userModel.id)
            .set(userData);

        return userModel;
      } else {
        // Update lastActive and return existing user
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'lastActive': FieldValue.serverTimestamp()});

        return await getUserFromFirestore(user);
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
