import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:makan_mate/core/base_model.dart';

part 'user_models.g.dart';

@JsonSerializable()
class UserModel extends BaseModel {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final List<String> dietaryRestrictions;
  final Map<String, double> cuisinePreferences;
  final double spiceTolerance;
  final String culturalBackground;
  final Location currentLocation;
  final Map<String, double> behaviorPatterns;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.dietaryRestrictions = const [],
    this.cuisinePreferences = const {},
    this.spiceTolerance = 0.5,
    this.culturalBackground = 'mixed',
    required this.currentLocation,
    this.behaviorPatterns = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson({'id': doc.id, ...data});
  }

  /// Create UserModel from Firebase Auth User
  /// Uses default values for fields not available in Firebase Auth
  factory UserModel.fromFirebase(User user) {
    final now = DateTime.now();
    // Default location: Kuala Lumpur, Malaysia (central location)
    const defaultLocation = Location(
      latitude: 3.1390,
      longitude: 101.6869,
      city: 'Kuala Lumpur',
      state: 'Kuala Lumpur',
      country: 'Malaysia',
    );

    // Handle email - required field, use UID-based email for anonymous users
    final email = user.email;
    if (email == null || email.isEmpty) {
      // For anonymous users or users without email, create a placeholder
      // This should not happen for email/password auth, but handles edge cases
      throw ArgumentError(
        'User email is required. Cannot create UserModel from user without email.',
      );
    }

    return UserModel(
      id: user.uid,
      name: user.displayName ?? email.split('@').first,
      email: email,
      profileImageUrl: user.photoURL,
      dietaryRestrictions: const [],
      cuisinePreferences: const {},
      spiceTolerance: 0.5,
      culturalBackground: 'mixed',
      currentLocation: defaultLocation,
      behaviorPatterns: const {},
      createdAt: user.metadata.creationTime ?? now,
      updatedAt: user.metadata.lastSignInTime ?? now,
    );
  }

  // Convert to feature vector for AI
  List<double> toFeatureVector() {
    List<double> features = [];

    // Cuisine preferences
    List<String> cuisines = ['malay', 'chinese', 'indian', 'western', 'thai'];
    for (String cuisine in cuisines) {
      features.add(cuisinePreferences[cuisine] ?? 0.0);
    }

    // Dietary restrictions
    features.add(dietaryRestrictions.contains('halal') ? 1.0 : 0.0);
    features.add(dietaryRestrictions.contains('vegetarian') ? 1.0 : 0.0);
    features.add(dietaryRestrictions.contains('vegan') ? 1.0 : 0.0);

    // Spice tolerance
    features.add(spiceTolerance);

    // Cultural background
    List<String> cultures = ['malay', 'chinese', 'indian', 'mixed'];
    for (String culture in cultures) {
      features.add(culturalBackground.toLowerCase() == culture ? 1.0 : 0.0);
    }

    // Behavioral patterns
    features.add(behaviorPatterns['morning_activity'] ?? 0.0);
    features.add(behaviorPatterns['afternoon_activity'] ?? 0.0);
    features.add(behaviorPatterns['evening_activity'] ?? 0.0);
    features.add(behaviorPatterns['weekend_activity'] ?? 0.0);

    return features;
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    List<String>? dietaryRestrictions,
    Map<String, double>? cuisinePreferences,
    double? spiceTolerance,
    String? culturalBackground,
    Location? currentLocation,
    Map<String, double>? behaviorPatterns,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      cuisinePreferences: cuisinePreferences ?? this.cuisinePreferences,
      spiceTolerance: spiceTolerance ?? this.spiceTolerance,
      culturalBackground: culturalBackground ?? this.culturalBackground,
      currentLocation: currentLocation ?? this.currentLocation,
      behaviorPatterns: behaviorPatterns ?? this.behaviorPatterns,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    profileImageUrl,
    dietaryRestrictions,
    cuisinePreferences,
    spiceTolerance,
    culturalBackground,
    currentLocation,
    behaviorPatterns,
    createdAt,
    updatedAt,
  ];
}

@JsonSerializable()
class Location extends BaseModel {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? state;
  final String? country;

  const Location({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.state,
    this.country,
  });

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LocationToJson(this);

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    address,
    city,
    state,
    country,
  ];
}

@JsonSerializable()
class UserInteraction extends BaseModel {
  final String id;
  final String userId;
  final String itemId;
  final String interactionType;
  final double? rating;
  final String? comment;
  final Map<String, dynamic> context;
  final DateTime timestamp;

  const UserInteraction({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.interactionType,
    this.rating,
    this.comment,
    this.context = const {},
    required this.timestamp,
  });

  factory UserInteraction.fromJson(Map<String, dynamic> json) =>
      _$UserInteractionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserInteractionToJson(this);

  factory UserInteraction.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserInteraction.fromJson({'id': doc.id, ...data});
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    itemId,
    interactionType,
    rating,
    comment,
    context,
    timestamp,
  ];
}
