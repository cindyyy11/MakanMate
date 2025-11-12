import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/features/map/data/datasources/map_remote_datasource.dart';
import 'package:makan_mate/features/map/domain/repositories/map_repository.dart';
import 'package:makan_mate/features/map/domain/repositories/map_repository_impl.dart';
import 'package:makan_mate/features/map/domain/usecases/get_nearby_restaurants_usecase.dart';
import 'package:makan_mate/features/map/presentation/bloc/map_bloc.dart';

// Home Feature imports
import '../../features/home/data/datasources/restaurant_remote_datasource.dart';
import '../../features/home/data/repositories/restaurant_repository_impl.dart';
import '../../features/home/domain/repositories/restaurant_repository.dart';
import '../../features/home/domain/usecases/get_categories_usecase.dart';
import '../../features/home/domain/usecases/get_recommendations_usecase.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

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

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Data source
  sl.registerLazySingleton<RestaurantRemoteDataSource>(
      () => RestaurantRemoteDataSource(sl()));

  // Repository
  sl.registerLazySingleton<RestaurantRepository>(
      () => RestaurantRepositoryImpl(sl()));

  // Use cases
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetRecommendationsUseCase(sl()));

  // Bloc
  sl.registerFactory(() => HomeBloc(
        getCategoriesUseCase: sl(),
        getRecommendationsUseCase: sl(),
      ));

  // Map Feature
    sl.registerLazySingleton<MapRemoteDataSource>(() => MapRemoteDataSourceImpl());
    sl.registerLazySingleton<MapRepository>(() => MapRepositoryImpl(sl()));
    sl.registerLazySingleton(() => GetNearbyRestaurantsUseCase(sl()));
    sl.registerFactory(() => MapBloc(sl()));

    // Vendor Feature
    sl.registerLazySingleton<VendorRemoteDataSource>(
      () => VendorRemoteDataSourceImpl(),
    );

    sl.registerLazySingleton<StorageService>(
      () => StorageService(),
    );

    sl.registerLazySingleton<VendorRepository>(
      () => VendorRepositoryImpl(remoteDataSource: sl()),
    );

    sl.registerLazySingleton(() => GetMenuItemsUseCase(sl()));
    sl.registerLazySingleton(() => AddMenuItemUseCase(sl()));
    sl.registerLazySingleton(() => UpdateMenuItemUseCase(sl()));
    sl.registerLazySingleton(() => DeleteMenuItemUseCase(sl()));

    sl.registerFactory(() => VendorBloc(
      getMenuItems: sl(),
      addMenuItem: sl(),
      updateMenuItem: sl(),
      deleteMenuItem: sl(),
      storageService: sl(),
    ));

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

    sl.registerFactory(() => PromotionBloc(
      getPromotions: sl(),
      getPromotionsByStatus: sl(),
      addPromotion: sl(),
      updatePromotion: sl(),
      deletePromotion: sl(),
      deactivatePromotion: sl(),
      storageService: sl(),
    ));

    // Review Feature
    sl.registerLazySingleton<ReviewRepository>(
      () => ReviewRepositoryImpl(),
    );

    sl.registerLazySingleton(() => WatchVendorReviewsUseCase(sl()));
    sl.registerLazySingleton(() => ReplyToReviewUseCase(sl()));
    sl.registerLazySingleton(() => ReportReviewUseCase(sl()));

    sl.registerFactory(() => VendorReviewBloc(
      watchReviews: sl(),
      replyToReview: sl(),
      reportReview: sl(),
    ));
}
