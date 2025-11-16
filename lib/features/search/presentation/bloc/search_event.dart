import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchStarted extends SearchEvent {}

class SearchQuerySubmitted extends SearchEvent {
  final String query;

  const SearchQuerySubmitted(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchSuggestionTapped extends SearchEvent {
  final String query;

  const SearchSuggestionTapped(this.query);

  @override
  List<Object?> get props => [query];
}
