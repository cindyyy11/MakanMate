import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/features/admin/domain/entities/data_quality_metrics_entity.dart';

/// Model for data quality metrics
class DataQualityMetricsModel {
  final double overallQualityScore;
  final double menuCompleteness;
  final double halalCoverage;
  final double staleness;
  final double locationAccuracy;
  final int totalVendors;
  final int vendorsWithCompleteMenus;
  final int vendorsWithValidHalalCerts;
  final int vendorsStaleData;
  final int duplicateListings;
  final int totalFoodItems;
  final List<DataQualityIssue> criticalIssues;
  final List<String> staleVendorIds;
  final List<String> expiredCertVendorIds;
  final List<String> incompleteMenuVendorIds;
  final List<String> duplicateVendorIds;
  final DateTime calculatedAt;

  DataQualityMetricsModel({
    required this.overallQualityScore,
    required this.menuCompleteness,
    required this.halalCoverage,
    required this.staleness,
    required this.locationAccuracy,
    required this.totalVendors,
    required this.vendorsWithCompleteMenus,
    required this.vendorsWithValidHalalCerts,
    required this.vendorsStaleData,
    required this.duplicateListings,
    required this.totalFoodItems,
    required this.criticalIssues,
    required this.staleVendorIds,
    required this.expiredCertVendorIds,
    required this.incompleteMenuVendorIds,
    required this.duplicateVendorIds,
    required this.calculatedAt,
  });

  /// Convert to domain entity
  DataQualityMetrics toEntity() {
    return DataQualityMetrics(
      overallQualityScore: overallQualityScore,
      menuCompleteness: menuCompleteness,
      halalCoverage: halalCoverage,
      staleness: staleness,
      locationAccuracy: locationAccuracy,
      totalVendors: totalVendors,
      vendorsWithCompleteMenus: vendorsWithCompleteMenus,
      vendorsWithValidHalalCerts: vendorsWithValidHalalCerts,
      vendorsStaleData: vendorsStaleData,
      duplicateListings: duplicateListings,
      totalFoodItems: totalFoodItems,
      criticalIssues: criticalIssues,
      staleVendorIds: staleVendorIds,
      expiredCertVendorIds: expiredCertVendorIds,
      incompleteMenuVendorIds: incompleteMenuVendorIds,
      duplicateVendorIds: duplicateVendorIds,
      calculatedAt: calculatedAt,
    );
  }

  /// Create from Firestore document
  factory DataQualityMetricsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse critical issues
    final issuesData = data['criticalIssues'] as List<dynamic>? ?? [];
    final criticalIssues = issuesData.map((issue) {
      final issueMap = issue as Map<String, dynamic>;
      return DataQualityIssue(
        issueType: issueMap['issueType'] as String,
        severity: _parseSeverity(issueMap['severity'] as String),
        description: issueMap['description'] as String,
        vendorId: issueMap['vendorId'] as String,
        vendorName: issueMap['vendorName'] as String? ?? 'Unknown',
        metadata: issueMap['daysStale'] != null
            ? {'daysStale': issueMap['daysStale']}
            : issueMap['completeness'] != null
                ? {'completeness': issueMap['completeness']}
                : null,
      );
    }).toList();
    
    // Parse lists
    final staleVendorIds = (data['staleVendorIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];
    final expiredCertVendorIds = (data['expiredCertVendorIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];
    final incompleteMenuVendorIds = (data['incompleteMenuVendorIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];
    final duplicateVendorIds = (data['duplicateVendorIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];
    
    return DataQualityMetricsModel(
      overallQualityScore: (data['overallQualityScore'] as num?)?.toDouble() ?? 0.0,
      menuCompleteness: (data['menuCompleteness'] as num?)?.toDouble() ?? 0.0,
      halalCoverage: (data['halalCoverage'] as num?)?.toDouble() ?? 0.0,
      staleness: (data['staleness'] as num?)?.toDouble() ?? 0.0,
      locationAccuracy: (data['locationAccuracy'] as num?)?.toDouble() ?? 0.0,
      totalVendors: data['totalVendors'] as int? ?? 0,
      vendorsWithCompleteMenus: data['vendorsWithCompleteMenus'] as int? ?? 0,
      vendorsWithValidHalalCerts: data['vendorsWithValidHalalCerts'] as int? ?? 0,
      vendorsStaleData: data['vendorsStaleData'] as int? ?? 0,
      duplicateListings: data['duplicateListings'] as int? ?? 0,
      totalFoodItems: data['totalFoodItems'] as int? ?? 0,
      criticalIssues: criticalIssues,
      staleVendorIds: staleVendorIds,
      expiredCertVendorIds: expiredCertVendorIds,
      incompleteMenuVendorIds: incompleteMenuVendorIds,
      duplicateVendorIds: duplicateVendorIds,
      calculatedAt: (data['calculatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'overallQualityScore': overallQualityScore,
      'menuCompleteness': menuCompleteness,
      'halalCoverage': halalCoverage,
      'staleness': staleness,
      'locationAccuracy': locationAccuracy,
      'totalVendors': totalVendors,
      'vendorsWithCompleteMenus': vendorsWithCompleteMenus,
      'vendorsWithValidHalalCerts': vendorsWithValidHalalCerts,
      'vendorsStaleData': vendorsStaleData,
      'duplicateListings': duplicateListings,
      'totalFoodItems': totalFoodItems,
      'criticalIssues': criticalIssues.map((issue) => {
        'issueType': issue.issueType,
        'severity': issue.severity.toString().split('.').last,
        'description': issue.description,
        'vendorId': issue.vendorId,
        'vendorName': issue.vendorName,
        if (issue.metadata != null) ...issue.metadata!,
      }).toList(),
      'staleVendorIds': staleVendorIds,
      'expiredCertVendorIds': expiredCertVendorIds,
      'incompleteMenuVendorIds': incompleteMenuVendorIds,
      'duplicateVendorIds': duplicateVendorIds,
      'calculatedAt': Timestamp.fromDate(calculatedAt),
    };
  }

  static DataQualitySeverity _parseSeverity(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return DataQualitySeverity.high;
      case 'medium':
        return DataQualitySeverity.medium;
      case 'low':
      default:
        return DataQualitySeverity.low;
    }
  }
}

