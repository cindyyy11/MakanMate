import 'package:equatable/equatable.dart';

/// System configuration settings
class SystemConfig extends Equatable {
  final String id;
  final int autoApprovalThreshold; // Risk score threshold
  final int deepVerificationThreshold; // Risk score for deep verification
  final int maxMenuItems; // Max items per vendor
  final int photoMaxSizeMB; // Max photo size
  final int reviewMinLength; // Min review length in chars
  final Map<String, dynamic> apiKeys; // API key management
  final Map<String, dynamic> performanceSettings; // Performance tuning
  final DateTime lastUpdated;
  final String updatedBy;

  const SystemConfig({
    required this.id,
    this.autoApprovalThreshold = 30,
    this.deepVerificationThreshold = 70,
    this.maxMenuItems = 100,
    this.photoMaxSizeMB = 5,
    this.reviewMinLength = 10,
    this.apiKeys = const {},
    this.performanceSettings = const {},
    required this.lastUpdated,
    required this.updatedBy,
  });

  @override
  List<Object?> get props => [
        id,
        autoApprovalThreshold,
        deepVerificationThreshold,
        maxMenuItems,
        photoMaxSizeMB,
        reviewMinLength,
        apiKeys,
        performanceSettings,
        lastUpdated,
        updatedBy,
      ];
}


