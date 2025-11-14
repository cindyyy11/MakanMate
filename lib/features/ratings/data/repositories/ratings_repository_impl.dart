import '../../domain/entities/rating_entity.dart';
import '../../domain/repositories/ratings_repository.dart';
import '../datasources/ratings_remote_datasource.dart';
import '../models/rating_model.dart';

class RatingsRepositoryImpl implements RatingsRepository {
  final RatingsRemoteDatasource remoteDatasource;

  RatingsRepositoryImpl(this.remoteDatasource);

  @override
  Future<void> submitRating(RatingEntity rating) {
    final model = RatingModel(
      userId: rating.userId,
      vendorId: rating.vendorId,
      rating: rating.rating,
      comment: rating.comment,
      createdAt: rating.createdAt,
    );

    return remoteDatasource.submitRating(model);
  }
}
