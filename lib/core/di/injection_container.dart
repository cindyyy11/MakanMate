import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/features/home/domain/usecases/get_restaurant_details_usecase.dart';
import 'package:makan_mate/features/map/data/datasources/map_remote_datasource.dart';
import 'package:makan_mate/features/map/domain/repositories/map_repository.dart';
import 'package:makan_mate/features/map/domain/repositories/map_repository_impl.dart';
import 'package:makan_mate/features/map/domain/usecases/get_nearby_restaurants_usecase.dart';
import 'package:makan_mate/features/map/presentation/bloc/map_bloc.dart';
import 'package:makan_mate/features/vendor/data/datasources/vendor_remote_datasource.dart';
import 'package:makan_mate/features/vendor/data/repositories/vendor_repository_impl.dart';
import 'package:makan_mate/features/vendor/domain/repositories/vendor_repository.dart';
import 'package:makan_mate/features/vendor/domain/usecases/get_all_approved_vendors_usecase.dart';
import 'package:makan_mate/features/vendor/domain/usecases/get_vendor_menu_items_usecase.dart';
import 'package:makan_mate/features/vendor/domain/usecases/get_vendor_profile_usecase.dart';
import 'package:makan_mate/features/vendor/presentation/bloc/vendor_bloc.dart';
import '../../features/home/data/datasources/restaurant_remote_datasource.dart';
import '../../features/home/data/repositories/restaurant_repository_impl.dart';
import '../../features/home/domain/repositories/restaurant_repository.dart';
import '../../features/home/domain/usecases/get_categories_usecase.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Data source
  sl.registerLazySingleton<VendorRemoteDataSource>(
      () => VendorRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<MapRemoteDataSource>(
      () => MapRemoteDataSourceImpl());
  sl.registerLazySingleton<RestaurantRemoteDataSource>(
    () => RestaurantRemoteDataSourceImpl(sl()));

  // Repository
  sl.registerLazySingleton<RestaurantRepository>(
      () => RestaurantRepositoryImpl(sl()));
    sl.registerLazySingleton<MapRepository>(() => MapRepositoryImpl(sl()));
    sl.registerLazySingleton<VendorRepository>(
      () => VendorRepositoryImpl(sl()));

  // Use cases
  sl.registerLazySingleton<GetNearbyRestaurantsUseCase>(
    () => GetNearbyRestaurantsUseCase(sl()));
  sl.registerLazySingleton<GetVendorMenuItemsUseCase>(
    () => GetVendorMenuItemsUseCase(sl()));
  sl.registerLazySingleton<GetVendorProfileUseCase>(
    () => GetVendorProfileUseCase(sl()));
  sl.registerLazySingleton<GetAllApprovedVendorsUseCase>(
    () => GetAllApprovedVendorsUseCase(sl()));
  sl.registerLazySingleton<GetRestaurantsUseCase>(
    () => GetRestaurantsUseCase(sl()));
  sl.registerLazySingleton<GetRestaurantDetailsUseCase>(
    () => GetRestaurantDetailsUseCase(sl()));

  // Bloc
  sl.registerFactory<VendorBloc>(() => VendorBloc(
    getVendorProfile: sl(),
    getVendorMenuItems: sl(),
  ));
  sl.registerFactory<HomeBloc>(() => HomeBloc(
      getRestaurants: sl(),
      getRestaurantDetails: sl(),
    ));
  sl.registerFactory(() => MapBloc(sl()));
   
}
