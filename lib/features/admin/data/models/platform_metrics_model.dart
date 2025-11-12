import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/features/admin/domain/entities/platform_metrics_entity.dart';

/// Data model for platform metrics
/// 
/// Handles conversion between Firestore data and domain entity
class PlatformMetricsModel extends PlatformMetrics {
  const PlatformMetricsModel({
    required super.totalUsers,
    required super.totalVendors,
    required super.activeVendors,
    required super.pendingApplications,
    required super.flaggedReviews,
    required super.averagePlatformRating,
    required super.todaysActiveUsers,
    required super.totalRestaurants,
    required super.totalFoodItems,
    required super.lastUpdated,
  });

  /// Create from Firestore snapshot data
  factory PlatformMetricsModel.fromJson(Map<String, dynamic> json) {
    return PlatformMetricsModel(
      totalUsers: json['totalUsers'] as int? ?? 0,
      totalVendors: json['totalVendors'] as int? ?? 0,
      activeVendors: json['activeVendors'] as int? ?? 0,
      pendingApplications: json['pendingApplications'] as int? ?? 0,
      flaggedReviews: json['flaggedReviews'] as int? ?? 0,
      averagePlatformRating: (json['averagePlatformRating'] as num?)?.toDouble() ?? 0.0,
      todaysActiveUsers: json['todaysActiveUsers'] as int? ?? 0,
      totalRestaurants: json['totalRestaurants'] as int? ?? 0,
      totalFoodItems: json['totalFoodItems'] as int? ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? (json['lastUpdated'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'totalVendors': totalVendors,
      'activeVendors': activeVendors,
      'pendingApplications': pendingApplications,
      'flaggedReviews': flaggedReviews,
      'averagePlatformRating': averagePlatformRating,
      'todaysActiveUsers': todaysActiveUsers,
      'totalRestaurants': totalRestaurants,
      'totalFoodItems': totalFoodItems,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  /// Convert to domain entity
  PlatformMetrics toEntity() {
    return PlatformMetrics(
      totalUsers: totalUsers,
      totalVendors: totalVendors,
      activeVendors: activeVendors,
      pendingApplications: pendingApplications,
      flaggedReviews: flaggedReviews,
      averagePlatformRating: averagePlatformRating,
      todaysActiveUsers: todaysActiveUsers,
      totalRestaurants: totalRestaurants,
      totalFoodItems: totalFoodItems,
      lastUpdated: lastUpdated,
    );
  }
}

