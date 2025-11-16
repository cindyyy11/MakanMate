import 'package:flutter_bloc/flutter_bloc.dart';
import 'promotion_event.dart';
import 'promotion_state.dart';
import '../../../vendor/domain/usecases/get_promotions_usecase.dart';
import '../../../vendor/domain/usecases/get_promotions_by_status_usecase.dart';
import '../../../vendor/domain/usecases/add_promotion_usecase.dart';
import '../../../vendor/domain/usecases/update_promotion_usecase.dart';
import '../../../vendor/domain/usecases/delete_promotion_usecase.dart';
import '../../../vendor/domain/usecases/deactivate_promotion_usecase.dart';
import '../../../vendor/domain/usecases/increment_promotion_click_usecase.dart';
import '../../../vendor/domain/usecases/increment_promotion_redeemed_usecase.dart';
import '../../../vendor/data/services/storage_service.dart';
import '../../../vendor/domain/entities/promotion_entity.dart';

class PromotionBloc extends Bloc<PromotionEvent, PromotionState> {
  final GetPromotionsUseCase getPromotions;
  final GetPromotionsByStatusUseCase getPromotionsByStatus;
  final AddPromotionUseCase addPromotion;
  final UpdatePromotionUseCase updatePromotion;
  final DeletePromotionUseCase deletePromotion;
  final DeactivatePromotionUseCase deactivatePromotion;
  final IncrementPromotionClickUseCase incrementPromotionClick;
  final IncrementPromotionRedeemedUseCase incrementPromotionRedeemed;
  final StorageService storageService;

  PromotionBloc({
    required this.getPromotions,
    required this.getPromotionsByStatus,
    required this.addPromotion,
    required this.updatePromotion,
    required this.deletePromotion,
    required this.deactivatePromotion,
    required this.incrementPromotionClick,
    required this.incrementPromotionRedeemed,
    required this.storageService,
  }) : super(PromotionInitial()) {
    on<LoadPromotionsEvent>(_onLoadPromotions);
    on<FilterPromotionsByStatusEvent>(_onFilterByStatus);
    on<AddPromotionEvent>(_onAddPromotion);
    on<UpdatePromotionEvent>(_onUpdatePromotion);
    on<DeletePromotionEvent>(_onDeletePromotion);
    on<DeactivatePromotionEvent>(_onDeactivatePromotion);
    on<IncrementPromotionClickEvent>(_onIncrementClick);
    on<IncrementPromotionRedeemedEvent>(_onIncrementRedeemed);
  }

  Future<void> _onLoadPromotions(LoadPromotionsEvent event, Emitter emit) async {
    emit(PromotionLoading());
    try {
      final promotions = await getPromotions();
      emit(PromotionLoaded(
        promotions,
        filteredPromotions: promotions,
      ));
    } catch (e) {
      emit(PromotionError(e.toString()));
    }
  }

  Future<void> _onFilterByStatus(
      FilterPromotionsByStatusEvent event, Emitter emit) async {
    emit(PromotionLoading());
    try {
      // Always fetch latest promotions first
      final promotions = await getPromotions();

      final filtered = _applyStatusFilter(promotions, event.status);

      emit(PromotionLoaded(
        promotions,
        filteredPromotions: filtered,
        selectedStatus: event.status,
      ));
    } catch (e) {
      emit(PromotionError(e.toString()));
    }
  }

  Future<void> _onAddPromotion(AddPromotionEvent event, Emitter emit) async {
    try {
      String imageUrl = event.promotion.imageUrl;
      
      // Upload image if provided
      if (event.imageFile != null) {
        emit(PromotionImageUploading());
        try {
          imageUrl = await storageService.uploadPromotionImage(event.imageFile!);
        } catch (e) {
          emit(PromotionError('Failed to upload image: ${e.toString()}'));
          return;
        }
      }

      // Create promotion with uploaded image URL
      final promotion = PromotionEntity(
        id: event.promotion.id,
        title: event.promotion.title,
        description: event.promotion.description,
        type: event.promotion.type,
        status: PromotionStatus.pending, // Always start as pending for admin approval
        discountPercentage: event.promotion.discountPercentage,
        flatDiscountAmount: event.promotion.flatDiscountAmount,
        buyQuantity: event.promotion.buyQuantity,
        getQuantity: event.promotion.getQuantity,
        imageUrl: imageUrl,
        startDate: event.promotion.startDate,
        expiryDate: event.promotion.expiryDate,
        createdAt: DateTime.now(),
      );

      await addPromotion(promotion);
      add(LoadPromotionsEvent());
    } catch (e) {
      emit(PromotionError('Failed to add promotion: ${e.toString()}'));
    }
  }

  Future<void> _onUpdatePromotion(
      UpdatePromotionEvent event, Emitter emit) async {
    try {
      String imageUrl = event.promotion.imageUrl;
      
      // Upload new image if provided
      if (event.imageFile != null) {
        emit(PromotionImageUploading());
        try {
          imageUrl = await storageService.uploadPromotionImage(event.imageFile!);
        } catch (e) {
          emit(PromotionError('Failed to upload image: ${e.toString()}'));
          return;
        }
      }

      // Update promotion with new image URL
      final promotion = PromotionEntity(
        id: event.promotion.id,
        title: event.promotion.title,
        description: event.promotion.description,
        type: event.promotion.type,
        status: event.promotion.status,
        discountPercentage: event.promotion.discountPercentage,
        flatDiscountAmount: event.promotion.flatDiscountAmount,
        buyQuantity: event.promotion.buyQuantity,
        getQuantity: event.promotion.getQuantity,
        imageUrl: imageUrl,
        startDate: event.promotion.startDate,
        expiryDate: event.promotion.expiryDate,
        createdAt: event.promotion.createdAt,
        approvedAt: event.promotion.approvedAt,
        approvedBy: event.promotion.approvedBy,
      );

      await updatePromotion(promotion);
      add(LoadPromotionsEvent());
    } catch (e) {
      emit(PromotionError('Failed to update promotion: ${e.toString()}'));
    }
  }

  Future<void> _onDeletePromotion(
      DeletePromotionEvent event, Emitter emit) async {
    try {
      await deletePromotion(event.id);
      add(LoadPromotionsEvent());
    } catch (e) {
      emit(PromotionError('Failed to delete promotion.'));
    }
  }

  Future<void> _onDeactivatePromotion(
      DeactivatePromotionEvent event, Emitter emit) async {
    try {
      await deactivatePromotion(event.id);
      add(LoadPromotionsEvent());
    } catch (e) {
      emit(PromotionError('Failed to deactivate promotion.'));
    }
  }

  Future<void> _onIncrementClick(
      IncrementPromotionClickEvent event, Emitter emit) async {
    try {
      await incrementPromotionClick(event.promotionId);
      // Reload promotions to update counts
      add(LoadPromotionsEvent());
    } catch (e) {
      // Silently fail - analytics shouldn't break the app
      print('Error incrementing click count: $e');
    }
  }

  Future<void> _onIncrementRedeemed(
      IncrementPromotionRedeemedEvent event, Emitter emit) async {
    try {
      await incrementPromotionRedeemed(event.promotionId);
      // Reload promotions to update counts
      add(LoadPromotionsEvent());
    } catch (e) {
      // Silently fail - analytics shouldn't break the app
      print('Error incrementing redeemed count: $e');
    }
  }

  List<PromotionEntity> _applyStatusFilter(
    List<PromotionEntity> promotions,
    String? status,
  ) {
    if (status == null) return promotions;

    switch (status) {
      case 'active':
        return promotions.where((promotion) => promotion.isActive).toList();
      case 'expired':
        return promotions.where((promotion) => promotion.isExpired).toList();
      case 'pending':
        return promotions
            .where((promotion) => promotion.status == PromotionStatus.pending)
            .toList();
      case 'approved':
        return promotions
            .where((promotion) => promotion.status == PromotionStatus.approved)
            .toList();
      case 'rejected':
        return promotions
            .where((promotion) => promotion.status == PromotionStatus.rejected)
            .toList();
      case 'deactivated':
        return promotions
            .where(
                (promotion) => promotion.status == PromotionStatus.deactivated)
            .toList();
      default:
        return promotions;
    }
  }
}

