import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/features/admin/domain/entities/metric_trend_entity.dart';

/// Data model for metric trend
class MetricTrendModel extends MetricTrend {
  const MetricTrendModel({
    required super.metricName,
    required super.dataPoints,
    required super.currentValue,
    required super.previousValue,
    required super.percentageChange,
  });

  factory MetricTrendModel.fromJson(Map<String, dynamic> json) {
    final dataPoints =
        (json['dataPoints'] as List?)
            ?.map(
              (e) => MetricDataPoint(
                date: (e['date'] as Timestamp).toDate(),
                value: (e['value'] as num).toDouble(),
                label: e['label'] as String?,
              ),
            )
            .toList() ??
        [];

    return MetricTrendModel(
      metricName: json['metricName'] as String,
      dataPoints: dataPoints,
      currentValue: (json['currentValue'] as num).toDouble(),
      previousValue: (json['previousValue'] as num).toDouble(),
      percentageChange: (json['percentageChange'] as num).toDouble(),
    );
  }

  MetricTrend toEntity() {
    return MetricTrend(
      metricName: metricName,
      dataPoints: dataPoints,
      currentValue: currentValue,
      previousValue: previousValue,
      percentageChange: percentageChange,
    );
  }
}
