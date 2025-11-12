import 'package:equatable/equatable.dart';

/// Real-time system metrics entity
/// 
/// Contains current system-level metrics for real-time monitoring
class SystemMetrics extends Equatable {
  final int activeUsers;
  final int activeSessions;
  final int apiCallsPerMinute;
  final double avgResponseTime; // in milliseconds
  final int errorCount;
  final double errorRate; // percentage
  final SystemHealthStatus healthStatus;
  final DateTime lastUpdated;

  const SystemMetrics({
    required this.activeUsers,
    required this.activeSessions,
    required this.apiCallsPerMinute,
    required this.avgResponseTime,
    required this.errorCount,
    required this.errorRate,
    required this.healthStatus,
    required this.lastUpdated,
  });

  @override
  List<Object> get props => [
        activeUsers,
        activeSessions,
        apiCallsPerMinute,
        avgResponseTime,
        errorCount,
        errorRate,
        healthStatus,
        lastUpdated,
      ];

  SystemMetrics copyWith({
    int? activeUsers,
    int? activeSessions,
    int? apiCallsPerMinute,
    double? avgResponseTime,
    int? errorCount,
    double? errorRate,
    SystemHealthStatus? healthStatus,
    DateTime? lastUpdated,
  }) {
    return SystemMetrics(
      activeUsers: activeUsers ?? this.activeUsers,
      activeSessions: activeSessions ?? this.activeSessions,
      apiCallsPerMinute: apiCallsPerMinute ?? this.apiCallsPerMinute,
      avgResponseTime: avgResponseTime ?? this.avgResponseTime,
      errorCount: errorCount ?? this.errorCount,
      errorRate: errorRate ?? this.errorRate,
      healthStatus: healthStatus ?? this.healthStatus,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// System health status enum
enum SystemHealthStatus {
  healthy, // 🟢
  warning, // 🟡
  critical, // 🔴
}

/// Extension for SystemHealthStatus to add display methods
extension SystemHealthStatusExtension on SystemHealthStatus {
  String get displayName {
    switch (this) {
      case SystemHealthStatus.healthy:
        return 'Healthy';
      case SystemHealthStatus.warning:
        return 'Warning';
      case SystemHealthStatus.critical:
        return 'Critical';
    }
  }

  String get emoji {
    switch (this) {
      case SystemHealthStatus.healthy:
        return '🟢';
      case SystemHealthStatus.warning:
        return '🟡';
      case SystemHealthStatus.critical:
        return '🔴';
    }
  }
}

