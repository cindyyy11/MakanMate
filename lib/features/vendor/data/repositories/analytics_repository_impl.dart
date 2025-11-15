import '../../domain/entities/analytics_entity.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_datasource.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ReviewAnalyticsEntity> getWeeklyReviewData(String vendorId) async {
    try {
      final model = await remoteDataSource.getWeeklyReviewData(vendorId);
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to get weekly review data: $e');
    }
  }

  @override
  Future<ReviewAnalyticsEntity> getMonthlyReviewData(String vendorId) async {
    try {
      final model = await remoteDataSource.getMonthlyReviewData(vendorId);
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to get monthly review data: $e');
    }
  }

  @override
  Future<FavouriteStatsEntity> getFavouriteData(String vendorId) async {
    try {
      final model = await remoteDataSource.getFavouriteData(vendorId);
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to get favourite data: $e');
    }
  }

  @override
  Future<PromotionAnalyticsEntity> getPromotionAnalytics(String vendorId) async {
    try {
      final model = await remoteDataSource.getPromotionAnalytics(vendorId);
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to get promotion analytics: $e');
    }
  }
}

