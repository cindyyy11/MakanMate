import 'package:makan_mate/features/admin/domain/entities/fairness_metrics_entity.dart';

/// Interface for calculating fairness metrics
///
/// This interface belongs in the domain layer to maintain clean architecture.
/// The implementation will be in the data layer (datasource).
abstract class FairnessMetricsCalculatorInterface {
  /// Calculate fairness metrics from last N recommendations
  Future<FairnessMetrics> calculateFairnessMetrics({
    int recommendationLimit = 1000,
    DateTime? startDate,
    DateTime? endDate,
  });
}
