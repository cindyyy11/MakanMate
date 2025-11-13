import 'dart:convert';
import 'package:makan_mate/core/errors/exceptions.dart';
import 'package:makan_mate/features/auth/data/models/user_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String cachedUserKey = 'CACHED_USER';
  
  AuthLocalDataSourceImpl({required this.sharedPreferences});
  
   @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = sharedPreferences.getString(cachedUserKey);
      if (jsonString != null) {
        return UserModel.fromJson(json.decode(jsonString));
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to read cached user');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await sharedPreferences.setString(
        cachedUserKey,
        json.encode(user.toJson()),
      );
    } catch (e) {
      throw CacheException('Failed to cache user');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(cachedUserKey);
    } catch (e) {
      throw CacheException('Failed to clear cache');
    }
  }
}