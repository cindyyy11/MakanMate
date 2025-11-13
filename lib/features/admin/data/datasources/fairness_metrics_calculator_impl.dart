import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:makan_mate/features/admin/domain/entities/fairness_metrics_entity.dart';
import 'package:makan_mate/features/admin/domain/services/fairness_metrics_calculator_interface.dart';
import 'package:makan_mate/features/food/data/models/food_models.dart';

/// Implementation of fairness metrics calculator
///
/// This belongs in the data layer (datasources) as it directly accesses Firestore.
/// Implements the domain interface to maintain clean architecture.
class FairnessMetricsCalculatorImpl
    implements FairnessMetricsCalculatorInterface {
  final FirebaseFirestore firestore;
  final Logger logger;

  FairnessMetricsCalculatorImpl({
    required this.firestore,
    required this.logger,
  });

  @override
  Future<FairnessMetrics> calculateFairnessMetrics({
    int recommendationLimit = 1000,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      logger.i(
        'Calculating fairness metrics for last $recommendationLimit recommendations',
      );

      // Get recommendations from cache
      final recommendations = await _getRecentRecommendations(
        limit: recommendationLimit,
        startDate: startDate,
        endDate: endDate,
      );

      if (recommendations.isEmpty) {
        logger.w('No recommendations found for analysis');
        return _createEmptyMetrics();
      }

      // Get food items data for analysis
      final foodItems = await _getFoodItemsData(recommendations);

      // Get vendor data for size analysis
      final vendors = await _getVendorsData(foodItems);

      // Calculate distributions
      final cuisineDistribution = _calculateCuisineDistribution(
        recommendations,
        foodItems,
      );

      final regionDistribution = _calculateRegionDistribution(
        recommendations,
        foodItems,
      );

      // Calculate vendor size visibility
      final vendorSizeMetrics = _calculateVendorSizeVisibility(
        recommendations,
        foodItems,
        vendors,
      );

      // Calculate diversity score
      final diversityScore = _calculateDiversityScore(
        cuisineDistribution,
        regionDistribution,
      );

      // Calculate NDCG score
      final ndcgScore = await _calculateNDCGScore(recommendations);

      // Detect bias patterns
      final biasAlerts = _detectBiasPatterns(
        cuisineDistribution,
        regionDistribution,
        vendorSizeMetrics,
      );

      // Determine analysis period
      final analysisDates = _getAnalysisPeriod(recommendations);

      final metrics = FairnessMetrics(
        cuisineDistribution: cuisineDistribution,
        regionDistribution: regionDistribution,
        smallVendorVisibility: vendorSizeMetrics['small'] ?? 0.0,
        largeVendorVisibility: vendorSizeMetrics['large'] ?? 0.0,
        diversityScore: diversityScore,
        ndcgScore: ndcgScore,
        biasAlerts: biasAlerts,
        totalRecommendations: recommendations.length,
        analysisStartDate: analysisDates['start'] ?? DateTime.now(),
        analysisEndDate: analysisDates['end'] ?? DateTime.now(),
        calculatedAt: DateTime.now(),
      );

      logger.i('Successfully calculated fairness metrics');
      return metrics;
    } catch (e, stackTrace) {
      logger.e(
        'Error calculating fairness metrics: $e',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get recent recommendations from cache
  Future<List<Map<String, dynamic>>> _getRecentRecommendations({
    required int limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = firestore
          .collection('recommendation_cache')
          .orderBy('generatedAt', descending: true)
          .limit(limit);

      if (startDate != null) {
        query = query.where(
          'generatedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'generatedAt',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final snapshot = await query.get();
      final allRecommendations = <Map<String, dynamic>>[];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        final recommendations = data['recommendations'] as List<dynamic>? ?? [];

        for (var rec in recommendations) {
          final recMap = rec as Map<String, dynamic>?;
          if (recMap == null) continue;

          allRecommendations.add({
            ...recMap,
            'userId': data['userId'] as String?,
            'generatedAt': (data['generatedAt'] as Timestamp?)?.toDate(),
          });
        }
      }

      // Limit to last N recommendations
      return allRecommendations.take(limit).toList();
    } catch (e) {
      logger.e('Error fetching recommendations: $e');
      return [];
    }
  }

  /// Get food items data for recommendations
  Future<Map<String, FoodItem>> _getFoodItemsData(
    List<Map<String, dynamic>> recommendations,
  ) async {
    try {
      final itemIds = recommendations
          .map((r) => r['itemId'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      if (itemIds.isEmpty) return {};

      // Fetch in batches to avoid query limits
      final foodItems = <String, FoodItem>{};
      const batchSize = 100;

      for (var i = 0; i < itemIds.length; i += batchSize) {
        final batch = itemIds.skip(i).take(batchSize).toList();
        final snapshot = await firestore
            .collection('food_items')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        for (var doc in snapshot.docs) {
          try {
            final item = FoodItem.fromFirestore(doc);
            foodItems[doc.id] = item;
          } catch (e) {
            logger.w('Error parsing food item ${doc.id}: $e');
          }
        }
      }

      return foodItems;
    } catch (e) {
      logger.e('Error fetching food items: $e');
      return {};
    }
  }

  /// Get vendors data for size analysis
  Future<Map<String, Map<String, dynamic>>> _getVendorsData(
    Map<String, FoodItem> foodItems,
  ) async {
    try {
      final restaurantIds = foodItems.values
          .map((item) => item.restaurantId)
          .toSet()
          .toList();

      if (restaurantIds.isEmpty) return {};

      final vendors = <String, Map<String, dynamic>>{};
      const batchSize = 100;

      for (var i = 0; i < restaurantIds.length; i += batchSize) {
        final batch = restaurantIds.skip(i).take(batchSize).toList();
        final snapshot = await firestore
            .collection('restaurants')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            vendors[doc.id] = {
              'id': doc.id,
              'name': data['name'] as String? ?? '',
              'totalOrders': data['totalOrders'] as int? ?? 0,
              'region': _extractRegion(data['location']),
            };
          }
        }
      }

      return vendors;
    } catch (e) {
      logger.e('Error fetching vendors: $e');
      return {};
    }
  }

  /// Extract region from location data
  String _extractRegion(dynamic location) {
    if (location is Map<String, dynamic>) {
      return location['state'] as String? ??
          location['city'] as String? ??
          'Unknown';
    }
    return 'Unknown';
  }

  /// Calculate cuisine distribution
  Map<String, double> _calculateCuisineDistribution(
    List<Map<String, dynamic>> recommendations,
    Map<String, FoodItem> foodItems,
  ) {
    final cuisineCounts = <String, int>{};
    int total = 0;

    for (var rec in recommendations) {
      final itemId = rec['itemId'] as String?;
      if (itemId == null) continue;

      final item = foodItems[itemId];
      if (item == null) continue;

      final cuisine = item.cuisineType;
      cuisineCounts[cuisine] = (cuisineCounts[cuisine] ?? 0) + 1;
      total++;
    }

    if (total == 0) return {};

    return cuisineCounts.map(
      (key, value) => MapEntry(key, (value / total) * 100),
    );
  }

  /// Calculate region distribution
  Map<String, double> _calculateRegionDistribution(
    List<Map<String, dynamic>> recommendations,
    Map<String, FoodItem> foodItems,
  ) {
    final regionCounts = <String, int>{};
    int total = 0;

    for (var rec in recommendations) {
      final itemId = rec['itemId'] as String?;
      if (itemId == null) continue;

      final item = foodItems[itemId];
      if (item == null) continue;

      final region = item.restaurantLocation.state ?? 'Unknown';
      regionCounts[region] = (regionCounts[region] ?? 0) + 1;
      total++;
    }

    if (total == 0) return {};

    return regionCounts.map(
      (key, value) => MapEntry(key, (value / total) * 100),
    );
  }

  /// Calculate vendor size visibility
  Map<String, double> _calculateVendorSizeVisibility(
    List<Map<String, dynamic>> recommendations,
    Map<String, FoodItem> foodItems,
    Map<String, Map<String, dynamic>> vendors,
  ) {
    int smallCount = 0;
    int largeCount = 0;
    int total = 0;

    // Threshold: vendors with < 1000 total orders are considered small
    const smallVendorThreshold = 1000;

    for (var rec in recommendations) {
      final itemId = rec['itemId'] as String?;
      if (itemId == null) continue;

      final item = foodItems[itemId];
      if (item == null) continue;

      final vendor = vendors[item.restaurantId];
      if (vendor == null) continue;

      final totalOrders = vendor['totalOrders'] as int? ?? 0;

      if (totalOrders < smallVendorThreshold) {
        smallCount++;
      } else {
        largeCount++;
      }
      total++;
    }

    if (total == 0) {
      return {'small': 0.0, 'large': 0.0};
    }

    return {
      'small': (smallCount / total) * 100,
      'large': (largeCount / total) * 100,
    };
  }

  /// Calculate diversity score (0-1)
  ///
  /// Higher score = more diverse recommendations
  double _calculateDiversityScore(
    Map<String, double> cuisineDistribution,
    Map<String, double> regionDistribution,
  ) {
    // Use Shannon entropy to measure diversity
    double cuisineEntropy = _calculateEntropy(cuisineDistribution.values);
    double regionEntropy = _calculateEntropy(regionDistribution.values);

    // Normalize to 0-1 range
    final maxCuisineEntropy = log(cuisineDistribution.length) / ln2;
    final maxRegionEntropy = log(regionDistribution.length) / ln2;

    final normalizedCuisine = maxCuisineEntropy > 0
        ? cuisineEntropy / maxCuisineEntropy
        : 0.0;
    final normalizedRegion = maxRegionEntropy > 0
        ? regionEntropy / maxRegionEntropy
        : 0.0;

    // Average of both
    return (normalizedCuisine + normalizedRegion) / 2.0;
  }

  /// Calculate Shannon entropy
  double _calculateEntropy(Iterable<double> probabilities) {
    double entropy = 0.0;
    for (var p in probabilities) {
      if (p > 0) {
        entropy -= p * log(p) / ln2;
      }
    }
    return entropy;
  }

  static const ln2 = 0.6931471805599453;

  /// Calculate NDCG (Normalized Discounted Cumulative Gain) score
  ///
  /// Measures recommendation quality based on relevance scores
  Future<double> _calculateNDCGScore(
    List<Map<String, dynamic>> recommendations,
  ) async {
    if (recommendations.isEmpty) return 0.0;

    // Get relevance scores (using recommendation scores)
    final scores = recommendations
        .map((r) => (r['score'] as num?)?.toDouble() ?? 0.0)
        .toList();

    // Calculate DCG
    double dcg = 0.0;
    for (var i = 0; i < scores.length; i++) {
      final relevance = scores[i];
      final position = i + 1;
      dcg += relevance / (log(position + 1) / ln2);
    }

    // Calculate ideal DCG (sorted descending)
    final idealScores = List<double>.from(scores)
      ..sort((a, b) => b.compareTo(a));
    double idealDcg = 0.0;
    for (var i = 0; i < idealScores.length; i++) {
      final relevance = idealScores[i];
      final position = i + 1;
      idealDcg += relevance / (log(position + 1) / ln2);
    }

    // NDCG = DCG / Ideal DCG
    return idealDcg > 0 ? dcg / idealDcg : 0.0;
  }

  /// Detect bias patterns
  List<BiasAlert> _detectBiasPatterns(
    Map<String, double> cuisineDistribution,
    Map<String, double> regionDistribution,
    Map<String, double> vendorSizeMetrics,
  ) {
    final alerts = <BiasAlert>[];

    // Check cuisine bias (flag if any cuisine > 40%)
    for (var entry in cuisineDistribution.entries) {
      if (entry.value > 40.0) {
        // Get expected percentage (assume equal distribution for now)
        final expectedPercentage = 100.0 / cuisineDistribution.length;
        final severity = entry.value > 60.0
            ? BiasSeverity.high
            : entry.value > 50.0
            ? BiasSeverity.medium
            : BiasSeverity.low;

        alerts.add(
          BiasAlert(
            biasType: 'cuisine',
            description:
                '${entry.key} cuisine represents ${entry.value.toStringAsFixed(1)}% of recommendations, but only ${expectedPercentage.toStringAsFixed(1)}% of vendors',
            severity: severity,
            actualPercentage: entry.value,
            expectedPercentage: expectedPercentage,
            recommendation:
                'Consider adjusting recommendation algorithm to better balance cuisine types. Review user preferences and ensure diversity in recommendations.',
          ),
        );
      }
    }

    // Check vendor size bias
    final smallVendorPercentage = vendorSizeMetrics['small'] ?? 0.0;
    if (smallVendorPercentage < 20.0) {
      alerts.add(
        BiasAlert(
          biasType: 'vendor_size',
          description:
              'Small vendors only represent ${smallVendorPercentage.toStringAsFixed(1)}% of recommendations',
          severity: smallVendorPercentage < 10.0
              ? BiasSeverity.high
              : BiasSeverity.medium,
          actualPercentage: smallVendorPercentage,
          expectedPercentage: 30.0, // Target: 30% small vendors
          recommendation:
              'Increase visibility for small vendors. Consider boosting small vendor recommendations or implementing diversity filters.',
        ),
      );
    }

    // Check region bias (flag if any region > 50%)
    for (var entry in regionDistribution.entries) {
      if (entry.value > 50.0) {
        alerts.add(
          BiasAlert(
            biasType: 'region',
            description:
                '${entry.key} region represents ${entry.value.toStringAsFixed(1)}% of recommendations',
            severity: entry.value > 70.0
                ? BiasSeverity.high
                : BiasSeverity.medium,
            actualPercentage: entry.value,
            recommendation:
                'Ensure recommendations are distributed across all regions. Review location-based filtering in recommendation algorithm.',
          ),
        );
      }
    }

    return alerts;
  }

  /// Get analysis period from recommendations
  Map<String, DateTime> _getAnalysisPeriod(
    List<Map<String, dynamic>> recommendations,
  ) {
    if (recommendations.isEmpty) {
      final now = DateTime.now();
      return {'start': now, 'end': now};
    }

    final dates = recommendations
        .map((r) => r['generatedAt'] as DateTime?)
        .whereType<DateTime>()
        .toList();

    if (dates.isEmpty) {
      final now = DateTime.now();
      return {'start': now, 'end': now};
    }

    dates.sort();
    return {'start': dates.first, 'end': dates.last};
  }

  /// Create empty metrics when no data is available
  FairnessMetrics _createEmptyMetrics() {
    final now = DateTime.now();
    return FairnessMetrics(
      cuisineDistribution: {},
      regionDistribution: {},
      smallVendorVisibility: 0.0,
      largeVendorVisibility: 0.0,
      diversityScore: 0.0,
      ndcgScore: 0.0,
      biasAlerts: [],
      totalRecommendations: 0,
      analysisStartDate: now,
      analysisEndDate: now,
      calculatedAt: now,
    );
  }
}

