import 'package:equatable/equatable.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  
  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<RestaurantEntity> restaurants;
  
  const HomeLoaded(this.restaurants);
  
  @override
  List<Object> get props => [restaurants];
}

class HomeError extends HomeState {
  final String message;
  
  const HomeError(this.message);
  
  @override
  List<Object> get props => [message];
}