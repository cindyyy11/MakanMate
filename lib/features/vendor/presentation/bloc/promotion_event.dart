import 'dart:io';
import '../../../vendor/domain/entities/promotion_entity.dart';

abstract class PromotionEvent {}

class LoadPromotionsEvent extends PromotionEvent {}

class FilterPromotionsByStatusEvent extends PromotionEvent {
  final String? status; // 'active', 'expired', or null for all
  FilterPromotionsByStatusEvent(this.status);
}

class AddPromotionEvent extends PromotionEvent {
  final PromotionEntity promotion;
  final File? imageFile;
  AddPromotionEvent(this.promotion, {this.imageFile});
}

class UpdatePromotionEvent extends PromotionEvent {
  final PromotionEntity promotion;
  final File? imageFile;
  UpdatePromotionEvent(this.promotion, {this.imageFile});
}

class DeletePromotionEvent extends PromotionEvent {
  final String id;
  DeletePromotionEvent(this.id);
}

class DeactivatePromotionEvent extends PromotionEvent {
  final String id;
  DeactivatePromotionEvent(this.id);
}

