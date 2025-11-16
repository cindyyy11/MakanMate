import 'package:equatable/equatable.dart';
import 'package:makan_mate/features/search/domain/entities/search_history_entity.dart';
import 'package:makan_mate/features/search/domain/entities/search_result_food_entity.dart';
import 'package:makan_mate/features/search/domain/entities/search_result_restaurant_entity.dart';

class SearchState extends Equatable {
  final bool isLoading;
  final String? currentQuery;
  final List<SearchResultRestaurantEntity> restaurants;
  final List<SearchResultFoodEntity> foods;
  final List<SearchHistoryEntity> history;
  final String? errorMessage;

  const SearchState({
    this.isLoading = false,
    this.currentQuery,
    this.restaurants = const [],
    this.foods = const [],
    this.history = const [],
    this.errorMessage,
  });

  SearchState copyWith({
    bool? isLoading,
    String? currentQuery,
    List<SearchResultRestaurantEntity>? restaurants,
    List<SearchResultFoodEntity>? foods,
    List<SearchHistoryEntity>? history,
    String? errorMessage,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      currentQuery: currentQuery ?? this.currentQuery,
      restaurants: restaurants ?? this.restaurants,
      foods: foods ?? this.foods,
      history: history ?? this.history,
      errorMessage: errorMessage,
    );
  }

  factory SearchState.initial() => const SearchState();

  @override
  List<Object?> get props =>
      [isLoading, currentQuery, restaurants, foods, history, errorMessage];
}
