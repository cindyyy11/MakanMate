import 'package:equatable/equatable.dart';

/// Geographic heatmap data for user/vendor distribution
class GeographicHeatmap extends Equatable {
  final String id;
  final List<HeatmapZone> zones;
  final List<UnderservedRegion> underservedRegions;
  final List<PopularZone> popularZones;
  final List<Recommendation> recommendations;
  final DateTime generatedAt;

  const GeographicHeatmap({
    required this.id,
    this.zones = const [],
    this.underservedRegions = const [],
    this.popularZones = const [],
    this.recommendations = const [],
    required this.generatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        zones,
        underservedRegions,
        popularZones,
        recommendations,
        generatedAt,
      ];
}

class HeatmapZone extends Equatable {
  final String id;
  final String name; // e.g., "Petaling Jaya"
  final double latitude;
  final double longitude;
  final int userDensity; // Number of users
  final int vendorCount;
  final double densityScore; // 0-1 normalized score
  final HeatmapColor color; // Red, Yellow, Green

  const HeatmapZone({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.userDensity,
    required this.vendorCount,
    required this.densityScore,
    required this.color,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        latitude,
        longitude,
        userDensity,
        vendorCount,
        densityScore,
        color,
      ];
}

enum HeatmapColor {
  red, // High density
  yellow, // Medium density
  green, // Low density
}

class UnderservedRegion extends Equatable {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int userCount;
  final int vendorCount;
  final int recommendedVendors; // How many vendors needed
  final String priority; // High, Medium, Low

  const UnderservedRegion({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.userCount,
    required this.vendorCount,
    required this.recommendedVendors,
    required this.priority,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        latitude,
        longitude,
        userCount,
        vendorCount,
        recommendedVendors,
        priority,
      ];
}

class PopularZone extends Equatable {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int userCount;
  final int vendorCount;
  final double popularityScore; // 0-1
  final List<String> topCuisines;

  const PopularZone({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.userCount,
    required this.vendorCount,
    required this.popularityScore,
    this.topCuisines = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        latitude,
        longitude,
        userCount,
        vendorCount,
        popularityScore,
        topCuisines,
      ];
}

class Recommendation extends Equatable {
  final String id;
  final String message; // e.g., "Recruit more vendors in Petaling Jaya"
  final RecommendationType type;
  final String? targetRegion;

  const Recommendation({
    required this.id,
    required this.message,
    required this.type,
    this.targetRegion,
  });

  @override
  List<Object?> get props => [id, message, type, targetRegion];
}

enum RecommendationType {
  vendorRecruitment,
  marketingFocus,
  expansion,
}


