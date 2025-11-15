import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/features/reviews/data/models/review_model.dart';

abstract class UserReviewRemoteDataSource {
  Future<ReviewModel> submitReview(ReviewModel model);
  Future<List<ReviewModel>> getUserReviews(String userId);
}

class UserReviewRemoteDataSourceImpl implements UserReviewRemoteDataSource {
  final FirebaseFirestore firestore;

  UserReviewRemoteDataSourceImpl(this.firestore);

  @override
  Future<ReviewModel> submitReview(ReviewModel model) async {
    final docRef = await firestore.collection('reviews').add(model.toFirestore());
    final doc = await docRef.get();
    return ReviewModel.fromFirestore(doc);
  }

  @override
  Future<List<ReviewModel>> getUserReviews(String userId) async {
    final query = await firestore
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList();
  }
}
