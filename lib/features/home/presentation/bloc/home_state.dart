import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<RestaurantEntity> categories;
  final List<RestaurantEntity> recommendations;

  HomeLoaded({required this.categories, required this.recommendations});
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
