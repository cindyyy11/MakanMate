import 'package:equatable/equatable.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<RestaurantEntity> categories;
  final List<RestaurantEntity> recommendations;
  final List<RestaurantEntity> restaurants;

  /// True when recommendations are based on dietary preferences.
  final bool isPersonalized;

  const HomeLoaded({
    required this.categories,
    required this.recommendations,
    required this.restaurants,
    this.isPersonalized = false,
  });

  @override
  List<Object?> get props =>
      [categories, recommendations, restaurants, isPersonalized];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
