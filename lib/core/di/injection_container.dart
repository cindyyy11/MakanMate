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
}
