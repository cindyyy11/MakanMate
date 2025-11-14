// import 'package:dartz/dartz.dart';
// import 'package:makan_mate/core/errors/exceptions.dart';
// import 'package:makan_mate/core/errors/failures.dart';
// import 'package:makan_mate/core/network/network_info.dart';
// import 'package:makan_mate/features/home/data/models/restaurant_model.dart';
// import 'package:makan_mate/features/restaurant/data/datasources/restaurant_remote_datasource.dart';
// import 'package:makan_mate/features/restaurant/data/models/restaurant_models.dart';
// import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';
// import 'package:makan_mate/features/home/domain/repositories/restaurant_repository.dart';

// class RestaurantRepositoryImpl implements RestaurantRepository {
//   final RestaurantRemoteDataSource remoteDataSource;
//   final NetworkInfo networkInfo;

//   RestaurantRepositoryImpl({
//     required this.remoteDataSource,
//     required this.networkInfo,
//   });

//   /// Convert Restaurant (data model) to RestaurantEntity (domain entity)
//   RestaurantEntity _toRestaurantEntity(RestaurantModel restaurant) {
//     print("in _toRestaurantEntity");
//     return RestaurantEntity(
//       id: restaurant.id,
//       name: restaurant.name,
//       description: restaurant.description,
//       imageUrl: restaurant.imageUrl ?? '',
//       rating: restaurant.rating,
//       address: restaurant.address ?? '',
//       cuisineType: restaurant.cuisineType ?? 'Other',
//       priceRange: restaurant.priceRange,
//       isHalal: restaurant.isHalal,
//       isVegetarian: restaurant.isVegetarian,
//       latitude: restaurant.latitude,
//       longitude: restaurant.longitude,
//       openingHours: restaurant.openingHours.toList(),
//     );
//   }

//   /// Calculate price range based on delivery fee
//   String _calculatePriceRange(double deliveryFee) {
//     if (deliveryFee <= 2.0) return '\$';
//     if (deliveryFee <= 5.0) return '\$\$';
//     if (deliveryFee <= 10.0) return '\$\$\$';
//     return '\$\$\$\$';
//   }

//   @override
//   Future<Either<Failure, List<RestaurantEntity>>> getRestaurants({
//     int? limit,
//     String? cuisineType,
//     bool? isHalal,
//   }) async {
//     if (!await networkInfo.isConnected) {
//       return const Left(NetworkFailure('No internet connection'));
//     }

//     try {
//       final restaurants = await remoteDataSource.getRestaurants(
//         limit: limit,
//         cuisineType: cuisineType,
//         isHalal: isHalal,
//       );
//       return Right(restaurants.map((r) => _toRestaurantEntity(r)).toList());
//     } on ServerException catch (e) {
//       return Left(ServerFailure(e.message));
//     } catch (e) {
//       return Left(ServerFailure('Failed to fetch restaurants: $e'));
//     }
//   }

//   @override
//   Future<Either<Failure, RestaurantEntity>> getRestaurantById(String id) async {
//     if (!await networkInfo.isConnected) {
//       return const Left(NetworkFailure('No internet connection'));
//     }

//     try {
//       final restaurant = await remoteDataSource.getRestaurantById(id);
//       return Right(_toRestaurantEntity(restaurant));
//     } on ServerException catch (e) {
//       return Left(ServerFailure(e.message));
//     } catch (e) {
//       return Left(ServerFailure('Failed to fetch restaurant: $e'));
//     }
//   }

//   @override
//   Future<List<RestaurantModel>> getCategories() async {
//     return await remoteDataSource.fetchCategories();
//   }

//   @override
//   Future<List<RestaurantModel>> getRecommendations() async {
//     return await remoteDataSource.fetchRecommendations();
//   }
// }
