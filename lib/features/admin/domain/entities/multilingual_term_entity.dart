import 'package:equatable/equatable.dart';

/// Multilingual term bank for dish names and translations
class MultilingualTerm extends Equatable {
  final String id;
  final String termKey; // e.g., "nasi_lemak"
  final Map<String, Translation> translations; // EN, BM, ZH, TA
  final String category; // dish, cuisine, dietary_tag, etc.
  final bool isPublished;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final String? createdBy;

  const MultilingualTerm({
    required this.id,
    required this.termKey,
    required this.translations,
    required this.category,
    this.isPublished = false,
    required this.createdAt,
    this.publishedAt,
    this.createdBy,
  });

  @override
  List<Object?> get props => [
        id,
        termKey,
        translations,
        category,
        isPublished,
        createdAt,
        publishedAt,
        createdBy,
      ];
}

class Translation extends Equatable {
  final String languageCode; // EN, BM, ZH, TA
  final String text;
  final String? transliteration;
  final bool isVerified;

  const Translation({
    required this.languageCode,
    required this.text,
    this.transliteration,
    this.isVerified = false,
  });

  @override
  List<Object?> get props => [
        languageCode,
        text,
        transliteration,
        isVerified,
      ];
}


