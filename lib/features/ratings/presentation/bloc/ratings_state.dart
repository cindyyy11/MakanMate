abstract class RatingsState {}

class RatingsInitial extends RatingsState {}

class RatingsLoading extends RatingsState {}

class RatingsSuccess extends RatingsState {}

class RatingsFailure extends RatingsState {
  final String message;
  RatingsFailure(this.message);
}
