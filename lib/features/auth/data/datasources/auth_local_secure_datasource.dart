// Use only on Android/iOS for stricter storage
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:makan_mate/core/errors/exceptions.dart';
import 'package:makan_mate/features/auth/data/datasources/auth_local_datasource.dart';


import 'package:makan_mate/features/auth/data/models/user_models.dart';class AuthLocalSecureDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage storage;
  static const String cachedUserKey = 'CACHED_USER';

  AuthLocalSecureDataSourceImpl({required this.storage});

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = await storage.read(key: cachedUserKey);
      return jsonString == null ? null : UserModel.fromJson(json.decode(jsonString));
    } catch (e) {
      throw CacheException('Failed to read cached user (secure)');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await storage.write(key: cachedUserKey, value: json.encode(user.toJson()));
    } catch (e) {
      throw CacheException('Failed to cache user (secure)');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await storage.delete(key: cachedUserKey);
    } catch (e) {
      throw CacheException('Failed to clear cache (secure)');
    }
  }
}
