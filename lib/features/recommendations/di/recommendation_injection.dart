import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:makan_mate/ai_engine/recommendation_engine.dart';
import 'package:makan_mate/features/recommendations/data/datasources/recommendation_local_datasource.dart';
import 'package:makan_mate/features/recommendations/data/datasources/recommendation_remote_datasource.dart';
import 'package:makan_mate/features/recommendations/data/repositories/recommendation_repository_impl.dart';
import 'package:makan_mate/features/recommendations/domain/repositories/recommendation_repository.dart';
import 'package:makan_mate/features/recommendations/domain/usecases/get_contextual_recommendations_usecase.dart';
import 'package:makan_mate/features/recommendations/domain/usecases/get_recommendations_usecase.dart';
import 'package:makan_mate/features/recommendations/domain/usecases/get_similar_items_usecase.dart';
import 'package:makan_mate/features/recommendations/domain/usecases/track_interaction_usecase.dart';
import 'package:makan_mate/features/recommendations/presentation/bloc/recommendation_bloc.dart';

/// Dependency injection for recommendation feature
/// 
/// Sets up all dependencies following clean architecture
class RecommendationInjection {
  static final GetIt _getIt = GetIt.instance;

  /// Initialize all dependencies for recommendation feature
  static Future<void> init() async {
    final logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 5,
        lineLength: 80,
        colors: true,
        printEmojis: true,
      ),
    );

    // Initialize Hive box for caching
    final recommendationBox = await Hive.openBox('recommendations');

    // Core dependencies
    if (!_getIt.isRegistered<RecommendationEngine>()) {
      _getIt.registerLazySingleton<RecommendationEngine>(
        () => RecommendationEngine(),
      );
    }

    // Data sources
    _getIt.registerLazySingleton<RecommendationRemoteDataSource>(
      () => RecommendationRemoteDataSourceImpl(
        firestore: FirebaseFirestore.instance,
        storage: FirebaseStorage.instance,
        engine: _getIt<RecommendationEngine>(),
        logger: logger,
      ),
    );

    _getIt.registerLazySingleton<RecommendationLocalDataSource>(
      () => RecommendationLocalDataSourceImpl(
        recommendationBox: recommendationBox,
        logger: logger,
      ),
    );

    // Repository
    _getIt.registerLazySingleton<RecommendationRepository>(
      () => RecommendationRepositoryImpl(
        remoteDataSource: _getIt<RecommendationRemoteDataSource>(),
        localDataSource: _getIt<RecommendationLocalDataSource>(),
        logger: logger,
      ),
    );

    // Use cases
    _getIt.registerLazySingleton(
      () => GetRecommendationsUseCase(_getIt<RecommendationRepository>()),
    );

    _getIt.registerLazySingleton(
      () => GetContextualRecommendationsUseCase(
        _getIt<RecommendationRepository>(),
      ),
    );

    _getIt.registerLazySingleton(
      () => GetSimilarItemsUseCase(_getIt<RecommendationRepository>()),
    );

    _getIt.registerLazySingleton(
      () => TrackInteractionUseCase(_getIt<RecommendationRepository>()),
    );

    // BLoC
    _getIt.registerFactory(
      () => RecommendationBloc(
        getRecommendations: _getIt<GetRecommendationsUseCase>(),
        getContextualRecommendations:
            _getIt<GetContextualRecommendationsUseCase>(),
        getSimilarItems: _getIt<GetSimilarItemsUseCase>(),
        trackInteraction: _getIt<TrackInteractionUseCase>(),
        logger: logger,
      ),
    );
  }

  /// Get a registered dependency
  static T get<T extends Object>() {
    return _getIt<T>();
  }

  /// Check if a type is registered
  static bool isRegistered<T extends Object>() {
    return _getIt.isRegistered<T>();
  }

  /// Reset all dependencies (useful for testing)
  static Future<void> reset() async {
    await _getIt.reset();
  }
}

