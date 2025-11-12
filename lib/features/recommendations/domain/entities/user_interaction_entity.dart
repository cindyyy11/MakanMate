import 'package:equatable/equatable.dart';

/// User interaction entity (Domain layer)
/// Represents a user's interaction with a food item
class UserInteractionEntity extends Equatable {
  final String id;
  final String userId;
  final String itemId;
  final String interactionType;
  final double? rating;
  final DateTime timestamp;
  final Map<String, dynamic>? context;

  const UserInteractionEntity({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.interactionType,
    this.rating,
    required this.timestamp,
    this.context,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    itemId,
    interactionType,
    rating,
    timestamp,
    context,
  ];
}
