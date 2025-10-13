import 'package:json_annotation/json_annotation.dart';
import 'package:makan_mate/models/base_model.dart';

part 'recommendation_models.g.dart';

@JsonSerializable()
class RecommendationItem extends BaseModel {
  final String itemId;
  final double score;
  final String reason;
  final String algorithmType;
  final double confidence;
  final Map<String, dynamic> metadata;
  final DateTime generatedAt;

  const RecommendationItem({
    required this.itemId,
    required this.score,
    required this.reason,
    required this.algorithmType,
    required this.confidence,
    this.metadata = const {},
    required this.generatedAt,
  });

  factory RecommendationItem.fromJson(Map<String, dynamic> json) =>
      _$RecommendationItemFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RecommendationItemToJson(this);

  RecommendationItem copyWith({
    String? itemId,
    double? score,
    String? reason,
    String? algorithmType,
    double? confidence,
    Map<String, dynamic>? metadata,
    DateTime? generatedAt,
  }) {
    return RecommendationItem(
      itemId: itemId ?? this.itemId,
      score: score ?? this.score,
      reason: reason ?? this.reason,
      algorithmType: algorithmType ?? this.algorithmType,
      confidence: confidence ?? this.confidence,
      metadata: metadata ?? this.metadata,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  List<Object?> get props => [
    itemId,
    score,
    reason,
    algorithmType,
    confidence,
    metadata,
    generatedAt,
  ];
}
