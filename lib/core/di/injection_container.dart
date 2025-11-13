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
import 'package:makan_mate/features/home/domain/usecases/get_categories_usecase.dart';
import 'package:makan_mate/features/home/domain/usecases/get_recommendations_usecase.dart'
    as HomeGetRecommendationsUseCase;
import 'package:makan_mate/features/map/data/datasources/map_remote_datasource.dart';
import 'package:makan_mate/features/map/domain/repositories/map_repository.dart';
import 'package:makan_mate/features/map/domain/repositories/map_repository_impl.dart';
import 'package:makan_mate/features/map/domain/usecases/get_nearby_restaurants_usecase.dart';
import 'package:makan_mate/features/map/presentation/bloc/map_bloc.dart';
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

// Vendor Feature imports
import '../../features/vendor/data/datasources/vendor_remote_datasource.dart';
import '../../features/vendor/data/datasources/promotion_remote_datasource.dart';
import '../../features/vendor/data/repositories/vendor_repository_impl.dart';
import '../../features/vendor/data/repositories/promotion_repository_impl.dart';
import '../../features/vendor/data/services/storage_service.dart';
import '../../features/vendor/domain/repositories/vendor_repository.dart';
import '../../features/vendor/domain/repositories/promotion_repository.dart';
import '../../features/vendor/domain/usecases/add_menu_item_usecase.dart';
import '../../features/vendor/domain/usecases/delete_menu_item_usecase.dart';
import '../../features/vendor/domain/usecases/get_menu_items_usecase.dart';
import '../../features/vendor/domain/usecases/update_menu_item_usecase.dart';
import '../../features/vendor/domain/usecases/get_promotions_usecase.dart';
import '../../features/vendor/domain/usecases/get_promotions_by_status_usecase.dart';
import '../../features/vendor/domain/usecases/add_promotion_usecase.dart';
import '../../features/vendor/domain/usecases/update_promotion_usecase.dart';
import '../../features/vendor/domain/usecases/delete_promotion_usecase.dart';
import '../../features/vendor/domain/usecases/deactivate_promotion_usecase.dart';
import '../../features/vendor/presentation/bloc/vendor_bloc.dart';
import '../../features/vendor/presentation/bloc/promotion_bloc.dart';
import '../../features/vendor/presentation/bloc/vendor_review_bloc.dart';
import '../../features/vendor/data/repositories/review_repository_impl.dart';
import '../../features/vendor/domain/repositories/review_repository.dart';
import '../../features/vendor/domain/usecases/watch_vendor_reviews_usecase.dart';
import '../../features/vendor/domain/usecases/reply_to_review_usecase.dart';
import '../../features/vendor/domain/usecases/report_review_usecase.dart';
import '../../features/vendor/data/datasources/vendor_profile_remote_datasource.dart';
import '../../features/vendor/data/repositories/vendor_profile_repository_impl.dart';
import '../../features/vendor/domain/repositories/vendor_profile_repository.dart';
import '../../features/vendor/domain/usecases/get_vendor_profile_usecase.dart';
import '../../features/vendor/domain/usecases/update_vendor_profile_usecase.dart';
import '../../features/vendor/domain/usecases/create_vendor_profile_usecase.dart';
import '../../features/vendor/presentation/bloc/vendor_profile_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

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
  sl.registerFactory(
    () => HomeBloc(
      getCategoriesUseCase: sl(),
      getRecommendationsUseCase: sl(),
      getRestaurants: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetRestaurantsUseCase(sl()));
  sl.registerLazySingleton(
    () => HomeGetRecommendationsUseCase.GetRecommendationsUseCase(sl()),
  );

  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));

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

  // Bloc
  sl.registerFactory(() => HomeBloc(
        getCategoriesUseCase: sl(),
        getRecommendationsUseCase: sl(),
      ));

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

  sl.registerFactory(
    () => PromotionBloc(
      getPromotions: sl(),
      getPromotionsByStatus: sl(),
      addPromotion: sl(),
      updatePromotion: sl(),
      deletePromotion: sl(),
      deactivatePromotion: sl(),
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
}
