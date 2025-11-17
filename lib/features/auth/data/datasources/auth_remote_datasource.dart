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
  Future<UserModel> signInAsGuest();
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
      isVerified: data['isVerified'] ?? false,
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
      isBanned: data['isBanned'] ?? false,
      banReason: data['banReason'],
      bannedAt: data['bannedAt'] != null ? _safeToDate(data['bannedAt']) : null,
      bannedUntil: data['bannedUntil'] != null ? _safeToDate(data['bannedUntil']) : null,
      bannedBy: data['bannedBy'],
      warnings: List<Map<String, dynamic>>.from(data['warnings'] ?? []),
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

      final userModel = await getUserFromFirestore(user);

      // Check if user is banned
      if (userModel.isBanned) {
        final now = DateTime.now();
        // Check if ban has expired
        if (userModel.bannedUntil != null && userModel.bannedUntil!.isAfter(now)) {
          final daysLeft = userModel.bannedUntil!.difference(now).inDays;
          throw AuthException(
            'Your account has been suspended${userModel.banReason != null ? ': ${userModel.banReason}' : ''}. '
            'Suspension expires in $daysLeft day${daysLeft != 1 ? 's' : ''}. '
            'Please contact support if you believe this is an error.',
          );
        } else if (userModel.bannedUntil == null) {
          // Permanent ban
          throw AuthException(
            'Your account has been permanently suspended${userModel.banReason != null ? ': ${userModel.banReason}' : ''}. '
            'Please contact support if you believe this is an error.',
          );
        }
        // Ban expired, allow login (admin should unban, but we allow expired bans)
      }

      // Check vendor status if user is a vendor
      if (userModel.role == 'vendor') {
        final vendorDoc = await FirebaseFirestore.instance
            .collection('vendors')
            .doc(userModel.id)
            .get();

        if (vendorDoc.exists) {
          final vendorData = vendorDoc.data()!;
          final suspendedUntil = vendorData['suspendedUntil'] as Timestamp?;
          final suspendedAt = vendorData['suspendedAt'] as Timestamp?;
          final suspensionReason = vendorData['suspensionReason'] as String?;

          if (suspendedAt != null) {
            final now = DateTime.now();
            if (suspendedUntil != null && suspendedUntil.toDate().isAfter(now)) {
              final daysLeft = suspendedUntil.toDate().difference(now).inDays;
              throw AuthException(
                'Your vendor account has been suspended${suspensionReason != null ? ': $suspensionReason' : ''}. '
                'Suspension expires in $daysLeft day${daysLeft != 1 ? 's' : ''}. '
                'Please contact support for assistance.',
              );
            } else if (suspendedUntil == null) {
              // Permanent suspension
              throw AuthException(
                'Your vendor account has been permanently suspended${suspensionReason != null ? ': $suspensionReason' : ''}. '
                'Please contact support if you believe this is an error.',
              );
            }
            // Suspension expired, allow login
          }

          // Check approval status
          final approvalStatus = vendorData['approvalStatus'] as String? ?? 'pending';
          if (approvalStatus == 'rejected') {
            final rejectionReason = vendorData['rejectionReason'] as String?;
            throw AuthException(
              'Your vendor application has been rejected${rejectionReason != null ? ': $rejectionReason' : ''}. '
              'Please contact support if you wish to appeal.',
            );
          }
        }
      }

      return userModel;
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

      UserModel userModel;
      if (!userDoc.exists) {
        // Create user document if it doesn't exist
        userModel = UserModel.fromFirebase(user);
        final userData = userModel.toJson();
        userData['createdAt'] = Timestamp.fromDate(userModel.createdAt);
        userData['updatedAt'] = Timestamp.fromDate(userModel.updatedAt);
        userData['lastActive'] = FieldValue.serverTimestamp();
        userData['isVerified'] = true;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userModel.id)
            .set(userData);
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'lastActive': FieldValue.serverTimestamp()});

        userModel = await getUserFromFirestore(user);
      }

      // Check if user is banned
      if (userModel.isBanned) {
        final now = DateTime.now();
        if (userModel.bannedUntil != null && userModel.bannedUntil!.isAfter(now)) {
          final daysLeft = userModel.bannedUntil!.difference(now).inDays;
          throw AuthException(
            'Your account has been suspended${userModel.banReason != null ? ': ${userModel.banReason}' : ''}. '
            'Suspension expires in $daysLeft day${daysLeft != 1 ? 's' : ''}. '
            'Please contact support if you believe this is an error.',
          );
        } else if (userModel.bannedUntil == null) {
          throw AuthException(
            'Your account has been permanently suspended${userModel.banReason != null ? ': ${userModel.banReason}' : ''}. '
            'Please contact support if you believe this is an error.',
          );
        }
      }

      // Check vendor status if user is a vendor
      if (userModel.role == 'vendor') {
        final vendorDoc = await FirebaseFirestore.instance
            .collection('vendors')
            .doc(userModel.id)
            .get();

        if (vendorDoc.exists) {
          final vendorData = vendorDoc.data()!;
          final suspendedUntil = vendorData['suspendedUntil'] as Timestamp?;
          final suspendedAt = vendorData['suspendedAt'] as Timestamp?;
          final suspensionReason = vendorData['suspensionReason'] as String?;

          if (suspendedAt != null) {
            final now = DateTime.now();
            if (suspendedUntil != null && suspendedUntil.toDate().isAfter(now)) {
              final daysLeft = suspendedUntil.toDate().difference(now).inDays;
              throw AuthException(
                'Your vendor account has been suspended${suspensionReason != null ? ': $suspensionReason' : ''}. '
                'Suspension expires in $daysLeft day${daysLeft != 1 ? 's' : ''}. '
                'Please contact support for assistance.',
              );
            } else if (suspendedUntil == null) {
              throw AuthException(
                'Your vendor account has been permanently suspended${suspensionReason != null ? ': $suspensionReason' : ''}. '
                'Please contact support if you believe this is an error.',
              );
            }
          }

          final approvalStatus = vendorData['approvalStatus'] as String? ?? 'pending';
          if (approvalStatus == 'rejected') {
            final rejectionReason = vendorData['rejectionReason'] as String?;
            throw AuthException(
              'Your vendor application has been rejected${rejectionReason != null ? ': $rejectionReason' : ''}. '
              'Please contact support if you wish to appeal.',
            );
          }
        }
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthCode(e));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Google sign-in failed: $e');
    }
  }

  @override
  Future<UserModel> signInAsGuest() async {
    try {
      final cred = await firebaseAuth.signInAnonymously();
      final user = cred.user;

      if (user == null) throw AuthException('Guest sign-in failed');

      // Create guest user document
      final userModel = UserModel(
        id: user.uid,
        name: 'Guest User',
        email: 'guest_${user.uid}@makanmate.guest',
        role: 'guest',
        isVerified: false,
        profileImageUrl: null,
        dietaryRestrictions: const [],
        cuisinePreferences: const {},
        spiceTolerance: 0.5,
        culturalBackground: 'mixed',
        currentLocation: const Location(
          latitude: 3.1390,
          longitude: 101.6869,
          city: 'Kuala Lumpur',
          state: 'Kuala Lumpur',
          country: 'Malaysia',
        ),
        behaviorPatterns: const {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isBanned: false,
        warnings: const [],
      );

      final userData = userModel.toJson();
      userData['createdAt'] = Timestamp.fromDate(userModel.createdAt);
      userData['updatedAt'] = Timestamp.fromDate(userModel.updatedAt);
      userData['lastActive'] = FieldValue.serverTimestamp();
      userData['isGuest'] = true;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userModel.id)
          .set(userData, SetOptions(merge: true));

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthCode(e));
    } catch (e) {
      throw AuthException('Guest sign-in failed: $e');
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
        return 'No account found with this email address. Please check your email or sign up.';
      case 'wrong-password':
        return 'Incorrect password. Please try again or use "Forgot Password" to reset.';
      case 'invalid-email':
        return 'Invalid email address format. Please enter a valid email.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'email-already-in-use':
        return 'An account with this email already exists. Please sign in instead.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters with a mix of letters and numbers.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet and try again.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait a few minutes before trying again.';
      case 'requires-recent-login':
        return 'For security, please sign in again to continue.';
      case 'account-exists-with-different-credential':
        return 'An account exists with a different sign-in method. Please use the original method.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials and try again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
