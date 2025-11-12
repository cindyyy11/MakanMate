// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  role: json['role'] as String? ?? 'user',
  profileImageUrl: json['profileImageUrl'] as String?,
  dietaryRestrictions:
      (json['dietaryRestrictions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  cuisinePreferences:
      (json['cuisinePreferences'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ) ??
      const {},
  spiceTolerance: (json['spiceTolerance'] as num?)?.toDouble() ?? 0.5,
  culturalBackground: json['culturalBackground'] as String? ?? 'mixed',
  currentLocation: Location.fromJson(
    json['currentLocation'] as Map<String, dynamic>,
  ),
  behaviorPatterns:
      (json['behaviorPatterns'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ) ??
      const {},
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'role': instance.role,
  'profileImageUrl': instance.profileImageUrl,
  'dietaryRestrictions': instance.dietaryRestrictions,
  'cuisinePreferences': instance.cuisinePreferences,
  'spiceTolerance': instance.spiceTolerance,
  'culturalBackground': instance.culturalBackground,
  'currentLocation': instance.currentLocation,
  'behaviorPatterns': instance.behaviorPatterns,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  address: json['address'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  country: json['country'] as String?,
);

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'address': instance.address,
  'city': instance.city,
  'state': instance.state,
  'country': instance.country,
};

UserInteraction _$UserInteractionFromJson(Map<String, dynamic> json) =>
    UserInteraction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      itemId: json['itemId'] as String,
      interactionType: json['interactionType'] as String,
      rating: (json['rating'] as num?)?.toDouble(),
      comment: json['comment'] as String?,
      context: json['context'] as Map<String, dynamic>? ?? const {},
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$UserInteractionToJson(UserInteraction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'itemId': instance.itemId,
      'interactionType': instance.interactionType,
      'rating': instance.rating,
      'comment': instance.comment,
      'context': instance.context,
      'timestamp': instance.timestamp.toIso8601String(),
    };
