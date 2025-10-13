import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/models/base_model.dart';
import 'package:makan_mate/models/user_models.dart';


part 'restaurant_models.g.dart';


@JsonSerializable()
class Restaurant extends BaseModel {
  final String id;
  final String name;
  final String description;
  final List<String> imageUrls;
  final Location location;
  final String phoneNumber;
  final String email;
  final Map<String, String> openingHours;
  final List<String> cuisineTypes;
  final double averageRating;
  final int totalRatings;
  final bool isHalalCertified;
  final List<String> amenities;
  final double deliveryFee;
  final int estimatedDeliveryTime;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Restaurant({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrls = const [],
    required this.location,
    required this.phoneNumber,
    required this.email,
    this.openingHours = const {},
    this.cuisineTypes = const [],
    this.averageRating = 0.0,
    this.totalRatings = 0,
    this.isHalalCertified = false,
    this.amenities = const [],
    this.deliveryFee = 0.0,
    this.estimatedDeliveryTime = 30,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => _$RestaurantFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$RestaurantToJson(this);
  
  factory Restaurant.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Restaurant.fromJson({
      'id': doc.id,
      ...data,
    });
  }
  
  @override
  List<Object?> get props => [
    id, name, description, imageUrls, location, phoneNumber, email,
    openingHours, cuisineTypes, averageRating, totalRatings,
    isHalalCertified, amenities, deliveryFee, estimatedDeliveryTime,
    isActive, createdAt, updatedAt,
  ];
}