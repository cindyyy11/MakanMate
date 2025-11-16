import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/features/search/domain/entities/search_history_entity.dart';

class SearchHistoryModel {
  final String id;
  final String query;

  SearchHistoryModel({
    required this.id,
    required this.query,
  });

  factory SearchHistoryModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SearchHistoryModel(
      id: doc.id,
      query: data['query'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'query': query,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  SearchHistoryEntity toEntity() {
    return SearchHistoryEntity(id: id, query: query);
  }
}
