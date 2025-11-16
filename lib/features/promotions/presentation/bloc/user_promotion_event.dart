abstract class UserPromotionEvent {}

class LoadUserPromotionsEvent extends UserPromotionEvent {}

class UserPromotionClickEvent extends UserPromotionEvent {
  final String vendorId;
  final String promotionId;
  
  UserPromotionClickEvent({
    required this.vendorId,
    required this.promotionId,
  });
}

class UserPromotionRedeemedEvent extends UserPromotionEvent {
  final String vendorId;
  final String promotionId;
  
  UserPromotionRedeemedEvent({
    required this.vendorId,
    required this.promotionId,
  });
}

