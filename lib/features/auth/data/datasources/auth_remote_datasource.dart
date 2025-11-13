import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  final String? serverClientId = dotenv.env['SERVER_CLIENT_ID'];
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

  AuthRemoteDataSourceImpl({required this.firebaseAuth});

  DateTime _safeToDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  Future<void> refreshUserVerificationStatus(User user) async {
    // Reload user to get the latest verification status
    await user.reload();

    // If verified, update Firestore
    if (user.emailVerified) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'isVerified': true},
      );
    }
  }

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
      isVerified: data['isVerified'],
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
      createdAt: _safeToDate(data['createdAt']),
      updatedAt: _safeToDate(data['updatedAt']),
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

      if (!user.emailVerified) {
        await refreshUserVerificationStatus(user);
      }

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

      if (role == 'vendor') {
        final vendorRef = FirebaseFirestore.instance
            .collection('vendors')
            .doc(userModel.id);

        await vendorRef.set(
          {
            'ownerId': userModel.id,
            'businessName': displayName ?? '',
            'contactEmail': email,
            'status': 'pending',
            'approvalStatus': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      await user.sendEmailVerification();

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
        final GoogleSignInAccount? account = await googleSignIn.signIn();
        if (account == null) {
          // User cancelled the sign-in
          throw AuthException('Google sign-in canceled by user');
        }
        final GoogleSignInAuthentication googleAuth =
            await account.authentication;

        // ✅ Use both idToken + accessToken (important for Android/iOS)
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
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
        userData['isVerified'] = true;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userModel.id)
            .set(userData);

        return userModel;
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'lastActive': FieldValue.serverTimestamp()});

        return await getUserFromFirestore(user);
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthCode(e));
      // } on GoogleSignInException catch (e) {
      //   debugPrint(
      //     'GOOGLE SIGN-IN SDK ERROR: Code: ${e.code.name}, Description: ${e.description}',
      //   );
      //   throw AuthException('Google sign-in ${e.code.name.toLowerCase()}');
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
