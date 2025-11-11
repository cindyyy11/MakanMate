import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:makan_mate/core/network/network_info.dart';
import 'package:makan_mate/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:makan_mate/features/auth/data/datasources/auth_local_secure_datasource.dart';
import 'package:makan_mate/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:makan_mate/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:makan_mate/features/auth/domain/repositories/auth_repository.dart';
import 'package:makan_mate/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:makan_mate/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:makan_mate/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:makan_mate/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:makan_mate/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:makan_mate/features/restaurant/data/datasources/restaurant_remote_datasource.dart';
import 'package:makan_mate/features/restaurant/data/repositories/restaurant_repository_impl.dart';
import 'package:makan_mate/features/home/domain/repositories/restaurant_repository.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:makan_mate/ai_engine/recommendation_engine.dart';
import 'package:makan_mate/features/home/domain/usecases/get_restaurants_usecase.dart';
import 'package:makan_mate/features/home/presentation/bloc/home_bloc.dart';
import 'package:makan_mate/features/recommendations/data/datasources/recommendation_local_datasource.dart';
import 'package:makan_mate/features/recommendations/data/datasources/recommendation_remote_datasource.dart';
import 'package:makan_mate/features/recommendations/data/repositories/recommendation_repository_impl.dart';
import 'package:makan_mate/features/recommendations/domain/repositories/recommendation_repository.dart';
import 'package:makan_mate/features/recommendations/domain/usecases/get_contextual_recommendations_usecase.dart';
import 'package:makan_mate/features/recommendations/domain/usecases/get_recommendations_usecase.dart';
import 'package:makan_mate/features/recommendations/domain/usecases/get_similar_items_usecase.dart';
import 'package:makan_mate/features/recommendations/domain/usecases/track_interaction_usecase.dart';
import 'package:makan_mate/features/recommendations/presentation/bloc/recommendation_bloc.dart';
import 'package:makan_mate/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:makan_mate/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_repository.dart';
import 'package:makan_mate/features/admin/domain/usecases/export_metrics_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_activity_logs_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_metric_trend_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_notifications_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_platform_metrics_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/stream_system_metrics_usecase.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:makan_mate/features/reviews/data/datasources/review_remote_datasource.dart';
import 'package:makan_mate/features/reviews/data/repositories/review_repository_impl.dart';
import 'package:makan_mate/features/reviews/domain/repositories/review_repository.dart';
import 'package:makan_mate/features/reviews/domain/usecases/flag_review_usecase.dart';
import 'package:makan_mate/features/reviews/domain/usecases/get_item_reviews_usecase.dart';
import 'package:makan_mate/features/reviews/domain/usecases/get_restaurant_reviews_usecase.dart';
import 'package:makan_mate/features/reviews/domain/usecases/submit_review_usecase.dart';
import 'package:makan_mate/features/reviews/presentation/bloc/review_bloc.dart';
import 'package:makan_mate/features/food/data/datasources/food_remote_datasource.dart';
import 'package:makan_mate/features/food/data/repositories/food_repository_impl.dart';
import 'package:makan_mate/features/food/domain/repositories/food_repository.dart';
import 'package:makan_mate/features/food/domain/usecases/get_food_item_usecase.dart';
import 'package:makan_mate/features/food/domain/usecases/get_food_items_by_restaurant_usecase.dart';
import 'package:makan_mate/features/food/domain/usecases/search_food_items_usecase.dart';
import 'package:makan_mate/features/food/domain/usecases/get_popular_food_items_usecase.dart';
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
import 'package:makan_mate/features/vendor/domain/usecases/create_vendor_application_usecase.dart';
import 'package:makan_mate/features/vendor/domain/usecases/get_vendor_application_usecase.dart';
import 'package:makan_mate/features/vendor/domain/usecases/approve_vendor_application_usecase.dart';
import 'package:makan_mate/features/vendor/domain/usecases/reject_vendor_application_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Order matters for clarity: External → Core → Features
  await _initExternal();
  await _initCore();
  _initAuth();
  _initHome();
  await _initRecommendations();
  _initAdmin();
  _initReviews();
  _initFood();
  _initUser();
  _initVendor();
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
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));

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

// ---------------------------
// Home / Restaurants
// ---------------------------
void _initHome() {
  // Bloc
  sl.registerFactory(() => HomeBloc(getRestaurants: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetRestaurantsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<RestaurantRemoteDataSource>(
    () => RestaurantRemoteDataSourceImpl(firestore: sl()),
  );
}

// ---------------------------
// Core
// ---------------------------
Future<void> _initCore() async {
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
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
      exportMetrics: sl(),
      streamSystemMetrics: sl(),
      adminRepository: sl(),
      logger: logger,
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPlatformMetricsUseCase(sl()));
  sl.registerLazySingleton(() => GetMetricTrendUseCase(sl()));
  sl.registerLazySingleton(() => GetActivityLogsUseCase(sl()));
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => ExportMetricsUseCase(sl()));
  sl.registerLazySingleton(() => StreamSystemMetricsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(firestore: sl(), logger: logger),
  );
}

// ---------------------------
// Reviews
// ---------------------------
void _initReviews() {
  // Logger for reviews
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
    () => ReviewBloc(
      submitReview: sl(),
      getRestaurantReviews: sl(),
      getItemReviews: sl(),
      flagReview: sl(),
      logger: logger,
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SubmitReviewUseCase(sl()));
  sl.registerLazySingleton(() => GetRestaurantReviewsUseCase(sl()));
  sl.registerLazySingleton(() => GetItemReviewsUseCase(sl()));
  sl.registerLazySingleton(() => FlagReviewUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
      logger: logger,
    ),
  );

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
  // Use cases
  sl.registerLazySingleton(() => CreateVendorApplicationUseCase(sl()));
  sl.registerLazySingleton(() => GetVendorApplicationUseCase(sl()));
  sl.registerLazySingleton(() => ApproveVendorApplicationUseCase(sl()));
  sl.registerLazySingleton(() => RejectVendorApplicationUseCase(sl()));

  // Repository
  sl.registerLazySingleton<VendorRepository>(
    () => VendorRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<VendorRemoteDataSource>(
    () => VendorRemoteDataSourceImpl(firestore: sl()),
  );
}
