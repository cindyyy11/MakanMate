import 'package:equatable/equatable.dart';

class SearchHistoryEntity extends Equatable {
  final String id; 
  final String query;

  const SearchHistoryEntity({
    required this.id,
    required this.query,
  });

  @override
  List<Object?> get props => [id, query];
}
