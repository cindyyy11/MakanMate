import 'package:bloc/bloc.dart';
import 'package:makan_mate/features/home/domain/usecases/get_restaurants_usecase.dart';
import 'package:makan_mate/features/home/presentation/bloc/home_event.dart';
import 'package:makan_mate/features/home/presentation/bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetRestaurantsUseCase getRestaurants;
  
  HomeBloc({required this.getRestaurants}) : super(HomeInitial()) {
    on<LoadRestaurants>(_onLoadRestaurants);
    on<RefreshRestaurants>(_onRefreshRestaurants);
  }
  
  Future<void> _onLoadRestaurants(
    LoadRestaurants event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    
    final result = await getRestaurants(
      limit: event.limit ?? 20,
      cuisineType: event.cuisineType,
      isHalal: event.isHalal,
    );
    
    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (restaurants) => emit(HomeLoaded(restaurants)),
    );
  }
  
  Future<void> _onRefreshRestaurants(
    RefreshRestaurants event,
    Emitter<HomeState> emit,
  ) async {
    // Keep current state while refreshing
    final currentState = state;
    
    final result = await getRestaurants(limit: 20);
    
    result.fold(
      (failure) {
        // If refresh fails, keep current state and show error
        if (currentState is HomeLoaded) {
          // Could emit a snackbar event here
        } else {
          emit(HomeError(failure.message));
        }
      },
      (restaurants) => emit(HomeLoaded(restaurants)),
    );
  }
}