class AppConstants {
  // App info
  static const String appName = 'MakanMate';
  static const String appVersion = '1.0.0';
  
  // Pagination
  static const int restaurantsPerPage = 20;
  static const int reviewsPerPage = 10;
  
  // Cache durations
  static const Duration shortCacheDuration = Duration(minutes: 5);
  static const Duration mediumCacheDuration = Duration(hours: 1);
  static const Duration longCacheDuration = Duration(hours: 24);
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxReviewLength = 500;
  static const int maxUsernameLength = 30;
  
  // Keys
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
}
