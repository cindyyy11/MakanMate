import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating_model.dart';

abstract class RatingsRemoteDatasource {
  Future<void> submitRating(RatingModel rating);
}

class RatingsRemoteDatasourceImpl implements RatingsRemoteDatasource {
  final FirebaseFirestore firestore;

  RatingsRemoteDatasourceImpl(this.firestore);

  @override
  Future<void> submitRating(RatingModel rating) async {
    await firestore.collection('ratings').add(rating.toMap());
  }
}
