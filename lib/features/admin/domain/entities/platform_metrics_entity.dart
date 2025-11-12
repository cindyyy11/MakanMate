import 'package:equatable/equatable.dart';

/// Platform metrics entity for admin dashboard
/// 
/// Contains aggregate statistics about the platform
class PlatformMetrics extends Equatable {
  final int totalUsers;
  final int totalVendors;
  final int activeVendors;
  final int pendingApplications;
  final int flaggedReviews;
  final double averagePlatformRating;
  final int todaysActiveUsers;
  final int totalRestaurants;
  final int totalFoodItems;
  final DateTime lastUpdated;

  const PlatformMetrics({
    required this.totalUsers,
    required this.totalVendors,
    required this.activeVendors,
    required this.pendingApplications,
    required this.flaggedReviews,
    required this.averagePlatformRating,
    required this.todaysActiveUsers,
    required this.totalRestaurants,
    required this.totalFoodItems,
    required this.lastUpdated,
  });

  @override
  List<Object> get props => [
        totalUsers,
        totalVendors,
        activeVendors,
        pendingApplications,
        flaggedReviews,
        averagePlatformRating,
        todaysActiveUsers,
        totalRestaurants,
        totalFoodItems,
        lastUpdated,
      ];

  PlatformMetrics copyWith({
    int? totalUsers,
    int? totalVendors,
    int? activeVendors,
    int? pendingApplications,
    int? flaggedReviews,
    double? averagePlatformRating,
    int? todaysActiveUsers,
    int? totalRestaurants,
    int? totalFoodItems,
    DateTime? lastUpdated,
  }) {
    return PlatformMetrics(
      totalUsers: totalUsers ?? this.totalUsers,
      totalVendors: totalVendors ?? this.totalVendors,
      activeVendors: activeVendors ?? this.activeVendors,
      pendingApplications: pendingApplications ?? this.pendingApplications,
      flaggedReviews: flaggedReviews ?? this.flaggedReviews,
      averagePlatformRating: averagePlatformRating ?? this.averagePlatformRating,
      todaysActiveUsers: todaysActiveUsers ?? this.todaysActiveUsers,
      totalRestaurants: totalRestaurants ?? this.totalRestaurants,
      totalFoodItems: totalFoodItems ?? this.totalFoodItems,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

