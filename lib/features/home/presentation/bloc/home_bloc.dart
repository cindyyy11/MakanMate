import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_recommendations_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetRecommendationsUseCase getRecommendationsUseCase;

  HomeBloc({
    required this.getCategoriesUseCase,
    required this.getRecommendationsUseCase,
  }) : super(HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(
      LoadHomeDataEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final categories = await getCategoriesUseCase();
      final recommendations = await getRecommendationsUseCase();

      emit(HomeLoaded(
        categories: categories,
        recommendations: recommendations,
      ));
    } catch (e) {
      emit(HomeError('Failed to load home data: $e'));
    }
  }
}
