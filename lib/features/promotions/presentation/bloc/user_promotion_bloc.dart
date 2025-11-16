import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../vendor/domain/entities/promotion_entity.dart';
import '../../domain/usecases/watch_user_promotions_usecase.dart';
import '../../../vendor/domain/usecases/increment_promotion_click_for_user_usecase.dart';
import '../../../vendor/domain/usecases/increment_promotion_redeemed_for_user_usecase.dart';
import 'user_promotion_event.dart';
import 'user_promotion_state.dart';

class UserPromotionBloc extends Bloc<UserPromotionEvent, UserPromotionState> {
  final WatchUserPromotionsUseCase watchUserPromotions;
  final IncrementPromotionClickForUserUseCase incrementClick;
  final IncrementPromotionRedeemedForUserUseCase incrementRedeemed;

  UserPromotionBloc({
    required this.watchUserPromotions,
    required this.incrementClick,
    required this.incrementRedeemed,
  }) : super(UserPromotionInitial()) {
    on<LoadUserPromotionsEvent>(_onLoadPromotions);
    on<UserPromotionClickEvent>(_onClick);
    on<UserPromotionRedeemedEvent>(_onRedeemed);
  }

  Future<void> _onLoadPromotions(
    LoadUserPromotionsEvent event,
    Emitter<UserPromotionState> emit,
  ) async {
    print('🔄 _onLoadPromotions called');
    
    try {
      await emit.forEach<List<PromotionEntity>>(
        watchUserPromotions(),
        onData: (promotions) {
          return UserPromotionLoaded(promotions);
        },
        onError: (error, stackTrace) {
          return UserPromotionError(error.toString());
        },
      );
    } catch (e, stackTrace) {
      emit(UserPromotionError('Failed to load promotions: $e'));
    }
  }

  Future<void> _onClick(
    UserPromotionClickEvent event,
    Emitter<UserPromotionState> emit,
  ) async {
    try {
      await incrementClick(event.vendorId, event.promotionId);
    } catch (e) {
    }
  }

  Future<void> _onRedeemed(
    UserPromotionRedeemedEvent event,
    Emitter<UserPromotionState> emit,
  ) async {
    try {
      await incrementRedeemed(event.vendorId, event.promotionId);
    } catch (e) {
    }
  }
}