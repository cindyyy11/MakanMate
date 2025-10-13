// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Restaurant _$RestaurantFromJson(Map<String, dynamic> json) => Restaurant(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  location: Location.fromJson(json['location'] as Map<String, dynamic>),
  phoneNumber: json['phoneNumber'] as String,
  email: json['email'] as String,
  openingHours:
      (json['openingHours'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  cuisineTypes:
      (json['cuisineTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
  totalRatings: (json['totalRatings'] as num?)?.toInt() ?? 0,
  isHalalCertified: json['isHalalCertified'] as bool? ?? false,
  amenities:
      (json['amenities'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
  estimatedDeliveryTime: (json['estimatedDeliveryTime'] as num?)?.toInt() ?? 30,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$RestaurantToJson(Restaurant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'imageUrls': instance.imageUrls,
      'location': instance.location,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'openingHours': instance.openingHours,
      'cuisineTypes': instance.cuisineTypes,
      'averageRating': instance.averageRating,
      'totalRatings': instance.totalRatings,
      'isHalalCertified': instance.isHalalCertified,
      'amenities': instance.amenities,
      'deliveryFee': instance.deliveryFee,
      'estimatedDeliveryTime': instance.estimatedDeliveryTime,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
