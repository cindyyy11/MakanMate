import 'package:equatable/equatable.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewSuccess extends ReviewState {}

class ReviewFailure extends ReviewState {
  final String message;

  const ReviewFailure(this.message);

  @override
  List<Object?> get props => [message];
}
