import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  /// Upload menu item image to Firebase Storage
  /// Returns the download URL of the uploaded image
  Future<String> uploadMenuItemImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Generate unique filename
      final String fileName = '${_uuid.v4()}.jpg';
      final String path = 'vendors/${user.uid}/menu_items/$fileName';

      // Create reference
      final Reference ref = _storage.ref().child(path);

      // Upload file
      final UploadTask uploadTask = ref.putFile(imageFile);

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete menu item image from Firebase Storage
  Future<void> deleteMenuItemImage(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) return;

      final user = _auth.currentUser;
      if (user == null) return;

      // Use refFromURL to create a reference directly from the download URL
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Log error but don't throw - image deletion failure shouldn't block other operations
      print('Failed to delete image: $e');
    }
  }

  /// Upload promotion image to Firebase Storage
  /// Returns the download URL of the uploaded image
  Future<String> uploadPromotionImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final String fileName = '${_uuid.v4()}.jpg';
      final String path = 'vendors/${user.uid}/promotions/$fileName';

      final Reference ref = _storage.ref().child(path);

      final UploadTask uploadTask = ref.putFile(imageFile);

      final TaskSnapshot snapshot = await uploadTask;

      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload profile photo to Firebase Storage
  /// Returns the download URL of the uploaded image
  Future<String> uploadProfilePhoto(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Generate unique filename
      final String fileName = '${_uuid.v4()}.jpg';
      final String path = 'vendors/${user.uid}/profile_photo/$fileName';

      // Create reference
      final Reference ref = _storage.ref().child(path);

      // Upload file
      final UploadTask uploadTask = ref.putFile(imageFile);

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile photo: $e');
    }
  }

  /// Upload business logo to Firebase Storage
  /// Returns the download URL of the uploaded image
  Future<String> uploadBusinessLogo(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Generate unique filename
      final String fileName = '${_uuid.v4()}.jpg';
      final String path = 'vendors/${user.uid}/business_logo/$fileName';

      // Create reference
      final Reference ref = _storage.ref().child(path);

      // Upload file
      final UploadTask uploadTask = ref.putFile(imageFile);

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload business logo: $e');
    }
  }

  /// Upload certificate image to Firebase Storage
  /// Returns the download URL of the uploaded image
  Future<String> uploadCertificateImage(File imageFile, String certificationId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Generate unique filename
      final String fileName = '${_uuid.v4()}.jpg';
      final String path = 'vendors/${user.uid}/certifications/$certificationId/$fileName';

      // Create reference
      final Reference ref = _storage.ref().child(path);

      // Upload file
      final UploadTask uploadTask = ref.putFile(imageFile);

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload certificate image: $e');
    }
  }
}

