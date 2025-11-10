import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/exceptions.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/core/network/network_info.dart';
import 'package:makan_mate/features/restaurant/data/datasources/restaurant_remote_datasource.dart';
import 'package:makan_mate/features/restaurant/data/models/restaurant_models.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';
import 'package:makan_mate/features/home/domain/repositories/restaurant_repository.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  
  RestaurantRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, List<RestaurantEntity>>> getRestaurants({
    int? limit,
    String? cuisineType,
    bool? isHalal,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    
    try {
      final restaurants = await remoteDataSource.getRestaurants(
        limit: limit,
        cuisineType: cuisineType,
        isHalal: isHalal,
      );
      final entities = restaurants.map((r) => _toEntity(r)).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch restaurants'));
    }
  }
  
  @override
  Future<Either<Failure, RestaurantEntity>> getRestaurantById(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    
    try {
      final restaurant = await remoteDataSource.getRestaurantById(id);
      return Right(_toEntity(restaurant));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch restaurant'));
    }
  }
  
  /// Convert Restaurant model to RestaurantEntity
  RestaurantEntity _toEntity(Restaurant restaurant) {
    // Get first image URL or empty string
    final imageUrl = restaurant.imageUrls.isNotEmpty 
        ? restaurant.imageUrls.first 
        : '';
    
    // Get primary cuisine type or first one
    final cuisineType = restaurant.cuisineTypes.isNotEmpty 
        ? restaurant.cuisineTypes.first 
        : 'Other';
    
    // Convert opening hours map to list of strings
    final openingHours = restaurant.openingHours.entries
        .map((e) => '${e.key}: ${e.value}')
        .toList();
    
    // Determine price range based on delivery fee
    String priceRange;
    if (restaurant.deliveryFee < 5) {
      priceRange = '\$';
    } else if (restaurant.deliveryFee < 10) {
      priceRange = '\$\$';
    } else if (restaurant.deliveryFee < 20) {
      priceRange = '\$\$\$';
    } else {
      priceRange = '\$\$\$\$';
    }
    
    // Check if vegetarian (assuming amenities contain vegetarian info)
    final isVegetarian = restaurant.amenities.contains('vegetarian') || 
                        restaurant.amenities.any((a) => a.toLowerCase().contains('vegetarian'));
    
    return RestaurantEntity(
      id: restaurant.id,
      name: restaurant.name,
      description: restaurant.description,
      imageUrl: imageUrl,
      rating: restaurant.averageRating,
      address: restaurant.location.address ?? 
               '${restaurant.location.city ?? ''}, ${restaurant.location.state ?? ''}'.trim(),
      cuisineType: cuisineType,
      priceRange: priceRange,
      isHalal: restaurant.isHalalCertified,
      isVegetarian: isVegetarian,
      latitude: restaurant.location.latitude,
      longitude: restaurant.location.longitude,
      openingHours: openingHours,
    );
  }
}