import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/features/admin/domain/entities/fairness_metrics_entity.dart';

/// Model for fairness metrics
class FairnessMetricsModel {
  final Map<String, double> cuisineDistribution;
  final Map<String, double> regionDistribution;
  final double smallVendorVisibility;
  final double largeVendorVisibility;
  final double diversityScore;
  final double ndcgScore;
  final List<BiasAlert> biasAlerts;
  final int totalRecommendations;
  final DateTime analysisStartDate;
  final DateTime analysisEndDate;
  final DateTime calculatedAt;

  FairnessMetricsModel({
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

  /// Convert to domain entity
  FairnessMetrics toEntity() {
    return FairnessMetrics(
      cuisineDistribution: cuisineDistribution,
      regionDistribution: regionDistribution,
      smallVendorVisibility: smallVendorVisibility,
      largeVendorVisibility: largeVendorVisibility,
      diversityScore: diversityScore,
      ndcgScore: ndcgScore,
      biasAlerts: biasAlerts,
      totalRecommendations: totalRecommendations,
      analysisStartDate: analysisStartDate,
      analysisEndDate: analysisEndDate,
      calculatedAt: calculatedAt,
    );
  }

  /// Create from Firestore document
  factory FairnessMetricsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse cuisine distribution
    final cuisineData = data['cuisineDistribution'] as Map<String, dynamic>? ?? {};
    final cuisineDistribution = cuisineData.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );
    
    // Parse region distribution
    final regionData = data['regionDistribution'] as Map<String, dynamic>? ?? {};
    final regionDistribution = regionData.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );
    
    // Parse bias alerts
    final alertsData = data['biasAlerts'] as List<dynamic>? ?? [];
    final biasAlerts = alertsData.map((alert) {
      final alertMap = alert as Map<String, dynamic>;
      return BiasAlert(
        biasType: alertMap['biasType'] as String,
        description: alertMap['description'] as String,
        severity: _parseSeverity(alertMap['severity'] as String),
        actualPercentage: (alertMap['actualPercentage'] as num).toDouble(),
        expectedPercentage: alertMap['expectedPercentage'] != null
            ? (alertMap['expectedPercentage'] as num).toDouble()
            : null,
        recommendation: alertMap['recommendation'] as String,
      );
    }).toList();
    
    return FairnessMetricsModel(
      cuisineDistribution: cuisineDistribution,
      regionDistribution: regionDistribution,
      smallVendorVisibility: (data['smallVendorVisibility'] as num?)?.toDouble() ?? 0.0,
      largeVendorVisibility: (data['largeVendorVisibility'] as num?)?.toDouble() ?? 0.0,
      diversityScore: (data['diversityScore'] as num?)?.toDouble() ?? 0.0,
      ndcgScore: (data['ndcgScore'] as num?)?.toDouble() ?? 0.0,
      biasAlerts: biasAlerts,
      totalRecommendations: data['totalRecommendations'] as int? ?? 0,
      analysisStartDate: (data['analysisStartDate'] as Timestamp).toDate(),
      analysisEndDate: (data['analysisEndDate'] as Timestamp).toDate(),
      calculatedAt: (data['calculatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'cuisineDistribution': cuisineDistribution,
      'regionDistribution': regionDistribution,
      'smallVendorVisibility': smallVendorVisibility,
      'largeVendorVisibility': largeVendorVisibility,
      'diversityScore': diversityScore,
      'ndcgScore': ndcgScore,
      'biasAlerts': biasAlerts.map((alert) => {
        'biasType': alert.biasType,
        'description': alert.description,
        'severity': alert.severity.toString().split('.').last,
        'actualPercentage': alert.actualPercentage,
        'expectedPercentage': alert.expectedPercentage,
        'recommendation': alert.recommendation,
      }).toList(),
      'totalRecommendations': totalRecommendations,
      'analysisStartDate': Timestamp.fromDate(analysisStartDate),
      'analysisEndDate': Timestamp.fromDate(analysisEndDate),
      'calculatedAt': Timestamp.fromDate(calculatedAt),
    };
  }

  static BiasSeverity _parseSeverity(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return BiasSeverity.high;
      case 'medium':
        return BiasSeverity.medium;
      case 'low':
      default:
        return BiasSeverity.low;
    }
  }
}


