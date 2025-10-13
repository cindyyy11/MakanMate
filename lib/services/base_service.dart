import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

abstract class BaseService {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final Logger logger = Logger();
  
  // Common error handling
  static String handleError(dynamic error) {
    logger.e('Service error: $error');
    
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Access denied. Please check your permissions.';
        case 'not-found':
          return 'Requested data not found.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        default:
          return 'An error occurred: ${error.message}';
      }
    }
    
    return 'An unexpected error occurred.';
  }
}