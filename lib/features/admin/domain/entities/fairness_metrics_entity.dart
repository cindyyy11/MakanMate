import 'package:equatable/equatable.dart';

/// Fairness metrics entity for AI recommendation monitoring
/// 
/// Tracks bias patterns in recommendations to ensure fair distribution
class FairnessMetrics extends Equatable {
  /// Cuisine distribution - percentage of recommendations per cuisine
  final Map<String, double> cuisineDistribution;
  
  /// Region distribution - percentage of recommendations per region
  final Map<String, double> regionDistribution;
  
  /// Small vendor visibility percentage
  final double smallVendorVisibility;
  
  /// Large vendor visibility percentage
  final double largeVendorVisibility;
  
  /// Diversity score (0-1, where 1 is most diverse)
  final double diversityScore;
  
  /// NDCG score (Normalized Discounted Cumulative Gain) - recommendation quality
  final double ndcgScore;
  
  /// Bias alerts - list of detected bias patterns
  final List<BiasAlert> biasAlerts;
  
  /// Total recommendations analyzed
  final int totalRecommendations;
  
  /// Analysis period start
  final DateTime analysisStartDate;
  
  /// Analysis period end
  final DateTime analysisEndDate;
  
  /// When metrics were calculated
  final DateTime calculatedAt;

  const FairnessMetrics({
    required this.cuisineDistribution,
    required this.regionDistribution,
    required this.smallVendorVisibility,
    required this.largeVendorVisibility,
    required this.diversityScore,
    required this.ndcgScore,
    required this.biasAlerts,
    required this.totalRecommendations,
    required this.analysisStartDate,
    required this.analysisEndDate,
    required this.calculatedAt,
  });

  @override
  List<Object> get props => [
        cuisineDistribution,
        regionDistribution,
        smallVendorVisibility,
        largeVendorVisibility,
        diversityScore,
        ndcgScore,
        biasAlerts,
        totalRecommendations,
        analysisStartDate,
        analysisEndDate,
        calculatedAt,
      ];

  FairnessMetrics copyWith({
    Map<String, double>? cuisineDistribution,
    Map<String, double>? regionDistribution,
    double? smallVendorVisibility,
    double? largeVendorVisibility,
    double? diversityScore,
    double? ndcgScore,
    List<BiasAlert>? biasAlerts,
    int? totalRecommendations,
    DateTime? analysisStartDate,
    DateTime? analysisEndDate,
    DateTime? calculatedAt,
  }) {
    return FairnessMetrics(
      cuisineDistribution: cuisineDistribution ?? this.cuisineDistribution,
      regionDistribution: regionDistribution ?? this.regionDistribution,
      smallVendorVisibility: smallVendorVisibility ?? this.smallVendorVisibility,
      largeVendorVisibility: largeVendorVisibility ?? this.largeVendorVisibility,
      diversityScore: diversityScore ?? this.diversityScore,
      ndcgScore: ndcgScore ?? this.ndcgScore,
      biasAlerts: biasAlerts ?? this.biasAlerts,
      totalRecommendations: totalRecommendations ?? this.totalRecommendations,
      analysisStartDate: analysisStartDate ?? this.analysisStartDate,
      analysisEndDate: analysisEndDate ?? this.analysisEndDate,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }
}

/// Bias alert indicating a detected bias pattern
class BiasAlert extends Equatable {
  /// Type of bias (e.g., 'cuisine', 'vendor_size', 'region')
  final String biasType;
  
  /// Description of the bias
  final String description;
  
  /// Severity level (low, medium, high)
  final BiasSeverity severity;
  
  /// Actual percentage
  final double actualPercentage;
  
  /// Expected percentage (if available)
  final double? expectedPercentage;
  
  /// Recommendation to fix the bias
  final String recommendation;

  const BiasAlert({
    required this.biasType,
    required this.description,
    required this.severity,
    required this.actualPercentage,
    this.expectedPercentage,
    required this.recommendation,
  });

  @override
  List<Object?> get props => [
        biasType,
        description,
        severity,
        actualPercentage,
        expectedPercentage,
        recommendation,
      ];
}

/// Bias severity levels
enum BiasSeverity {
  low,
  medium,
  high,
}


