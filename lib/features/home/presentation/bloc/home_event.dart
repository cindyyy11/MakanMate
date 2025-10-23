import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadRestaurants extends HomeEvent {
  final int? limit;
  final String? cuisineType;
  final bool? isHalal;
  
  const LoadRestaurants({
    this.limit,
    this.cuisineType,
    this.isHalal,
  });
  
  @override
  List<Object?> get props => [limit, cuisineType, isHalal];
}

class RefreshRestaurants extends HomeEvent {}