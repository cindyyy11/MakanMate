import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:makan_mate/features/admin/domain/entities/seasonal_trend_entity.dart';
import 'package:makan_mate/features/admin/domain/services/seasonal_trend_calculator_interface.dart';

/// Implementation of seasonal trend calculator
///
/// This belongs in the data layer (datasources) as it directly accesses Firestore.
/// Implements the domain interface to maintain clean architecture.
///
/// Uses ML algorithm to:
/// - Detect current season based on date
/// - Compare searches vs last 30 days
/// - Identify trending dishes (% increase)
/// - Detect trending cuisines
/// - Predict next major event
class SeasonalTrendCalculatorImpl implements SeasonalTrendCalculatorInterface {
  final FirebaseFirestore firestore;
  final Logger logger;

  SeasonalTrendCalculatorImpl({
    required this.firestore,
    required this.logger,
  });

  @override
  Future<SeasonalTrendAnalysis> calculateSeasonalTrends({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      logger.i('Calculating seasonal trend analysis');

      final now = DateTime.now();
      final analysisEndDate = endDate ?? now;
      final analysisStartDate = startDate ?? now.subtract(const Duration(days: 30));
      final previousPeriodStart = analysisStartDate.subtract(const Duration(days: 30));
      final previousPeriodEnd = analysisStartDate;

      // Step 1: Detect current season
      final currentSeason = _detectCurrentSeason(now);

      // Step 2: Get search data for current and previous periods
      final currentSearches = await _getSearchData(
        startDate: analysisStartDate,
        endDate: analysisEndDate,
      );

      final previousSearches = await _getSearchData(
        startDate: previousPeriodStart,
        endDate: previousPeriodEnd,
      );

      // Step 3: Analyze trending dishes
      final trendingDishes = _analyzeTrendingDishes(
        currentSearches,
        previousSearches,
      );

      // Step 4: Analyze trending cuisines
      final trendingCuisines = _analyzeTrendingCuisines(
        currentSearches,
        previousSearches,
      );

      // Step 5: Predict upcoming events
      final upcomingEvents = _predictUpcomingEvents(now);

      // Step 6: Generate admin recommendations
      final recommendations = _generateAdminRecommendations(
        currentSeason,
        trendingDishes,
        trendingCuisines,
        upcomingEvents,
      );

      return SeasonalTrendAnalysis(
        currentSeason: currentSeason,
        trendingDishes: trendingDishes,
        trendingCuisines: trendingCuisines,
        upcomingEvents: upcomingEvents,
        recommendations: recommendations,
        analysisStartDate: analysisStartDate,
        analysisEndDate: analysisEndDate,
        calculatedAt: now,
        totalSearches: currentSearches.length,
      );
    } catch (e, stackTrace) {
      logger.e('Error calculating seasonal trends: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Detect current season based on month
  ///
  /// SEASONAL DETECTION LOGIC:
  /// - if (month == 3 or month == 4) → Ramadan
  /// - if (month == 1 or month == 2) → CNY
  /// - if (month == 6 or month == 7) → Durian Season
  /// - else → Regular
  Season _detectCurrentSeason(DateTime date) {
    final month = date.month;

    if (month == 3 || month == 4) {
      return Season.ramadan;
    } else if (month == 1 || month == 2) {
      return Season.cny;
    } else if (month == 6 || month == 7) {
      return Season.durian;
    } else {
      return Season.regular;
    }
  }

  /// Get search data from Firestore
  ///
  /// Searches can come from:
  /// - search_logs collection (if exists)
  /// - user_interactions with type 'search'
  /// - food_items views/orders (as proxy for searches)
  Future<List<SearchData>> _getSearchData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final searches = <SearchData>[];

      // Try to get from search_logs collection
      try {
        final searchLogsSnapshot = await firestore
            .collection('search_logs')
            .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
            .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
            .get();

        for (var doc in searchLogsSnapshot.docs) {
          final data = doc.data();
          searches.add(SearchData(
            query: data['query'] as String? ?? '',
            itemId: data['itemId'] as String?,
            cuisineType: data['cuisineType'] as String?,
            timestamp: (data['timestamp'] as Timestamp).toDate(),
          ));
        }
      } catch (e) {
        logger.w('search_logs collection not found, using alternative methods: $e');
      }

      // If no search logs, use user_interactions as proxy
      if (searches.isEmpty) {
        try {
          final interactionsSnapshot = await firestore
              .collection('user_interactions')
              .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
              .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
              .where('interactionType', whereIn: ['search', 'view', 'order'])
              .limit(1000)
              .get();

          for (var doc in interactionsSnapshot.docs) {
            final data = doc.data();
            final itemId = data['itemId'] as String?;
            String? cuisineType;

            // Get cuisine type from food item if available
            if (itemId != null) {
              try {
                final itemDoc = await firestore.collection('food_items').doc(itemId).get();
                if (itemDoc.exists) {
                  final itemData = itemDoc.data();
                  cuisineType = itemData?['cuisineType'] as String?;
                }
              } catch (e) {
                // Ignore errors fetching item data
              }
            }

            searches.add(SearchData(
              query: data['query'] as String? ?? data['itemId'] ?? '',
              itemId: itemId,
              cuisineType: cuisineType,
              timestamp: (data['timestamp'] as Timestamp).toDate(),
            ));
          }
        } catch (e) {
          logger.w('Error getting user_interactions: $e');
        }
      }

      // If still empty, use food_items orders/views as last resort
      if (searches.isEmpty) {
        try {
          final itemsSnapshot = await firestore
              .collection('food_items')
              .limit(500)
              .get();

          for (var doc in itemsSnapshot.docs) {
            final data = doc.data();
            final itemName = data['name'] as String? ?? '';
            final cuisineType = data['cuisineType'] as String?;
            final totalOrders = data['totalOrders'] as int? ?? 0;
            final totalRatings = data['totalRatings'] as int? ?? 0;

            // Use orders/ratings as proxy for search popularity
            final popularity = totalOrders + totalRatings;
            if (popularity > 0) {
              // Distribute searches across the period
              final daysDiff = endDate.difference(startDate).inDays;
              final searchesPerItem = (popularity / 100).ceil().clamp(1, 10);
              
              for (var i = 0; i < searchesPerItem; i++) {
                final randomDay = Random().nextInt(daysDiff);
                searches.add(SearchData(
                  query: itemName,
                  itemId: doc.id,
                  cuisineType: cuisineType,
                  timestamp: startDate.add(Duration(days: randomDay)),
                ));
              }
            }
          }
        } catch (e) {
          logger.w('Error getting food_items: $e');
        }
      }

      logger.i('Retrieved ${searches.length} search records');
      return searches;
    } catch (e, stackTrace) {
      logger.e('Error getting search data: $e', stackTrace: stackTrace);
      return [];
    }
  }

  /// Analyze trending dishes by comparing current vs previous period
  List<TrendingDish> _analyzeTrendingDishes(
    List<SearchData> currentSearches,
    List<SearchData> previousSearches,
  ) {
    // Count searches per dish in current period
    final currentCounts = <String, int>{};
    final dishCuisines = <String, String>{};

    for (var search in currentSearches) {
      if (search.query.isNotEmpty) {
        final dishName = search.query.toLowerCase();
        currentCounts[dishName] = (currentCounts[dishName] ?? 0) + 1;
        if (search.cuisineType != null) {
          dishCuisines[dishName] = search.cuisineType!;
        }
      }
    }

    // Count searches per dish in previous period
    final previousCounts = <String, int>{};
    for (var search in previousSearches) {
      if (search.query.isNotEmpty) {
        final dishName = search.query.toLowerCase();
        previousCounts[dishName] = (previousCounts[dishName] ?? 0) + 1;
      }
    }

    // Calculate percentage changes
    final trendingDishes = <TrendingDish>[];

    for (var entry in currentCounts.entries) {
      final dishName = entry.key;
      final currentCount = entry.value;
      final previousCount = previousCounts[dishName] ?? 0;

      if (currentCount >= 3) { // Only include dishes with meaningful data
        final percentageChange = previousCount > 0
            ? ((currentCount - previousCount) / previousCount) * 100
            : currentCount > 0
                ? 100.0
                : 0.0;

        trendingDishes.add(TrendingDish(
          dishName: dishName,
          percentageChange: percentageChange,
          currentCount: currentCount,
          previousCount: previousCount,
          cuisineType: dishCuisines[dishName] ?? 'unknown',
        ));
      }
    }

    // Sort by percentage change (descending) and take top 10
    trendingDishes.sort((a, b) => b.percentageChange.compareTo(a.percentageChange));
    return trendingDishes.take(10).toList();
  }

  /// Analyze trending cuisines by comparing current vs previous period
  List<TrendingCuisine> _analyzeTrendingCuisines(
    List<SearchData> currentSearches,
    List<SearchData> previousSearches,
  ) {
    // Count searches per cuisine in current period
    final currentCounts = <String, int>{};
    for (var search in currentSearches) {
      if (search.cuisineType != null && search.cuisineType!.isNotEmpty) {
        final cuisine = search.cuisineType!.toLowerCase();
        currentCounts[cuisine] = (currentCounts[cuisine] ?? 0) + 1;
      }
    }

    // Count searches per cuisine in previous period
    final previousCounts = <String, int>{};
    for (var search in previousSearches) {
      if (search.cuisineType != null && search.cuisineType!.isNotEmpty) {
        final cuisine = search.cuisineType!.toLowerCase();
        previousCounts[cuisine] = (previousCounts[cuisine] ?? 0) + 1;
      }
    }

    // Calculate percentage changes
    final trendingCuisines = <TrendingCuisine>[];

    for (var entry in currentCounts.entries) {
      final cuisineName = entry.key;
      final currentCount = entry.value;
      final previousCount = previousCounts[cuisineName] ?? 0;

      if (currentCount >= 5) { // Only include cuisines with meaningful data
        final percentageChange = previousCount > 0
            ? ((currentCount - previousCount) / previousCount) * 100
            : currentCount > 0
                ? 100.0
                : 0.0;

        trendingCuisines.add(TrendingCuisine(
          cuisineName: cuisineName,
          percentageChange: percentageChange,
          currentCount: currentCount,
          previousCount: previousCount,
        ));
      }
    }

    // Sort by percentage change (descending) and take top 5
    trendingCuisines.sort((a, b) => b.percentageChange.compareTo(a.percentageChange));
    return trendingCuisines.take(5).toList();
  }

  /// Predict upcoming events based on current date
  List<UpcomingEvent> _predictUpcomingEvents(DateTime now) {
    final upcomingEvents = <UpcomingEvent>[];

    // Calculate days until next major events
    final currentYear = now.year;
    final currentMonth = now.month;

    // Next Ramadan (typically March-April, but varies by year)
    // For simplicity, assume it's in March-April
    DateTime nextRamadan;
    if (currentMonth < 3) {
      nextRamadan = DateTime(currentYear, 3, 1);
    } else if (currentMonth <= 4) {
      nextRamadan = DateTime(currentYear + 1, 3, 1);
    } else {
      nextRamadan = DateTime(currentYear + 1, 3, 1);
    }
    final daysUntilRamadan = nextRamadan.difference(now).inDays;

    if (daysUntilRamadan <= 60) {
      upcomingEvents.add(UpcomingEvent(
        eventName: 'Ramadan',
        daysUntil: daysUntilRamadan,
        impact: daysUntilRamadan <= 30 ? EventImpact.high : EventImpact.medium,
        predictedTrendingItems: [
          'Nasi Briyani',
          'Rendang',
          'Satay',
          'Bubur Lambuk',
          'Dates',
        ],
      ));
    }

    // Next CNY (January-February)
    DateTime nextCNY;
    if (currentMonth < 1 || currentMonth == 1) {
      nextCNY = DateTime(currentYear, 1, 1);
    } else {
      nextCNY = DateTime(currentYear + 1, 1, 1);
    }
    final daysUntilCNY = nextCNY.difference(now).inDays;

    if (daysUntilCNY <= 60) {
      upcomingEvents.add(UpcomingEvent(
        eventName: 'Chinese New Year',
        daysUntil: daysUntilCNY,
        impact: daysUntilCNY <= 30 ? EventImpact.high : EventImpact.medium,
        predictedTrendingItems: [
          'Yee Sang',
          'Nian Gao',
          'Dumplings',
          'Pineapple Tarts',
          'Bak Kwa',
        ],
      ));
    }

    // Next Durian Season (June-July)
    DateTime nextDurian;
    if (currentMonth < 6) {
      nextDurian = DateTime(currentYear, 6, 1);
    } else if (currentMonth <= 7) {
      nextDurian = DateTime(currentYear + 1, 6, 1);
    } else {
      nextDurian = DateTime(currentYear + 1, 6, 1);
    }
    final daysUntilDurian = nextDurian.difference(now).inDays;

    if (daysUntilDurian <= 60) {
      upcomingEvents.add(UpcomingEvent(
        eventName: 'Durian Season',
        daysUntil: daysUntilDurian,
        impact: daysUntilDurian <= 30 ? EventImpact.high : EventImpact.medium,
        predictedTrendingItems: [
          'Musang King',
          'D24',
          'Durian Cakes',
          'Durian Ice Cream',
        ],
      ));
    }

    return upcomingEvents;
  }

  /// Generate admin recommendations based on trends
  List<AdminRecommendation> _generateAdminRecommendations(
    Season currentSeason,
    List<TrendingDish> trendingDishes,
    List<TrendingCuisine> trendingCuisines,
    List<UpcomingEvent> upcomingEvents,
  ) {
    final recommendations = <AdminRecommendation>[];

    // Season-specific recommendations
    switch (currentSeason) {
      case Season.ramadan:
        recommendations.add(AdminRecommendation(
          title: 'Boost Iftar-Friendly Vendors',
          description:
              'Ramadan is active. Promote vendors offering iftar meals, dates, and traditional breaking-fast dishes.',
          type: RecommendationType.vendorPromotion,
          priority: RecommendationPriority.high,
        ));
        recommendations.add(AdminRecommendation(
          title: 'Highlight Halal-Certified Items',
          description:
              'Ensure halal-certified items are prominently featured during Ramadan season.',
          type: RecommendationType.contentBoost,
          priority: RecommendationPriority.high,
        ));
        break;
      case Season.cny:
        recommendations.add(AdminRecommendation(
          title: 'Promote CNY Special Dishes',
          description:
              'Chinese New Year is active. Feature traditional CNY dishes like Yee Sang, Nian Gao, and festive meals.',
          type: RecommendationType.marketingCampaign,
          priority: RecommendationPriority.high,
        ));
        break;
      case Season.durian:
        recommendations.add(AdminRecommendation(
          title: 'Feature Durian Vendors',
          description:
              'Durian season is active. Boost visibility of durian vendors and durian-based desserts.',
          type: RecommendationType.vendorPromotion,
          priority: RecommendationPriority.medium,
        ));
        break;
      case Season.regular:
        break;
    }

    // Trending dishes recommendations
    if (trendingDishes.isNotEmpty) {
      final topTrending = trendingDishes.first;
      if (topTrending.isTrendingUp && topTrending.percentageChange > 50) {
        recommendations.add(AdminRecommendation(
          title: '${topTrending.dishName} is Trending Up',
          description:
              '${topTrending.dishName} shows ${topTrending.percentageChange.toStringAsFixed(0)}% increase. Consider featuring this dish prominently.',
          type: RecommendationType.contentBoost,
          priority: RecommendationPriority.medium,
        ));
      }
    }

    // Trending cuisines recommendations
    if (trendingCuisines.isNotEmpty) {
      final topCuisine = trendingCuisines.first;
      if (topCuisine.isTrendingUp && topCuisine.percentageChange > 30) {
        recommendations.add(AdminRecommendation(
          title: '${topCuisine.cuisineName} Cuisine is Trending',
          description:
              '${topCuisine.cuisineName} cuisine shows ${topCuisine.percentageChange.toStringAsFixed(0)}% increase. Consider boosting ${topCuisine.cuisineName} restaurants.',
          type: RecommendationType.vendorPromotion,
          priority: RecommendationPriority.medium,
        ));
      }
    }

    // Upcoming events recommendations
    for (var event in upcomingEvents) {
      if (event.daysUntil <= 45 && event.impact == EventImpact.high) {
        recommendations.add(AdminRecommendation(
          title: '${event.eventName} Coming Soon',
          description:
              '${event.eventName} is in ${event.daysUntil} days. Start preparing marketing campaigns and inventory for predicted trending items: ${event.predictedTrendingItems.take(3).join(", ")}.',
          type: RecommendationType.marketingCampaign,
          priority: RecommendationPriority.high,
        ));
      }
    }

    return recommendations;
  }
}

/// Helper class for search data
class SearchData {
  final String query;
  final String? itemId;
  final String? cuisineType;
  final DateTime timestamp;

  SearchData({
    required this.query,
    this.itemId,
    this.cuisineType,
    required this.timestamp,
  });
}

