import 'package:equatable/equatable.dart';

/// Entity representing a single data point in a trend
class MetricDataPoint extends Equatable {
  final DateTime date;
  final double value;
  final String? label;

  const MetricDataPoint({required this.date, required this.value, this.label});

  @override
  List<Object?> get props => [date, value, label];
}

/// Entity representing trend data for a metric
class MetricTrend extends Equatable {
  final String metricName;
  final List<MetricDataPoint> dataPoints;
  final double currentValue;
  final double previousValue;
  final double percentageChange;

  const MetricTrend({
    required this.metricName,
    required this.dataPoints,
    required this.currentValue,
    required this.previousValue,
    required this.percentageChange,
  });

  bool get isIncreasing => percentageChange > 0;
  bool get isDecreasing => percentageChange < 0;

  @override
  List<Object> get props => [
    metricName,
    dataPoints,
    currentValue,
    previousValue,
    percentageChange,
  ];
}
