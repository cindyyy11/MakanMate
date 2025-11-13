import 'package:equatable/equatable.dart';

/// Data quality metrics entity for platform data monitoring
/// 
/// Tracks overall data quality across the platform including:
/// - Menu completeness
/// - Halal certification coverage
/// - Data staleness
/// - Location accuracy
/// - Duplicate listings
class DataQualityMetrics extends Equatable {
  /// Overall quality score (0-100)
  final double overallQualityScore;
  
  /// Percentage of vendors with complete menus (>70%)
  final double menuCompleteness;
  
  /// Percentage of vendors with valid halal certs
  final double halalCoverage;
  
  /// Percentage of vendors with stale data (>30 days)
  final double staleness;
  
  /// Percentage of vendors with accurate location data
  final double locationAccuracy;
  
  /// Total number of vendors
  final int totalVendors;
  
  /// Number of vendors with complete menus
  final int vendorsWithCompleteMenus;
  
  /// Number of vendors with valid halal certs
  final int vendorsWithValidHalalCerts;
  
  /// Number of vendors with stale data
  final int vendorsStaleData;
  
  /// Number of duplicate listings
  final int duplicateListings;
  
  /// Total number of food items
  final int totalFoodItems;
  
  /// List of critical issues requiring attention
  final List<DataQualityIssue> criticalIssues;
  
  /// Vendor IDs with stale data
  final List<String> staleVendorIds;
  
  /// Vendor IDs with expired/missing halal certs
  final List<String> expiredCertVendorIds;
  
  /// Vendor IDs with incomplete menus
  final List<String> incompleteMenuVendorIds;
  
  /// Vendor IDs with duplicate listings
  final List<String> duplicateVendorIds;
  
  /// When metrics were calculated
  final DateTime calculatedAt;

  const DataQualityMetrics({
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

  @override
  List<Object> get props => [
        overallQualityScore,
        menuCompleteness,
        halalCoverage,
        staleness,
        locationAccuracy,
        totalVendors,
        vendorsWithCompleteMenus,
        vendorsWithValidHalalCerts,
        vendorsStaleData,
        duplicateListings,
        totalFoodItems,
        criticalIssues,
        staleVendorIds,
        expiredCertVendorIds,
        incompleteMenuVendorIds,
        duplicateVendorIds,
        calculatedAt,
      ];

  DataQualityMetrics copyWith({
    double? overallQualityScore,
    double? menuCompleteness,
    double? halalCoverage,
    double? staleness,
    double? locationAccuracy,
    int? totalVendors,
    int? vendorsWithCompleteMenus,
    int? vendorsWithValidHalalCerts,
    int? vendorsStaleData,
    int? duplicateListings,
    int? totalFoodItems,
    List<DataQualityIssue>? criticalIssues,
    List<String>? staleVendorIds,
    List<String>? expiredCertVendorIds,
    List<String>? incompleteMenuVendorIds,
    List<String>? duplicateVendorIds,
    DateTime? calculatedAt,
  }) {
    return DataQualityMetrics(
      overallQualityScore: overallQualityScore ?? this.overallQualityScore,
      menuCompleteness: menuCompleteness ?? this.menuCompleteness,
      halalCoverage: halalCoverage ?? this.halalCoverage,
      staleness: staleness ?? this.staleness,
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
      totalVendors: totalVendors ?? this.totalVendors,
      vendorsWithCompleteMenus: vendorsWithCompleteMenus ?? this.vendorsWithCompleteMenus,
      vendorsWithValidHalalCerts: vendorsWithValidHalalCerts ?? this.vendorsWithValidHalalCerts,
      vendorsStaleData: vendorsStaleData ?? this.vendorsStaleData,
      duplicateListings: duplicateListings ?? this.duplicateListings,
      totalFoodItems: totalFoodItems ?? this.totalFoodItems,
      criticalIssues: criticalIssues ?? this.criticalIssues,
      staleVendorIds: staleVendorIds ?? this.staleVendorIds,
      expiredCertVendorIds: expiredCertVendorIds ?? this.expiredCertVendorIds,
      incompleteMenuVendorIds: incompleteMenuVendorIds ?? this.incompleteMenuVendorIds,
      duplicateVendorIds: duplicateVendorIds ?? this.duplicateVendorIds,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }
}

/// Data quality issue indicating a problem requiring attention
class DataQualityIssue extends Equatable {
  /// Type of issue (e.g., 'incomplete_menu', 'missing_halal_cert', 'stale_data', 'duplicate_listing', 'invalid_location')
  final String issueType;
  
  /// Severity level (low, medium, high)
  final DataQualitySeverity severity;
  
  /// Description of the issue
  final String description;
  
  /// Vendor ID affected
  final String vendorId;
  
  /// Vendor name
  final String vendorName;
  
  /// Additional metadata (e.g., daysStale, completeness percentage)
  final Map<String, dynamic>? metadata;

  const DataQualityIssue({
    required this.issueType,
    required this.severity,
    required this.description,
    required this.vendorId,
    required this.vendorName,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        issueType,
        severity,
        description,
        vendorId,
        vendorName,
        metadata,
      ];
}

/// Data quality severity levels
enum DataQualitySeverity {
  low,
  medium,
  high,
}

