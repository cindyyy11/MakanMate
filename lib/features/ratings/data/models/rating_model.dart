import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/rating_entity.dart';

class RatingModel extends RatingEntity {
  RatingModel({
    required super.userId,
    required super.vendorId,
    required super.rating,
    required super.comment,
    required super.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'vendorId': vendorId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }

  factory RatingModel.fromMap(Map<String, dynamic> map) {
    return RatingModel(
      userId: map['userId'],
      vendorId: map['vendorId'],
      rating: map['rating'],
      comment: map['comment'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
