import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:makan_mate/features/home/presentation/pages/home_page.dart';
import '../../features/vendor/presentation/pages/menu_management_page.dart';

/// Utility class to handle role-based routing
class RoleRouter {
  /// Get user role from Firestore
  static Future<String?> getUserRole(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        return data?['role'] as String? ?? 'customer'; // Default to customer
      }
      return 'customer'; // Default role
    } catch (e) {
      print('Error getting user role: $e');
      return 'customer'; // Default role on error
    }
  }

  /// Get the appropriate home page based on user role
  static Future<Widget> getHomePage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Should not happen if called after authentication check
      return const HomePage();
    }

    final role = await getUserRole(user.uid);

    if (role == 'vendor') {
      return const MenuManagementPage();
    } else {
      return const HomePage();
    }
  }

  /// Check if current user is a vendor
  static Future<bool> isVendor() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final role = await getUserRole(user.uid);
    return role == 'vendor';
  }
}
