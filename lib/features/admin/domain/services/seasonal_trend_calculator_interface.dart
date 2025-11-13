import 'package:makan_mate/features/admin/domain/entities/seasonal_trend_entity.dart';

/// Interface for calculating seasonal trend analysis
///
/// This interface belongs in the domain layer to maintain clean architecture.
/// The implementation will be in the data layer (datasource).
abstract class SeasonalTrendCalculatorInterface {
  /// Calculate seasonal trend analysis
  ///
  /// Analyzes search patterns, detects current season, identifies trending
  /// dishes/cuisines, and predicts upcoming events
  Future<SeasonalTrendAnalysis> calculateSeasonalTrends({
    DateTime? startDate,
    DateTime? endDate,
  });
}


