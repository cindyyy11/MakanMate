import '../../../vendor/domain/entities/promotion_entity.dart';

abstract class UserPromotionState {}

class UserPromotionInitial extends UserPromotionState {}

class UserPromotionLoading extends UserPromotionState {}

class UserPromotionLoaded extends UserPromotionState {
  final List<PromotionEntity> promotions;
  
  UserPromotionLoaded(this.promotions);
}

class UserPromotionError extends UserPromotionState {
  final String message;
  UserPromotionError(this.message);
}

