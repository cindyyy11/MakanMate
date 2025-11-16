import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_user_analytics_event.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_user_analytics_state.dart';
import 'package:makan_mate/features/analytics/domain/usecases/get_user_analytics_usecase.dart';

class AdminUserAnalyticsBloc extends Bloc<AdminUserAnalyticsEvent, AdminUserAnalyticsState> {
  final GetUserAnalyticsUseCase getUserAnalytics;
  AdminUserAnalyticsBloc({required this.getUserAnalytics}) : super(AdminUserAnalyticsInitial()) {
    on<LoadUserAnalytics>(_onLoad);
  }

  Future<void> _onLoad(
    LoadUserAnalytics event,
    Emitter<AdminUserAnalyticsState> emit,
  ) async {
    emit(AdminUserAnalyticsLoading());
    final result = await getUserAnalytics();
    result.fold(
      (failure) => emit(AdminUserAnalyticsError(failure.message)),
      (analytics) => emit(AdminUserAnalyticsLoaded(analytics)),
    );
  }
}


