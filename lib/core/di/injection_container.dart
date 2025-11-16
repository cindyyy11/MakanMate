import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:makan_mate/core/network/network_info.dart';
import 'package:makan_mate/features/admin/domain/usecases/approve_menu_item_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_pending_menu_items_usecase.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_review_management_bloc.dart';
import 'package:makan_mate/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:makan_mate/features/auth/data/datasources/auth_local_secure_datasource.dart';
import 'package:makan_mate/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:makan_mate/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:makan_mate/features/auth/domain/repositories/auth_repository.dart';
import 'package:makan_mate/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:makan_mate/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:makan_mate/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:makan_mate/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:makan_mate/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:makan_mate/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:makan_mate/features/home/data/datasources/restaurant_remote_datasource.dart';
import 'package:makan_mate/features/home/data/repositories/restaurant_repository_impl.dart';
import 'package:makan_mate/features/home/domain/usecases/get_restaurants_usecase.dart';
import 'package:makan_mate/features/home/domain/usecases/get_restaurant_details_usecase.dart';
import 'package:makan_mate/features/map/data/datasources/map_remote_datasource.dart';
import 'package:makan_mate/features/map/domain/repositories/map_repository.dart';
import 'package:makan_mate/features/map/domain/repositories/map_repository_impl.dart';
import 'package:makan_mate/features/map/domain/usecases/get_nearby_restaurants_usecase.dart';
import 'package:makan_mate/features/map/presentation/bloc/map_bloc.dart';
import 'package:makan_mate/features/promotions/domain/usecases/redeem_promotion_usecase.dart';
import 'package:makan_mate/features/promotions/domain/usecases/check_user_redemption_usecase.dart';
import 'package:makan_mate/features/recommendations/domain/usecases/get_contextual_recommendations_usecase.dart';
import 'package:makan_mate/features/recommendations/domain/usecases/get_similar_items_usecase.dart';
import 'package:makan_mate/features/recommendations/domain/usecases/track_interaction_usecase.dart';
import 'package:makan_mate/features/recommendations/presentation/bloc/recommendation_bloc.dart';
import 'package:makan_mate/features/home/domain/repositories/restaurant_repository.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:makan_mate/ai_engine/recommendation_engine.dart';
import 'package:makan_mate/features/home/presentation/bloc/home_bloc.dart';
import 'package:makan_mate/features/recommendations/data/datasources/recommendation_local_datasource.dart';
import 'package:makan_mate/features/recommendations/data/datasources/recommendation_remote_datasource.dart';
import 'package:makan_mate/features/recommendations/data/repositories/recommendation_repository_impl.dart';
import 'package:makan_mate/features/recommendations/domain/repositories/recommendation_repository.dart';
import 'package:makan_mate/features/recommendations/domain/usecases/get_recommendations_usecase.dart';
import 'package:makan_mate/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:makan_mate/features/admin/data/datasources/admin_vendor_management_datasource.dart';
import 'package:makan_mate/features/admin/data/datasources/admin_promotion_management_datasource.dart';
import 'package:makan_mate/features/admin/data/datasources/admin_voucher_management_datasource.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_pending_vouchers_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/approve_voucher_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/reject_voucher_usecase.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_voucher_management_bloc.dart';
import 'package:makan_mate/features/reviews/data/datasources/admin_review_management_datasource.dart';
import 'package:makan_mate/features/reviews/data/repositories/admin_review_repository_impl.dart';
import 'package:makan_mate/features/reviews/domain/repositories/admin_review_repository.dart';
import 'package:makan_mate/features/reviews/domain/usecases/get_flagged_reviews_usecase.dart';
import 'package:makan_mate/features/reviews/domain/usecases/get_all_reviews_usecase.dart';
import 'package:makan_mate/features/reviews/domain/usecases/approve_review_usecase.dart';
import 'package:makan_mate/features/reviews/domain/usecases/flag_review_usecase.dart';
import 'package:makan_mate/features/reviews/domain/usecases/remove_review_usecase.dart';
import 'package:makan_mate/features/reviews/domain/usecases/dismiss_flagged_review_usecase.dart';
import 'package:makan_mate/features/admin/data/repositories/admin_vendor_repository_impl.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_vendor_repository.dart';
import 'package:makan_mate/features/admin/data/datasources/admin_menu_management_datasource.dart';
import 'package:makan_mate/features/admin/data/datasources/admin_user_management_datasource.dart';
import 'package:makan_mate/features/admin/data/repositories/admin_user_repository_impl.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_user_repository.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_user_management_bloc.dart';
import 'package:makan_mate/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:makan_mate/features/admin/data/services/audit_log_service.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_repository.dart';
import 'package:makan_mate/features/admin/domain/usecases/export_metrics_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_activity_logs_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_metric_trend_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_notifications_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_platform_metrics_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/stream_system_metrics_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_fairness_metrics_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_seasonal_trends_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_data_quality_metrics_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_vendors_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/approve_vendor_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/reject_vendor_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_pending_promotions_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/approve_promotion_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_users_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_user_by_id_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/verify_user_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/ban_user_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/unban_user_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/warn_user_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_user_violation_history_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/delete_user_data_usecase.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:makan_mate/features/reviews/data/datasources/review_remote_datasource.dart';
import 'package:makan_mate/features/reviews/domain/usecases/get_item_reviews_usecase.dart';
import 'package:makan_mate/features/reviews/domain/usecases/get_restaurant_reviews_usecase.dart';
import 'package:makan_mate/features/reviews/domain/usecases/submit_review_usecase.dart';
import 'package:makan_mate/features/food/data/datasources/food_remote_datasource.dart';
import 'package:makan_mate/features/food/data/repositories/food_repository_impl.dart';
import 'package:makan_mate/features/food/domain/repositories/food_repository.dart';
import 'package:makan_mate/features/food/domain/usecases/get_food_item_usecase.dart';
import 'package:makan_mate/features/food/domain/usecases/get_food_items_by_restaurant_usecase.dart';
import 'package:makan_mate/features/food/domain/usecases/search_food_items_usecase.dart';
import 'package:makan_mate/features/food/domain/usecases/get_popular_food_items_usecase.dart';
import 'package:makan_mate/features/search/data/datasources/search_remote_datasource.dart';
import 'package:makan_mate/features/search/data/repositories/search_repository_impl.dart';
import 'package:makan_mate/features/search/domain/repositories/search_repository.dart';
import 'package:makan_mate/features/search/domain/usecases/add_search_history_usecase.dart';
import 'package:makan_mate/features/search/domain/usecases/get_search_history_usecase.dart';
import 'package:makan_mate/features/search/domain/usecases/search_food_usecase.dart';
import 'package:makan_mate/features/search/domain/usecases/search_restaurant_usecase.dart';
import 'package:makan_mate/features/search/presentation/bloc/search_bloc.dart';
import 'package:makan_mate/features/user/data/datasources/user_remote_datasource.dart';
import 'package:makan_mate/features/user/data/repositories/user_repository_impl.dart';
import 'package:makan_mate/features/user/domain/repositories/user_repository.dart';
import 'package:makan_mate/features/user/domain/usecases/get_user_usecase.dart';
import 'package:makan_mate/features/user/domain/usecases/update_user_usecase.dart';
import 'package:makan_mate/features/user/domain/usecases/update_user_preferences_usecase.dart';
import 'package:makan_mate/features/user/domain/usecases/update_behavioral_patterns_usecase.dart';
import 'package:makan_mate/features/vendor/data/datasources/vendor_remote_datasource.dart';
import 'package:makan_mate/features/vendor/data/repositories/vendor_repository_impl.dart';
import 'package:makan_mate/features/vendor/domain/repositories/vendor_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Vendor Feature imports
import 'package:makan_mate/features/vendor/data/datasources/promotion_remote_datasource.dart';
import 'package:makan_mate/features/vendor/data/repositories/promotion_repository_impl.dart';
import 'package:makan_mate/features/vendor/data/services/storage_service.dart';
import 'package:makan_mate/features/vendor/domain/repositories/promotion_repository.dart';
import 'package:makan_mate/features/vendor/domain/usecases/add_menu_item_usecase.dart';
import 'package:makan_mate/features/vendor/domain/usecases/delete_menu_item_usecase.dart';
import 'package:makan_mate/features/vendor/domain/usecases/get_menu_items_usecase.dart';
import 'package:makan_mate/features/vendor/domain/usecases/update_menu_item_usecase.dart';
import 'package:makan_mate/features/vendor/domain/usecases/get_promotions_usecase.dart';
import 'package:makan_mate/features/vendor/domain/usecases/get_promotions_by_status_usecase.dart';
import 'package:makan_mate/features/vendor/domain/usecases/add_promotion_usecase.dart';
import 'package:makan_mate/features/vendor/domain/usecases/update_promotion_usecase.dart';
import 'package:makan_mate/features/vendor/domain/usecases/delete_promotion_usecase.dart';
import 'package:makan_mate/features/vendor/domain/usecases/deactivate_promotion_usecase.dart';
import 'package:makan_mate/features/vendor/domain/usecases/increment_promotion_click_usecase.dart';
import 'package:makan_mate/features/vendor/domain/usecases/increment_promotion_redeemed_usecase.dart';
import 'package:makan_mate/features/vendor/domain/usecases/watch_approved_promotions_usecase.dart';
import 'package:makan_mate/features/vendor/domain/usecases/increment_promotion_click_for_user_usecase.dart';
import 'package:makan_mate/features/vendor/domain/usecases/increment_promotion_redeemed_for_user_usecase.dart';
import 'package:makan_mate/features/promotions/data/datasources/user_promotion_remote_datasource.dart';
import 'package:makan_mate/features/promotions/data/repositories/user_promotion_repository_impl.dart';
import 'package:makan_mate/features/promotions/domain/user_promotion_repository.dart';
import 'package:makan_mate/features/promotions/domain/usecases/watch_user_promotions_usecase.dart';
import 'package:makan_mate/features/promotions/presentation/bloc/user_promotion_bloc.dart';
import 'package:makan_mate/features/vendor/presentation/bloc/vendor_bloc.dart';
import 'package:makan_mate/features/vendor/presentation/bloc/promotion_bloc.dart';
import 'package:makan_mate/features/vendor/presentation/bloc/vendor_review_bloc.dart';
import 'package:makan_mate/features/vendor/data/repositories/review_repository_impl.dart';
import 'package:makan_mate/features/vendor/domain/repositories/review_repository.dart';
import 'package:makan_mate/features/vendor/domain/usecases/watch_vendor_reviews_usecase.dart';
import 'package:makan_mate/features/vendor/domain/usecases/reply_to_review_usecase.dart';
import 'package:makan_mate/features/vendor/domain/usecases/report_review_usecase.dart';
import 'package:makan_mate/features/vendor/data/datasources/vendor_profile_remote_datasource.dart';
import 'package:makan_mate/features/vendor/data/repositories/vendor_profile_repository_impl.dart';
import 'package:makan_mate/features/vendor/domain/repositories/vendor_profile_repository.dart';
import 'package:makan_mate/features/vendor/domain/usecases/get_vendor_profile_usecase.dart';
import 'package:makan_mate/features/vendor/domain/usecases/update_vendor_profile_usecase.dart';
import 'package:makan_mate/features/vendor/domain/usecases/create_vendor_profile_usecase.dart';
import 'package:makan_mate/features/vendor/presentation/bloc/vendor_profile_bloc.dart';
import 'package:makan_mate/features/vendor/domain/usecases/get_all_approved_vendors_usecase.dart';
import 'package:makan_mate/features/vendor/domain/usecases/get_vendor_menu_items_usecase.dart';
import 'package:makan_mate/features/vendor/data/datasources/analytics_remote_datasource.dart';
import 'package:makan_mate/features/vendor/data/repositories/analytics_repository_impl.dart';
import 'package:makan_mate/features/vendor/domain/repositories/analytics_repository.dart';
import 'package:makan_mate/features/vendor/presentation/bloc/analytics_bloc.dart';
import 'package:makan_mate/features/vendor/data/services/promotion_analytics_service.dart';
import 'package:makan_mate/features/splash/data/datasources/splash_local_datasource.dart';
import 'package:makan_mate/features/splash/data/repositories/splash_repository_impl.dart';
import 'package:makan_mate/features/splash/domain/repositories/splash_repository.dart';
import 'package:makan_mate/features/splash/domain/usecases/check_onboarding_status_usecase.dart';
import 'package:makan_mate/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:makan_mate/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:makan_mate/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:makan_mate/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:makan_mate/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'package:makan_mate/features/onboarding/domain/usecases/get_onboarding_pages_usecase.dart';
import 'package:makan_mate/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:makan_mate/features/tickets/data/datasources/ticket_remote_datasource.dart';
import 'package:makan_mate/features/tickets/data/repositories/ticket_repository_impl.dart';
import 'package:makan_mate/features/tickets/domain/repositories/ticket_repository.dart';
import 'package:makan_mate/features/tickets/domain/usecases/get_support_tickets_usecase.dart';
import 'package:makan_mate/features/tickets/domain/usecases/respond_to_support_ticket_usecase.dart';
import 'package:makan_mate/features/analytics/data/datasources/user_analytics_remote_datasource.dart';
import 'package:makan_mate/features/analytics/data/repositories/user_analytics_repository_impl.dart';
import 'package:makan_mate/features/analytics/domain/repositories/user_analytics_repository.dart';
import 'package:makan_mate/features/analytics/domain/usecases/get_user_analytics_usecase.dart';
import 'package:makan_mate/core/navigation/admin_nav_controller.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_user_analytics_bloc.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_support_ticket_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Order matters for clarity: External → Core → Features
  await _initExternal();
  await _initCore();
  _initSplash();
  _initOnboarding();
  _initAuth();
  _initHome();
  await _initRecommendations();
  _initAdmin();
  _initTickets();
  _initAnalytics();
  _initReviews();
  _initFood();
  _initUser();
  _initVendor();
}

// ---------------------------
// Splash
// ---------------------------
void _initSplash() {
  // Logger for splash
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  // BLoC
  sl.registerFactory(
    () => SplashBloc(
      checkOnboardingStatus: sl(),
      logger: logger,
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => CheckOnboardingStatusUseCase(sl()));

  // Repository
  sl.registerLazySingleton<SplashRepository>(
    () => SplashRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<SplashLocalDataSource>(
    () => SplashLocalDataSourceImpl(sharedPreferences: sl()),
  );
}

// ---------------------------
// Onboarding
// ---------------------------
void _initOnboarding() {
  // Logger for onboarding
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  // BLoC
  sl.registerFactory(
    () => OnboardingBloc(
      getOnboardingPages: sl(),
      completeOnboarding: sl(),
      logger: logger,
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetOnboardingPagesUseCase(sl()));
  sl.registerLazySingleton(() => CompleteOnboardingUseCase(sl()));

  // Repository
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(sharedPreferences: sl()),
  );
}

// ---------------------------
// Auth
// ---------------------------
void _initAuth() {
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      signIn: sl(),
      signUp: sl(),
      signOut: sl(),
      googleSignIn: sl(),
      forgotPassword: sl(),
      deleteAccount: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase());

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      // googleSignIn is optional in the impl; we only register it on mobile,
      // so passing sl<GoogleSignIn>() is not required here.
    ),
  );

  // Local DS: SharedPreferences on web, SecureStorage on mobile (optional best-practice)
  if (kIsWeb) {
    sl.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
    );
  } else {
    // If you want to keep SharedPreferences on mobile, swap this to AuthLocalDataSourceImpl.
    sl.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalSecureDataSourceImpl(storage: sl()),
    );
  }
}

// void _initAdmin() {
//   // Logger for admin
//   final logger = Logger(
//     printer: PrettyPrinter(
//       methodCount: 2,
//       errorMethodCount: 5,
//       lineLength: 80,
//       colors: true,
//       printEmojis: true,
//     ),
//   );

//   // BLoC
//   sl.registerFactory(
//     () => AdminBloc(
//       getPlatformMetrics: sl(),
//       getMetricTrend: sl(),
//       getActivityLogs: sl(),
//       getNotifications: sl(),
//       exportMetrics: sl(),
//       streamSystemMetrics: sl(),
//       adminRepository: sl(),
//       logger: logger,
//     ),
//   );

//   // Use cases
//   sl.registerLazySingleton(() => GetPlatformMetricsUseCase(sl()));
//   sl.registerLazySingleton(() => GetMetricTrendUseCase(sl()));
//   sl.registerLazySingleton(() => GetActivityLogsUseCase(sl()));
//   sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
//   sl.registerLazySingleton(() => ExportMetricsUseCase(sl()));
//   sl.registerLazySingleton(() => StreamSystemMetricsUseCase(sl()));

//   // Repository
//   sl.registerLazySingleton<AdminRepository>(
//     () => AdminRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
//   );

//   // Data sources
//   sl.registerLazySingleton<AdminRemoteDataSource>(
//     () => AdminRemoteDataSourceImpl(firestore: sl(), logger: logger),
//   );

//   // Services
//   sl.registerLazySingleton<AuditLogService>(
//     () => AuditLogService(firestore: sl(), auth: sl(), logger: logger),
//   );
// }

// ---------------------------
// Home / Restaurants
// ---------------------------
void _initHome() {
  // Repository
  sl.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(remote: sl()),
  );

  // Data sources
  sl.registerLazySingleton<RestaurantRemoteDataSource>(
    () => RestaurantRemoteDataSourceImpl(firestore: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetRestaurantsUseCase(sl()));
  
  // Bloc
  sl.registerFactory(
    () => HomeBloc(getRestaurantDetails: sl(), getRestaurants: sl()),
  );
}

// ---------------------------
// Core
// ---------------------------
Future<void> _initCore() async {
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  // Admin navigation controller to enable in-shell navigation requests
  if (!sl.isRegistered<AdminNavController>()) {
    sl.registerLazySingleton<AdminNavController>(() => AdminNavController());
  }
}

// ---------------------------
// External
// ---------------------------
Future<void> _initExternal() async {
  // Hive initialization (must be done before opening any boxes)
  // initFlutter() is idempotent and safe to call multiple times
  await Hive.initFlutter();

  // SharedPreferences (web & mobile)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Secure storage (mobile only)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    sl.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    );
  }

  // Firebase
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  // Connectivity
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
}

// ---------------------------
// Recommendations
// ---------------------------
Future<void> _initRecommendations() async {
  // Logger for recommendations
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  // Initialize Hive box for caching recommendations
  final recommendationBox = await Hive.openBox('recommendations');

  // Core dependencies
  if (!sl.isRegistered<RecommendationEngine>()) {
    sl.registerLazySingleton<RecommendationEngine>(
      () => RecommendationEngine(),
    );
  }

  // Data sources
  sl.registerLazySingleton<RecommendationRemoteDataSource>(
    () => RecommendationRemoteDataSourceImpl(
      firestore: sl(),
      storage: sl(),
      engine: sl<RecommendationEngine>(),
      logger: logger,
    ),
  );

  sl.registerLazySingleton<RecommendationLocalDataSource>(
    () => RecommendationLocalDataSourceImpl(
      recommendationBox: recommendationBox,
      logger: logger,
    ),
  );

  // Repository
  sl.registerLazySingleton<RecommendationRepository>(
    () => RecommendationRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      logger: logger,
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetRecommendationsUseCase(sl()));
  sl.registerLazySingleton(() => GetContextualRecommendationsUseCase(sl()));
  sl.registerLazySingleton(() => GetSimilarItemsUseCase(sl()));
  sl.registerLazySingleton(() => TrackInteractionUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => RecommendationBloc(
      getRecommendations: sl(),
      getContextualRecommendations: sl(),
      getSimilarItems: sl(),
      trackInteraction: sl(),
      logger: logger,
    ),
  );
}

// ---------------------------
// Admin
// ---------------------------
void _initAdmin() {
  // Logger for admin
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  // BLoC
  sl.registerFactory(
    () => AdminBloc(
      getPlatformMetrics: sl(),
      getMetricTrend: sl(),
      getActivityLogs: sl(),
      getNotifications: sl(),
      getDataQualityMetrics: sl(),
      getFairnessMetrics: sl(),
      getSeasonalTrends: sl(),
      exportMetrics: sl(),
      streamSystemMetrics: sl(),
      adminRepository: sl(),
      logger: logger,
    ),
  );

  sl.registerFactory(() => AdminUserManagementBloc(repository: sl()));

  sl.registerFactory(
    () => AdminReviewManagementBloc(
      getFlaggedReviewsUseCase: sl(),
      getAllReviewsUseCase: sl(),
      approveReviewUseCase: sl(),
      flagReviewUseCase: sl(),
      removeReviewUseCase: sl(),
      dismissFlaggedReviewUseCase: sl(),
    ),
  );
  sl.registerFactory(() => AdminSupportTicketBloc(
        getSupportTickets: sl(),
        respondToSupportTicket: sl(),
      ));

  sl.registerFactory(
    () => AdminVoucherManagementBloc(
      getPendingVouchersUseCase: sl(),
      approveVoucherUseCase: sl(),
      rejectVoucherUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPlatformMetricsUseCase(sl()));
  sl.registerLazySingleton(() => GetMetricTrendUseCase(sl()));
  sl.registerLazySingleton(() => GetActivityLogsUseCase(sl()));
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => ExportMetricsUseCase(sl()));
  sl.registerLazySingleton(() => StreamSystemMetricsUseCase(sl()));
  sl.registerLazySingleton(() => GetFairnessMetricsUseCase(sl()));
  sl.registerLazySingleton(() => GetSeasonalTrendsUseCase(sl()));
  sl.registerLazySingleton(() => GetDataQualityMetricsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(firestore: sl(), logger: logger),
  );

  // Management datasources
  sl.registerLazySingleton<AdminVendorManagementDataSource>(
    () => AdminVendorManagementDataSource(
      firestore: sl(),
      auth: sl(),
      logger: logger,
      auditLogService: sl(),
    ),
  );

  // Management repositories
  sl.registerLazySingleton<AdminVendorRepository>(
    () => AdminVendorRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton<AdminUserManagementDataSource>(
    () => AdminUserManagementDataSource(
      firestore: sl(),
      auth: sl(),
      logger: logger,
      auditLogService: sl(),
    ),
  );

  sl.registerLazySingleton<AdminUserRepository>(
    () => AdminUserRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton<AdminPromotionManagementDataSource>(
    () => AdminPromotionManagementDataSource(
      firestore: sl(),
      auth: sl(),
      logger: logger,
      auditLogService: sl(),
    ),
  );

  sl.registerLazySingleton<AdminVoucherManagementDataSource>(
    () => AdminVoucherManagementDataSource(
      firestore: sl(),
      auth: sl(),
      logger: logger,
      auditLogService: sl(),
    ),
  );

  sl.registerLazySingleton<AdminReviewManagementDataSource>(
    () => AdminReviewManagementDataSource(
      firestore: sl(),
      auth: sl(),
      logger: logger,
      auditLogService: sl(),
    ),
  );

  sl.registerLazySingleton<AdminMenuManagementDataSource>(
    () => AdminMenuManagementDataSource(
      firestore: sl(),
      auth: sl(),
      logger: logger,
      auditLogService: sl(),
    ),
  );

  // Review management repository
  sl.registerLazySingleton<AdminReviewRepository>(
    () => AdminReviewRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Services
  sl.registerLazySingleton<AuditLogService>(
    () => AuditLogService(firestore: sl(), auth: sl(), logger: logger),
  );

  // Management use cases
  sl.registerLazySingleton(() => GetVendorsUseCase(sl()));
  sl.registerLazySingleton(() => ApproveVendorUseCase(sl()));
  sl.registerLazySingleton(() => RejectVendorUseCase(sl()));
  sl.registerLazySingleton(() => GetPendingPromotionsUseCase(sl()));
  sl.registerLazySingleton(() => ApprovePromotionUseCase(sl()));

  // Voucher management use cases
  sl.registerLazySingleton(() => GetPendingVouchersUseCase(sl(), sl()));
  sl.registerLazySingleton(() => ApproveVoucherUseCase(sl(), sl()));
  sl.registerLazySingleton(() => RejectVoucherUseCase(sl(), sl()));

  // Review management use cases
  sl.registerLazySingleton(() => GetFlaggedReviewsUseCase(sl()));
  sl.registerLazySingleton(() => GetAllReviewsUseCase(sl()));
  sl.registerLazySingleton(() => ApproveReviewUseCase(sl()));
  sl.registerLazySingleton(() => RemoveReviewUseCase(sl()));
  sl.registerLazySingleton(() => DismissFlaggedReviewUseCase(sl()));

  sl.registerLazySingleton(() => GetPendingMenuItemsUseCase(sl()));
  sl.registerLazySingleton(() => ApproveMenuItemUseCase(sl()));

  // User management use cases
  sl.registerLazySingleton(() => GetUsersUseCase(sl()));
  sl.registerLazySingleton(() => GetUserByIdUseCase(sl()));
  sl.registerLazySingleton(() => VerifyUserUseCase(sl()));
  sl.registerLazySingleton(() => BanUserUseCase(sl()));
  sl.registerLazySingleton(() => UnbanUserUseCase(sl()));
  sl.registerLazySingleton(() => WarnUserUseCase(sl()));
  sl.registerLazySingleton(() => GetUserViolationHistoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteUserDataUseCase(sl()));
}

// ---------------------------
// Tickets
// ---------------------------
void _initTickets() {
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );
  // Data source
  sl.registerLazySingleton<TicketRemoteDataSource>(
    () => TicketRemoteDataSourceImpl(firestore: sl(), logger: logger),
  );
  // Repository
  sl.registerLazySingleton<TicketRepository>(
    () => TicketRepositoryImpl(remote: sl(), networkInfo: sl()),
  );
  // Use case
  sl.registerLazySingleton(() => GetSupportTicketsUseCase(sl()));
  sl.registerLazySingleton(() => RespondToSupportTicketUseCase(sl()));
}

// ---------------------------
// User Analytics
// ---------------------------
void _initAnalytics() {
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );
  // Data source
  sl.registerLazySingleton<UserAnalyticsRemoteDataSource>(
    () => UserAnalyticsRemoteDataSourceImpl(firestore: sl(), logger: logger),
  );
  // Repository
  sl.registerLazySingleton<UserAnalyticsRepository>(
    () => UserAnalyticsRepositoryImpl(remote: sl(), networkInfo: sl()),
  );
  // Use case
  sl.registerLazySingleton(() => GetUserAnalyticsUseCase(sl()));
  // Bloc
  sl.registerFactory(() => AdminUserAnalyticsBloc(getUserAnalytics: sl()));
}
// ---------------------------
// Reviews
// ---------------------------
void _initReviews() {
  // BLoC
  // sl.registerFactory(
  //   () => ReviewBloc(
  //     submitReview: sl(),
  //     getRestaurantReviews: sl(),
  //     getItemReviews: sl(),
  //     flagReview: sl(),
  //     logger: logger,
  //   ),
  // );

  // Use cases
  sl.registerLazySingleton(() => SubmitReviewUseCase(sl()));
  sl.registerLazySingleton(() => GetRestaurantReviewsUseCase(sl()));
  sl.registerLazySingleton(() => GetItemReviewsUseCase(sl()));
  sl.registerLazySingleton(() => FlagReviewUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ReviewRepository>(() => ReviewRepositoryImpl());

  // Data sources
  sl.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSourceImpl(firestore: sl()),
  );
}

// ---------------------------
// Food
// ---------------------------
void _initFood() {
  // Use cases
  sl.registerLazySingleton(() => GetFoodItemUseCase(sl()));
  sl.registerLazySingleton(() => GetFoodItemsByRestaurantUseCase(sl()));
  sl.registerLazySingleton(() => SearchFoodItemsUseCase(sl()));
  sl.registerLazySingleton(() => GetPopularFoodItemsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<FoodRepository>(
    () => FoodRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<FoodRemoteDataSource>(
    () => FoodRemoteDataSourceImpl(firestore: sl()),
  );
}

// ---------------------------
// User
// ---------------------------
void _initUser() {
  // Use cases
  sl.registerLazySingleton(() => GetUserUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserPreferencesUseCase(sl()));
  sl.registerLazySingleton(() => UpdateBehavioralPatternsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(firestore: sl()),
  );
}

// ---------------------------
// Vendor
// ---------------------------
void _initVendor() {
  // Repository
  sl.registerLazySingleton<VendorRepository>(
    () => VendorRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => CheckUserRedemptionUseCase(sl()));
  sl.registerLazySingleton(() => RedeemPromotionUseCase(sl()));
  // Data sources
  sl.registerLazySingleton<VendorRemoteDataSource>(
    () => VendorRemoteDataSourceImpl(),
  );
  // Map Feature
  sl.registerLazySingleton<MapRemoteDataSource>(
    () => MapRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<MapRepository>(() => MapRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetNearbyRestaurantsUseCase(sl()));
  sl.registerFactory(() => MapBloc(sl()));

  sl.registerLazySingleton<StorageService>(() => StorageService());

  sl.registerLazySingleton(() => GetMenuItemsUseCase(sl()));
  sl.registerLazySingleton(() => AddMenuItemUseCase(sl()));
  sl.registerLazySingleton(() => UpdateMenuItemUseCase(sl()));
  sl.registerLazySingleton(() => DeleteMenuItemUseCase(sl()));

  sl.registerFactory(
    () => VendorBloc(
      getMenuItems: sl(),
      addMenuItem: sl(),
      updateMenuItem: sl(),
      deleteMenuItem: sl(),
      storageService: sl(),
    ),
  );

  // Promotion Feature
  sl.registerLazySingleton<PromotionRemoteDataSource>(
    () => PromotionRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<PromotionRepository>(
    () => PromotionRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetPromotionsUseCase(sl()));
  sl.registerLazySingleton(() => GetPromotionsByStatusUseCase(sl()));
  sl.registerLazySingleton(() => AddPromotionUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePromotionUseCase(sl()));
  sl.registerLazySingleton(() => DeletePromotionUseCase(sl()));
  sl.registerLazySingleton(() => DeactivatePromotionUseCase(sl()));
  sl.registerLazySingleton(() => IncrementPromotionClickUseCase(sl()));
  sl.registerLazySingleton(() => IncrementPromotionRedeemedUseCase(sl()));
  sl.registerLazySingleton(() => WatchApprovedPromotionsUseCase(sl()));
  sl.registerLazySingleton(() => IncrementPromotionClickForUserUseCase(sl()));
  sl.registerLazySingleton(() => IncrementPromotionRedeemedForUserUseCase(sl()));

  sl.registerFactory(
    () => PromotionBloc(
      getPromotions: sl(),
      getPromotionsByStatus: sl(),
      addPromotion: sl(),
      updatePromotion: sl(),
      deletePromotion: sl(),
      deactivatePromotion: sl(),
      incrementPromotionClick: sl(),
      incrementPromotionRedeemed: sl(),
      storageService: sl(),
    ),
  );

  sl.registerLazySingleton(() => WatchVendorReviewsUseCase(sl()));
  sl.registerLazySingleton(() => ReplyToReviewUseCase(sl()));
  sl.registerLazySingleton(() => ReportReviewUseCase(sl()));

  sl.registerFactory(
    () => VendorReviewBloc(
      watchReviews: sl(),
      replyToReview: sl(),
      reportReview: sl(),
    ),
  );

  // User Promotion Feature
  sl.registerLazySingleton<UserPromotionRemoteDataSource>(
    () => UserPromotionRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<UserPromotionRepository>(
    () => UserPromotionRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => WatchUserPromotionsUseCase(sl()));

  sl.registerFactory(
    () => UserPromotionBloc(
      watchUserPromotions: sl(),
      incrementClick: sl(),
      incrementRedeemed: sl(),
    ),
  );

  // Vendor Profile Feature
  sl.registerLazySingleton<VendorProfileRemoteDataSource>(
    () => VendorProfileRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<VendorProfileRepository>(
    () => VendorProfileRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetVendorProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateVendorProfileUseCase(sl()));
  sl.registerLazySingleton(() => CreateVendorProfileUseCase(sl()));

  sl.registerFactory(
    () => VendorProfileBloc(
      getVendorProfile: sl(),
      updateVendorProfile: sl(),
      createVendorProfile: sl(),
      storageService: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<GetVendorMenuItemsUseCase>(
    () => GetVendorMenuItemsUseCase(sl()),
  );
  sl.registerLazySingleton<GetAllApprovedVendorsUseCase>(
    () => GetAllApprovedVendorsUseCase(sl()),
  );
  sl.registerLazySingleton<GetRestaurantDetailsUseCase>(
    () => GetRestaurantDetailsUseCase(sl()),
  );

  // Analytics Feature
  sl.registerLazySingleton<AnalyticsRemoteDataSource>(
    () => AnalyticsRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerFactory(
    () => AnalyticsBloc(analyticsRepository: sl()),
  );

  // Promotion Analytics Service
  sl.registerLazySingleton<PromotionAnalyticsService>(
    () => PromotionAnalyticsService(firestore: sl()),
  );

  // Restaurant DataSources
  sl.registerLazySingleton<SearchRemoteDataSource>(() => SearchRemoteDataSourceImpl(
        firestore: sl(),
        firebaseAuth: sl(),
      ));

  // Repositories
  sl.registerLazySingleton<SearchRepository>(() => SearchRepositoryImpl(
        remoteDataSource: sl(),
        networkInfo: sl(),
      ));

  // Usecases
  sl.registerLazySingleton(() => SearchRestaurantUsecase(sl()));
  sl.registerLazySingleton(() => SearchFoodUsecase(sl()));
  sl.registerLazySingleton(() => GetSearchHistoryUsecase(sl()));
  sl.registerLazySingleton(() => AddSearchHistoryUsecase(sl()));

  // Bloc
  sl.registerFactory(() => SearchBloc(
        searchRestaurantUsecase: sl(),
        searchFoodUsecase: sl(),
        getSearchHistoryUsecase: sl(),
        addSearchHistoryUsecase: sl(),
      ));


}
