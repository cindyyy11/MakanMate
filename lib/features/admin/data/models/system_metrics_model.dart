import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/features/admin/domain/entities/system_metrics_entity.dart';

/// Data model for system metrics
/// 
/// Handles conversion between Firestore data and domain entity
class SystemMetricsModel extends SystemMetrics {
  const SystemMetricsModel({
    required super.activeUsers,
    required super.activeSessions,
    required super.apiCallsPerMinute,
    required super.avgResponseTime,
    required super.errorCount,
    required super.errorRate,
    required super.healthStatus,
    required super.lastUpdated,
  });

  factory SystemMetricsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Determine health status based on metrics
    final errorRate = (data['errorRate'] as num?)?.toDouble() ?? 0.0;
    final avgResponseTime = (data['avgResponseTime'] as num?)?.toDouble() ?? 0.0;
    
    SystemHealthStatus healthStatus;
    if (errorRate > 5.0 || avgResponseTime > 1000) {
      healthStatus = SystemHealthStatus.critical;
    } else if (errorRate > 2.0 || avgResponseTime > 500) {
      healthStatus = SystemHealthStatus.warning;
    } else {
      healthStatus = SystemHealthStatus.healthy;
    }

    return SystemMetricsModel(
      activeUsers: data['activeUsers'] as int? ?? 0,
      activeSessions: data['activeSessions'] as int? ?? 0,
      apiCallsPerMinute: data['apiCallsPerMinute'] as int? ?? 0,
      avgResponseTime: avgResponseTime,
      errorCount: data['errorCount'] as int? ?? 0,
      errorRate: errorRate,
      healthStatus: healthStatus,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert model to entity
  SystemMetrics toEntity() => this;
}

