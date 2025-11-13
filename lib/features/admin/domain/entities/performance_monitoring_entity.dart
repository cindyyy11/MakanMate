import 'package:equatable/equatable.dart';

/// Performance monitoring metrics
class PerformanceMetrics extends Equatable {
  final String id;
  final double avgApiResponseTime; // milliseconds
  final List<SlowQuery> slowQueries;
  final double databaseSizeGB;
  final double cacheHitRate; // Percentage
  final List<PerformanceAlert> alerts;
  final DateTime timestamp;

  const PerformanceMetrics({
    required this.id,
    required this.avgApiResponseTime,
    this.slowQueries = const [],
    required this.databaseSizeGB,
    required this.cacheHitRate,
    this.alerts = const [],
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        avgApiResponseTime,
        slowQueries,
        databaseSizeGB,
        cacheHitRate,
        alerts,
        timestamp,
      ];
}

class SlowQuery extends Equatable {
  final String id;
  final String query;
  final double executionTime; // milliseconds
  final int callCount;
  final String severity; // Low, Medium, High

  const SlowQuery({
    required this.id,
    required this.query,
    required this.executionTime,
    required this.callCount,
    required this.severity,
  });

  @override
  List<Object?> get props => [
        id,
        query,
        executionTime,
        callCount,
        severity,
      ];
}

class PerformanceAlert extends Equatable {
  final String id;
  final String type; // Slow API, High DB Usage, Low Cache Hit Rate
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;

  const PerformanceAlert({
    required this.id,
    required this.type,
    required this.message,
    required this.severity,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, type, message, severity, timestamp];
}

enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}


