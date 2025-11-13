import 'package:equatable/equatable.dart';

/// A/B Test status
enum ABTestStatus {
  draft,
  running,
  paused,
  completed,
  cancelled,
}

/// A/B Test entity
/// 
/// Represents an A/B test experiment comparing two variants
class ABTest extends Equatable {
  final String id;
  final String name;
  final String description;
  final ABTestVariant control;
  final ABTestVariant treatment;
  final String metric; // e.g., 'click_through_rate', 'conversion_rate', 'engagement_rate'
  final int controlSplit; // Percentage (0-100)
  final int treatmentSplit; // Percentage (0-100)
  final ABTestStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final Map<String, dynamic>? metadata; // Additional test configuration

  const ABTest({
    required this.id,
    required this.name,
    required this.description,
    required this.control,
    required this.treatment,
    required this.metric,
    required this.controlSplit,
    required this.treatmentSplit,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        control,
        treatment,
        metric,
        controlSplit,
        treatmentSplit,
        status,
        startDate,
        endDate,
        createdAt,
        updatedAt,
        createdBy,
        metadata,
      ];

  ABTest copyWith({
    String? id,
    String? name,
    String? description,
    ABTestVariant? control,
    ABTestVariant? treatment,
    String? metric,
    int? controlSplit,
    int? treatmentSplit,
    ABTestStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    Map<String, dynamic>? metadata,
  }) {
    return ABTest(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      control: control ?? this.control,
      treatment: treatment ?? this.treatment,
      metric: metric ?? this.metric,
      controlSplit: controlSplit ?? this.controlSplit,
      treatmentSplit: treatmentSplit ?? this.treatmentSplit,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// A/B Test Variant entity
/// 
/// Represents a variant in an A/B test (control or treatment)
class ABTestVariant extends Equatable {
  final String id;
  final String name;
  final String description;
  final String type; // 'control' or 'treatment'
  final Map<String, dynamic> config; // Variant-specific configuration

  const ABTestVariant({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.config,
  });

  @override
  List<Object?> get props => [id, name, description, type, config];

  ABTestVariant copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    Map<String, dynamic>? config,
  }) {
    return ABTestVariant(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      config: config ?? this.config,
    );
  }
}

/// A/B Test Result entity
/// 
/// Contains statistical analysis results for an A/B test
class ABTestResult extends Equatable {
  final String testId;
  final ABTestVariantMetrics controlMetrics;
  final ABTestVariantMetrics treatmentMetrics;
  final double improvement; // Percentage improvement
  final double confidence; // Statistical confidence (0-100)
  final bool isSignificant; // Whether the result is statistically significant
  final String? winner; // 'control' or 'treatment' or null if inconclusive
  final DateTime calculatedAt;
  final int totalParticipants;
  final int controlParticipants;
  final int treatmentParticipants;

  const ABTestResult({
    required this.testId,
    required this.controlMetrics,
    required this.treatmentMetrics,
    required this.improvement,
    required this.confidence,
    required this.isSignificant,
    this.winner,
    required this.calculatedAt,
    required this.totalParticipants,
    required this.controlParticipants,
    required this.treatmentParticipants,
  });

  @override
  List<Object?> get props => [
        testId,
        controlMetrics,
        treatmentMetrics,
        improvement,
        confidence,
        isSignificant,
        winner,
        calculatedAt,
        totalParticipants,
        controlParticipants,
        treatmentParticipants,
      ];
}

/// A/B Test Variant Metrics
/// 
/// Metrics for a specific variant
class ABTestVariantMetrics extends Equatable {
  final String variantId;
  final double metricValue; // The actual metric value (e.g., CTR: 15.2%)
  final int participants;
  final int events; // Number of events (e.g., clicks)
  final int impressions; // Number of impressions/views
  final double conversionRate; // events / impressions

  const ABTestVariantMetrics({
    required this.variantId,
    required this.metricValue,
    required this.participants,
    required this.events,
    required this.impressions,
    required this.conversionRate,
  });

  @override
  List<Object?> get props => [
        variantId,
        metricValue,
        participants,
        events,
        impressions,
        conversionRate,
      ];
}

/// A/B Test Assignment entity
/// 
/// Tracks which user is assigned to which variant
class ABTestAssignment extends Equatable {
  final String id;
  final String testId;
  final String userId;
  final String variantId; // 'control' or 'treatment'
  final DateTime assignedAt;
  final DateTime? lastSeenAt;

  const ABTestAssignment({
    required this.id,
    required this.testId,
    required this.userId,
    required this.variantId,
    required this.assignedAt,
    this.lastSeenAt,
  });

  @override
  List<Object?> get props => [
        id,
        testId,
        userId,
        variantId,
        assignedAt,
        lastSeenAt,
      ];
}


