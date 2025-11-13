import '../../../vendor/domain/entities/promotion_entity.dart';

abstract class PromotionState {}

class PromotionInitial extends PromotionState {}

class PromotionLoading extends PromotionState {}

class PromotionLoaded extends PromotionState {
  final List<PromotionEntity> promotions;
  final List<PromotionEntity> filteredPromotions;
  final String? selectedStatus; // 'active', 'expired', or null for all
  
  PromotionLoaded(
    this.promotions, {
    List<PromotionEntity>? filteredPromotions,
    this.selectedStatus,
  }) : filteredPromotions = filteredPromotions ?? promotions;
}

class PromotionError extends PromotionState {
  final String message;
  PromotionError(this.message);
}

// Image upload states
class PromotionImageUploading extends PromotionState {
  final double? progress;
  PromotionImageUploading({this.progress});
}

class PromotionImageUploaded extends PromotionState {
  final String imageUrl;
  PromotionImageUploaded(this.imageUrl);
}

class PromotionImageUploadError extends PromotionState {
  final String message;
  PromotionImageUploadError(this.message);
}

