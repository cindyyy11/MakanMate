import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:makan_mate/core/base_model.dart';
import 'package:makan_mate/features/user/domain/entities/user_entity.dart';

part 'user_models.g.dart';

@JsonSerializable()
class UserModel extends BaseModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isVerified;
  final String? profileImageUrl;
  final List<String> dietaryRestrictions;
  final Map<String, double> cuisinePreferences;
  final double spiceTolerance;
  final String culturalBackground;
  final Location currentLocation;
  final Map<String, double> behaviorPatterns;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Admin moderation fields
  final bool isBanned;
  final String? banReason;
  final DateTime? bannedAt;
  final DateTime? bannedUntil;
  final String? bannedBy;
  // Optional warnings list on user doc (each: reason, warnedBy, warnedAt)
  final List<Map<String, dynamic>> warnings;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'user',
    this.isVerified = false,
    this.profileImageUrl,
    this.dietaryRestrictions = const [],
    this.cuisinePreferences = const {},
    this.spiceTolerance = 0.5,
    this.culturalBackground = 'mixed',
    required this.currentLocation,
    this.behaviorPatterns = const {},
    required this.createdAt,
    required this.updatedAt,
    this.isBanned = false,
    this.banReason,
    this.bannedAt,
    this.bannedUntil,
    this.bannedBy,
    this.warnings = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  @override
  //Nested object needs to be JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'isVerified': isVerified,
      'profileImageUrl': profileImageUrl,
      'dietaryRestrictions': dietaryRestrictions,
      'cuisinePreferences': cuisinePreferences,
      'spiceTolerance': spiceTolerance,
      'culturalBackground': culturalBackground,
      'currentLocation': currentLocation.toJson(),
      'behaviorPatterns': behaviorPatterns,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isBanned': isBanned,
      'banReason': banReason,
      'bannedAt': bannedAt?.toIso8601String(),
      'bannedUntil': bannedUntil?.toIso8601String(),
      'bannedBy': bannedBy,
      'warnings': warnings,
    };
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final rawData = doc.data();
    if (rawData == null) {
      throw Exception('Document data is null');
    }

    // Safely convert Firestore data to Map<String, dynamic>
    final Map<String, dynamic> data = Map<String, dynamic>.from(rawData as Map);

    // Convert Firestore Timestamps to ISO8601 strings for fromJson
    final jsonData = <String, dynamic>{'id': doc.id};

    for (var entry in data.entries) {
      if (entry.value is Timestamp) {
        // Convert Timestamp to ISO8601 string
        jsonData[entry.key] = (entry.value as Timestamp)
            .toDate()
            .toIso8601String();
      } else if (entry.value is DateTime) {
        // Convert DateTime to ISO8601 string
        jsonData[entry.key] = (entry.value as DateTime).toIso8601String();
      } else if (entry.key == 'currentLocation' && entry.value != null) {
        // Handle nested Location object - safely convert to Map<String, dynamic>
        if (entry.value is Map) {
          jsonData[entry.key] = Map<String, dynamic>.from(entry.value as Map);
        } else {
          // If it's not a Map, provide default
          jsonData[entry.key] = {
            'latitude': 3.1390,
            'longitude': 101.6869,
            'city': 'Kuala Lumpur',
            'state': 'Kuala Lumpur',
            'country': 'Malaysia',
          };
        }
      } else if (entry.value is List) {
        // Handle lists - ensure they're properly typed
        jsonData[entry.key] = List.from(entry.value as List);
      } else if (entry.value is Map) {
        // Handle nested maps - convert to Map<String, dynamic>
        jsonData[entry.key] = Map<String, dynamic>.from(entry.value as Map);
      } else {
        jsonData[entry.key] = entry.value;
      }
    }

    // Handle missing required fields with defaults
    final now = DateTime.now().toIso8601String();
    jsonData['createdAt'] ??= now;
    jsonData['updatedAt'] ??= now;

    // Handle other required fields with defaults
    jsonData['name'] ??=
        jsonData['email']?.toString().split('@').first ?? 'User';
    jsonData['email'] ??= '';
    jsonData['role'] ??= 'user';
    jsonData['isVerified'] ??= false;
    jsonData['dietaryRestrictions'] ??= [];
    jsonData['cuisinePreferences'] ??= {};
    jsonData['spiceTolerance'] ??= 0.5;
    jsonData['culturalBackground'] ??= 'mixed';
    jsonData['behaviorPatterns'] ??= {};
    jsonData['isBanned'] ??= false;
    jsonData['warnings'] ??= const [];

    // Handle currentLocation - provide default if missing or invalid
    if (jsonData['currentLocation'] == null ||
        jsonData['currentLocation'] is! Map) {
      jsonData['currentLocation'] = {
        'latitude': 3.1390,
        'longitude': 101.6869,
        'city': 'Kuala Lumpur',
        'state': 'Kuala Lumpur',
        'country': 'Malaysia',
      };
    }

    return UserModel.fromJson(jsonData);
  }

  /// Create UserModel from Firebase Auth User
  /// Uses default values for fields not available in Firebase Auth
  factory UserModel.fromFirebase(User user, {String role = 'user'}) {
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
      role: role,
      isVerified: user.emailVerified,
      profileImageUrl: user.photoURL,
      dietaryRestrictions: const [],
      cuisinePreferences: const {},
      spiceTolerance: 0.5,
      culturalBackground: 'mixed',
      currentLocation: defaultLocation,
      behaviorPatterns: const {},
      createdAt: user.metadata.creationTime ?? now,
      updatedAt: user.metadata.lastSignInTime ?? now,
      isBanned: false,
      warnings: const [],
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
    String? role,
    bool? isVerified,
    String? profileImageUrl,
    List<String>? dietaryRestrictions,
    Map<String, double>? cuisinePreferences,
    double? spiceTolerance,
    String? culturalBackground,
    Location? currentLocation,
    Map<String, double>? behaviorPatterns,
    bool? isBanned,
    String? banReason,
    DateTime? bannedAt,
    DateTime? bannedUntil,
    String? bannedBy,
    List<Map<String, dynamic>>? warnings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      cuisinePreferences: cuisinePreferences ?? this.cuisinePreferences,
      spiceTolerance: spiceTolerance ?? this.spiceTolerance,
      culturalBackground: culturalBackground ?? this.culturalBackground,
      currentLocation: currentLocation ?? this.currentLocation,
      behaviorPatterns: behaviorPatterns ?? this.behaviorPatterns,
      isBanned: isBanned ?? this.isBanned,
      banReason: banReason ?? this.banReason,
      bannedAt: bannedAt ?? this.bannedAt,
      bannedUntil: bannedUntil ?? this.bannedUntil,
      bannedBy: bannedBy ?? this.bannedBy,
      warnings: warnings ?? this.warnings,
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
    isVerified,
    isBanned,
    banReason,
    bannedAt,
    bannedUntil,
    bannedBy,
    warnings,
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

// ============================================================================
// Clean Architecture Extensions
// ============================================================================

/// Extension to convert UserModel to UserEntity (Domain layer)
extension UserModelToEntity on UserModel {
  /// Convert UserModel to UserEntity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      role: role,
      isVerified: isVerified,
      isBanned: isBanned,
      banReason: banReason,
      bannedAt: bannedAt,
      bannedUntil: bannedUntil,
      bannedBy: bannedBy,
      profileImageUrl: profileImageUrl,
      dietaryRestrictions: dietaryRestrictions,
      cuisinePreferences: cuisinePreferences,
      spiceTolerance: spiceTolerance,
      culturalBackground: culturalBackground,
      currentLocation: currentLocation,
      behaviorPatterns: behaviorPatterns,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Extension to convert UserEntity to UserModel
extension UserEntityToModel on UserEntity {
  /// Convert UserEntity to UserModel
  UserModel toModel() {
    return UserModel(
      id: id,
      name: name,
      email: email,
      role: role,
      isVerified: isVerified,
      isBanned: isBanned,
      banReason: banReason,
      bannedAt: bannedAt,
      bannedUntil: bannedUntil,
      bannedBy: bannedBy,
      profileImageUrl: profileImageUrl,
      dietaryRestrictions: dietaryRestrictions,
      cuisinePreferences: cuisinePreferences,
      spiceTolerance: spiceTolerance,
      culturalBackground: culturalBackground,
      currentLocation: currentLocation,
      behaviorPatterns: behaviorPatterns,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
