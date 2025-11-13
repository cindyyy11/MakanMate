import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/features/admin/domain/entities/ab_test_entity.dart';

/// Data model for A/B Test
class ABTestModel extends ABTest {
  const ABTestModel({
    required super.id,
    required super.name,
    required super.description,
    required super.control,
    required super.treatment,
    required super.metric,
    required super.controlSplit,
    required super.treatmentSplit,
    required super.status,
    required super.startDate,
    super.endDate,
    required super.createdAt,
    required super.updatedAt,
    super.createdBy,
    super.metadata,
  });

  /// Create from Firestore document
  factory ABTestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ABTestModel.fromJson(data, doc.id);
  }

  /// Create from JSON
  factory ABTestModel.fromJson(Map<String, dynamic> json, String id) {
    return ABTestModel(
      id: id,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      control: ABTestVariantModel.fromJson(
        json['control'] as Map<String, dynamic>? ?? {},
      ),
      treatment: ABTestVariantModel.fromJson(
        json['treatment'] as Map<String, dynamic>? ?? {},
      ),
      metric: json['metric'] as String? ?? '',
      controlSplit: json['controlSplit'] as int? ?? 50,
      treatmentSplit: json['treatmentSplit'] as int? ?? 50,
      status: ABTestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ABTestStatus.draft,
      ),
      startDate: json['startDate'] != null
          ? (json['startDate'] as Timestamp).toDate()
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? (json['endDate'] as Timestamp).toDate()
          : null,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      createdBy: json['createdBy'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'control': (control as ABTestVariantModel).toJson(),
      'treatment': (treatment as ABTestVariantModel).toJson(),
      'metric': metric,
      'controlSplit': controlSplit,
      'treatmentSplit': treatmentSplit,
      'status': status.name,
      'startDate': Timestamp.fromDate(startDate),
      if (endDate != null) 'endDate': Timestamp.fromDate(endDate!),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (createdBy != null) 'createdBy': createdBy,
      if (metadata != null) 'metadata': metadata,
    };
  }

  @override
  ABTestModel copyWith({
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
    return ABTestModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      control: (control ?? this.control) as ABTestVariantModel,
      treatment: (treatment ?? this.treatment) as ABTestVariantModel,
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

/// Data model for A/B Test Variant
class ABTestVariantModel extends ABTestVariant {
  const ABTestVariantModel({
    required super.id,
    required super.name,
    required super.description,
    required super.type,
    required super.config,
  });

  factory ABTestVariantModel.fromJson(Map<String, dynamic> json) {
    return ABTestVariantModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'control',
      config: json['config'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'config': config,
    };
  }
}

/// Data model for A/B Test Result
class ABTestResultModel extends ABTestResult {
  const ABTestResultModel({
    required super.testId,
    required super.controlMetrics,
    required super.treatmentMetrics,
    required super.improvement,
    required super.confidence,
    required super.isSignificant,
    super.winner,
    required super.calculatedAt,
    required super.totalParticipants,
    required super.controlParticipants,
    required super.treatmentParticipants,
  });

  factory ABTestResultModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ABTestResultModel.fromJson(data);
  }

  factory ABTestResultModel.fromJson(Map<String, dynamic> json) {
    return ABTestResultModel(
      testId: json['testId'] as String? ?? '',
      controlMetrics: ABTestVariantMetricsModel.fromJson(
        json['controlMetrics'] as Map<String, dynamic>? ?? {},
      ),
      treatmentMetrics: ABTestVariantMetricsModel.fromJson(
        json['treatmentMetrics'] as Map<String, dynamic>? ?? {},
      ),
      improvement: (json['improvement'] as num?)?.toDouble() ?? 0.0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      isSignificant: json['isSignificant'] as bool? ?? false,
      winner: json['winner'] as String?,
      calculatedAt: json['calculatedAt'] != null
          ? (json['calculatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      totalParticipants: json['totalParticipants'] as int? ?? 0,
      controlParticipants: json['controlParticipants'] as int? ?? 0,
      treatmentParticipants: json['treatmentParticipants'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'testId': testId,
      'controlMetrics': (controlMetrics as ABTestVariantMetricsModel).toJson(),
      'treatmentMetrics':
          (treatmentMetrics as ABTestVariantMetricsModel).toJson(),
      'improvement': improvement,
      'confidence': confidence,
      'isSignificant': isSignificant,
      if (winner != null) 'winner': winner,
      'calculatedAt': Timestamp.fromDate(calculatedAt),
      'totalParticipants': totalParticipants,
      'controlParticipants': controlParticipants,
      'treatmentParticipants': treatmentParticipants,
    };
  }
}

/// Data model for A/B Test Variant Metrics
class ABTestVariantMetricsModel extends ABTestVariantMetrics {
  const ABTestVariantMetricsModel({
    required super.variantId,
    required super.metricValue,
    required super.participants,
    required super.events,
    required super.impressions,
    required super.conversionRate,
  });

  factory ABTestVariantMetricsModel.fromJson(Map<String, dynamic> json) {
    return ABTestVariantMetricsModel(
      variantId: json['variantId'] as String? ?? '',
      metricValue: (json['metricValue'] as num?)?.toDouble() ?? 0.0,
      participants: json['participants'] as int? ?? 0,
      events: json['events'] as int? ?? 0,
      impressions: json['impressions'] as int? ?? 0,
      conversionRate: (json['conversionRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'variantId': variantId,
      'metricValue': metricValue,
      'participants': participants,
      'events': events,
      'impressions': impressions,
      'conversionRate': conversionRate,
    };
  }
}

/// Data model for A/B Test Assignment
class ABTestAssignmentModel extends ABTestAssignment {
  const ABTestAssignmentModel({
    required super.id,
    required super.testId,
    required super.userId,
    required super.variantId,
    required super.assignedAt,
    super.lastSeenAt,
  });

  factory ABTestAssignmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ABTestAssignmentModel.fromJson(data, doc.id);
  }

  factory ABTestAssignmentModel.fromJson(Map<String, dynamic> json, String id) {
    return ABTestAssignmentModel(
      id: id,
      testId: json['testId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      variantId: json['variantId'] as String? ?? '',
      assignedAt: json['assignedAt'] != null
          ? (json['assignedAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastSeenAt: json['lastSeenAt'] != null
          ? (json['lastSeenAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'testId': testId,
      'userId': userId,
      'variantId': variantId,
      'assignedAt': Timestamp.fromDate(assignedAt),
      if (lastSeenAt != null) 'lastSeenAt': Timestamp.fromDate(lastSeenAt!),
    };
  }

  ABTestAssignmentModel copyWith({
    String? id,
    String? testId,
    String? userId,
    String? variantId,
    DateTime? assignedAt,
    DateTime? lastSeenAt,
  }) {
    return ABTestAssignmentModel(
      id: id ?? this.id,
      testId: testId ?? this.testId,
      userId: userId ?? this.userId,
      variantId: variantId ?? this.variantId,
      assignedAt: assignedAt ?? this.assignedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }
}

