import 'dart:math';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:makan_mate/ai_engine/ai_engine_base.dart';
import 'package:makan_mate/features/food/data/models/food_models.dart';
import 'package:makan_mate/features/recommendations/data/models/recommendation_models.dart';
import 'package:makan_mate/features/auth/data/models/user_models.dart'
    as auth_models;
import 'package:makan_mate/core/di/injection_container.dart' as di;
import 'package:makan_mate/features/food/domain/repositories/food_repository.dart';
import 'package:makan_mate/features/user/domain/repositories/user_repository.dart';
import 'package:makan_mate/features/recommendations/domain/repositories/recommendation_repository.dart';
import 'package:makan_mate/features/auth/data/models/user_models.dart'
    as user_model;
import 'package:path_provider/path_provider.dart';

/// Advanced AI-powered recommendation engine for MakanMate
///
/// Implements a hybrid approach combining:
/// 1. Collaborative Filtering - learns from similar users
/// 2. Content-Based Filtering - matches user preferences with food attributes
/// 3. Contextual Filtering - considers time, weather, location
///
/// The engine uses TensorFlow Lite for on-device inference,
/// ensuring privacy and fast recommendations
class RecommendationEngine extends AIEngineBase {
  static final RecommendationEngine _instance =
      RecommendationEngine._internal();
  factory RecommendationEngine() => _instance;
  RecommendationEngine._internal();

  @override
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );

  bool _isInitialized = false;

  // Feature dimensions (must match training script)
  static const int USER_FEATURE_DIM = 15;
  static const int ITEM_FEATURE_DIM = 20;

  // Algorithm weights for hybrid approach
  static const double COLLABORATIVE_WEIGHT = 0.40;
  static const double CONTENT_BASED_WEIGHT = 0.35;
  static const double CONTEXTUAL_WEIGHT = 0.25;

  /// Initialize the recommendation engine
  /// Downloads latest model from Firebase and loads it
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      logger.i('Initializing AI Recommendation Engine...');

      // Try to download latest model from Firebase first
      String? downloadedModelPath;
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final modelPath = '${appDir.path}/recommendation_model.tflite';
        final modelFile = File(modelPath);
        final ref = FirebaseStorage.instance.ref(
          'ml_models/recommendation_model.tflite',
        );

        logger.i('Downloading latest recommendation model...');
        await ref.writeToFile(modelFile);
        downloadedModelPath = modelPath;
        logger.i('Model downloaded successfully');
      } on FirebaseException catch (e) {
        logger.w('Firebase error downloading model: ${e.code} - ${e.message}');
        logger.i('Will try to use bundled model from assets');
      } catch (e) {
        logger.w('Could not download model: $e');
        logger.i('Will try to use bundled model from assets');
      }

      // Try to load model from downloaded path or assets
      try {
        if (downloadedModelPath != null &&
            File(downloadedModelPath).existsSync()) {
          // Load from downloaded file
          final options = InterpreterOptions()
            ..threads = 4
            ..useNnApiForAndroid = true;
          final loadedInterpreter = Interpreter.fromFile(
            File(downloadedModelPath),
            options: options,
          );
          setInterpreter(loadedInterpreter);
          logger.i('Model loaded from downloaded file');
        } else {
          // Try to load from assets
          await loadModel('assets/ml_models/recommendation_model.tflite');
          logger.i('Model loaded from assets');
        }
      } catch (e) {
        logger.w('Could not load model from assets or downloaded file: $e');
        logger.i('Continuing without ML model - will use fallback algorithms');
        // Don't throw - continue without model
      }

      _isInitialized = true;
      logger.i('AI Recommendation Engine initialized successfully');
    } catch (e, stackTrace) {
      logger.e('Failed to initialize recommendation engine: $e\n$stackTrace');
      // Continue without ML model - use fallback algorithms
      _isInitialized = true;
    }
  }

  /// Generate personalized recommendations for a user
  ///
  /// Uses hybrid approach combining multiple algorithms
  /// Returns sorted list by relevance score
  Future<List<RecommendationItem>> getRecommendations({
    required String userId,
    int limit = 10,
    RecommendationContext? context,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      logger.i('Generating recommendations for user: $userId');

      // Get hybrid recommendations
      List<RecommendationItem> recommendations =
          await _generateHybridRecommendations(
            userId: userId,
            limit: limit * 2, // Get more to ensure diversity
            context: context,
          );

      // Apply business rules and diversity
      recommendations = await _applyBusinessRules(recommendations, userId);

      // Sort and limit
      recommendations.sort((a, b) => b.score.compareTo(a.score));

      logger.i('Generated ${recommendations.length} recommendations');
      return recommendations.take(limit).toList();
    } on FirebaseException catch (e) {
      logger.e(
        'Firebase error generating recommendations: ${e.code} - ${e.message}',
      );
      return await _getFallbackRecommendations(userId, limit);
    } catch (e, stackTrace) {
      logger.e('Error generating recommendations: $e\n$stackTrace');
      return await _getFallbackRecommendations(userId, limit);
    }
  }

  /// Generate hybrid recommendations combining all algorithms
  Future<List<RecommendationItem>> _generateHybridRecommendations({
    required String userId,
    required int limit,
    RecommendationContext? context,
  }) async {
    // Get candidate items (filter based on user preferences)
    List<FoodItem> candidateItems = await _getCandidateItems(userId);

    if (candidateItems.isEmpty) {
      logger.w('No candidate items found for user: $userId');
      return await _getFallbackRecommendations(userId, limit);
    }

    try {
      // Run different recommendation algorithms in parallel
      final results = await Future.wait([
        _generateCollaborativeRecommendations(
          userId: userId,
          candidateItems: candidateItems,
          limit: limit,
        ),
        _generateContentBasedRecommendations(
          userId: userId,
          candidateItems: candidateItems,
          limit: limit,
        ),
        _generateContextualRecommendations(
          userId: userId,
          candidateItems: candidateItems.take(50).toList(),
          limit: limit ~/ 2,
          context: context,
        ),
      ]);

      final collaborativeRecs = results[0];
      final contentBasedRecs = results[1];
      final contextualRecs = results[2];

      // Combine with weights
      return _combineRecommendations(
        collaborative: collaborativeRecs,
        contentBased: contentBasedRecs,
        contextual: contextualRecs,
      );
    } catch (e, stackTrace) {
      logger.e('Error in hybrid recommendations: $e\n$stackTrace');
      return await _getFallbackRecommendations(userId, limit);
    }
  }

  /// Combine recommendations from different algorithms
  List<RecommendationItem> _combineRecommendations({
    required List<RecommendationItem> collaborative,
    required List<RecommendationItem> contentBased,
    required List<RecommendationItem> contextual,
  }) {
    Map<String, RecommendationItem> combinedRecs = {};

    // Collaborative filtering: 40% weight
    for (var rec in collaborative) {
      combinedRecs[rec.itemId] = rec.copyWith(
        score: rec.score * COLLABORATIVE_WEIGHT,
        algorithmType: 'hybrid',
      );
    }

    // Content-based: 35% weight
    for (var rec in contentBased) {
      if (combinedRecs.containsKey(rec.itemId)) {
        var existing = combinedRecs[rec.itemId]!;
        combinedRecs[rec.itemId] = existing.copyWith(
          score: existing.score + (rec.score * CONTENT_BASED_WEIGHT),
        );
      } else {
        combinedRecs[rec.itemId] = rec.copyWith(
          score: rec.score * CONTENT_BASED_WEIGHT,
          algorithmType: 'hybrid',
        );
      }
    }

    // Contextual: 25% weight
    for (var rec in contextual) {
      if (combinedRecs.containsKey(rec.itemId)) {
        var existing = combinedRecs[rec.itemId]!;
        combinedRecs[rec.itemId] = existing.copyWith(
          score: existing.score + (rec.score * CONTEXTUAL_WEIGHT),
        );
      } else {
        combinedRecs[rec.itemId] = rec.copyWith(
          score: rec.score * CONTEXTUAL_WEIGHT,
          algorithmType: 'hybrid',
        );
      }
    }

    return combinedRecs.values.toList();
  }

  /// Get candidate food items based on user's dietary restrictions
  Future<List<FoodItem>> _getCandidateItems(String userId) async {
    try {
      final userRepository = di.sl<UserRepository>();
      final foodRepository = di.sl<FoodRepository>();

      // Get user
      final userResult = await userRepository.getUser(userId);
      final userEntity = userResult.fold((failure) {
        logger.w('User not found: $userId, using popular items');
        return null;
      }, (entity) => entity);

      // Convert to UserModel for compatibility
      if (userEntity == null) {
        // Get popular items as fallback
        final popularResult = await foodRepository.getPopularItems(limit: 100);
        return popularResult.fold(
          (failure) => <FoodItem>[],
          (entities) => entities.map((e) => e.toFoodItem()).toList(),
        );
      }

      final user = userEntity.toModel();

      // Get items that match user's dietary restrictions
      List<FoodItem> candidates = [];

      // Get from multiple sources
      final popularResult = await foodRepository.getPopularItems(limit: 50);
      final popular = popularResult.fold(
        (failure) => <FoodItem>[],
        (entities) => entities.map((e) => e.toFoodItem()).toList(),
      );

      final nearbyResult = await foodRepository.getNearbyFoodItems(
        user.currentLocation,
        limit: 50,
      );
      final nearby = nearbyResult.fold(
        (failure) => <FoodItem>[],
        (entities) => entities.map((e) => e.toFoodItem()).toList(),
      );

      final highlyRatedResult = await foodRepository.getHighlyRatedItems(
        limit: 30,
      );
      final trending = highlyRatedResult.fold(
        (failure) => <FoodItem>[],
        (entities) => entities.map((e) => e.toFoodItem()).toList(),
      );

      candidates.addAll(popular);
      candidates.addAll(nearby);
      candidates.addAll(trending);

      // Filter based on dietary restrictions
      final userDietaryRestrictions = user.dietaryRestrictions;
      candidates = candidates.where((item) {
        // Check Halal requirement
        if (userDietaryRestrictions.contains('halal') && !item.isHalal) {
          return false;
        }

        // Check Vegetarian requirement
        if (userDietaryRestrictions.contains('vegetarian') &&
            !item.isVegetarian) {
          return false;
        }

        // Check Vegan requirement
        if (userDietaryRestrictions.contains('vegan') && !item.isVegan) {
          return false;
        }

        return true;
      }).toList();

      // Remove duplicates
      final seen = <String>{};
      candidates = candidates.where((item) => seen.add(item.id)).toList();

      logger.i('Found ${candidates.length} candidate items for user: $userId');
      return candidates;
    } catch (e, stackTrace) {
      logger.e('Error getting candidate items: $e\n$stackTrace');
      return [];
    }
  }

  @override
  List<Object> runInference(List<Object> inputs) {
    if (!isModelLoaded || interpreter == null) {
      throw Exception('Model not loaded');
    }
    // This is called by the specific recommendation methods
    return [];
  }

  // ✅ FIXED: All methods are now INSIDE the class

  /// Collaborative Filtering - Learn from similar users
  /// Uses matrix factorization if model is loaded, otherwise uses similarity-based approach
  Future<List<RecommendationItem>> _generateCollaborativeRecommendations({
    required String userId,
    required List<FoodItem> candidateItems,
    required int limit,
  }) async {
    if (!isModelLoaded) {
      logger.i(
        'Model not loaded, using similarity-based collaborative filtering',
      );
      return await _generateSimilarityBasedRecommendations(
        userId,
        candidateItems,
        limit,
      );
    }

    try {
      final userRepository = di.sl<UserRepository>();
      final userResult = await userRepository.getUser(userId);

      final userEntity = userResult.fold((failure) {
        logger.w('User not found for collaborative filtering: $userId');
        return null;
      }, (entity) => entity);

      if (userEntity == null) {
        return [];
      }

      // Convert to UserModel for compatibility
      final user = userEntity.toModel();

      List<RecommendationItem> recommendations = [];

      // Convert user and items to feature vectors
      final userFeatures = extractUserFeatures(user);

      for (FoodItem item in candidateItems) {
        final itemFeatures = extractItemFeatures(item);

        // Prepare input for TensorFlow Lite model
        // Input shape: [1, USER_FEATURE_DIM + ITEM_FEATURE_DIM]
        var input = List<double>.from(userFeatures)..addAll(itemFeatures);
        var inputTensor = [input];

        // Output shape: [1, 1]
        var output = List.filled(1, List.filled(1, 0.0));

        // Run inference
        interpreter!.run(inputTensor, output);

        double score = output[0][0].clamp(0.0, 1.0);

        if (score > 0.5) {
          recommendations.add(
            RecommendationItem(
              itemId: item.id,
              score: score,
              reason: _generateCollaborativeReason(score, item),
              algorithmType: 'collaborative_filtering',
              confidence: _calculateConfidence(score),
              generatedAt: DateTime.now(),
            ),
          );
        }
      }

      recommendations.sort((a, b) => b.score.compareTo(a.score));
      logger.i(
        'Generated ${recommendations.length} collaborative recommendations',
      );
      return recommendations.take(limit).toList();
    } catch (e, stackTrace) {
      logger.e('Error in collaborative filtering: $e\n$stackTrace');
      return await _generateSimilarityBasedRecommendations(
        userId,
        candidateItems,
        limit,
      );
    }
  }

  /// Content-Based Filtering - Match user preferences with food attributes
  Future<List<RecommendationItem>> _generateContentBasedRecommendations({
    required String userId,
    required List<FoodItem> candidateItems,
    required int limit,
  }) async {
    try {
      final userRepository = di.sl<UserRepository>();
      final recommendationRepository = di.sl<RecommendationRepository>();

      final userResult = await userRepository.getUser(userId);
      final userEntity = userResult.fold((failure) {
        logger.w('User not found for content-based filtering: $userId');
        return null;
      }, (entity) => entity);

      if (userEntity == null) {
        return [];
      }

      // Convert to UserModel for compatibility
      final user = userEntity.toModel();

      // Build user profile from past interactions
      final interactionsResult = await recommendationRepository
          .getUserInteractions(userId: userId, limit: 100);

      final userInteractions = interactionsResult.fold(
        (failure) => <UserInteraction>[],
        (entities) => entities.map((e) => e.toModel()).toList(),
      );

      final userProfile = await _buildUserProfile(user, userInteractions);

      List<RecommendationItem> recommendations = [];

      for (FoodItem item in candidateItems) {
        double contentScore = _calculateContentScore(userProfile, item);

        if (contentScore > 0.3) {
          recommendations.add(
            RecommendationItem(
              itemId: item.id,
              score: contentScore,
              reason: _generateContentBasedReason(userProfile, item),
              algorithmType: 'content_based',
              confidence: _calculateConfidence(contentScore),
              generatedAt: DateTime.now(),
            ),
          );
        }
      }

      recommendations.sort((a, b) => b.score.compareTo(a.score));
      logger.i(
        'Generated ${recommendations.length} content-based recommendations',
      );
      return recommendations.take(limit).toList();
    } on FirebaseException catch (e) {
      logger.e(
        'Firebase error in content-based filtering: ${e.code} - ${e.message}',
      );
      return [];
    } catch (e, stackTrace) {
      logger.e('Error in content-based filtering: $e\n$stackTrace');
      return [];
    }
  }

  /// Contextual Filtering - Consider time, weather, location
  Future<List<RecommendationItem>> _generateContextualRecommendations({
    required String userId,
    required List<FoodItem> candidateItems,
    required int limit,
    RecommendationContext? context,
  }) async {
    try {
      final currentContext = context ?? await _getCurrentContext(userId);
      final userRepository = di.sl<UserRepository>();

      final userResult = await userRepository.getUser(userId);
      final userEntity = userResult.fold((failure) {
        logger.w('User not found for contextual recommendations: $userId');
        return null;
      }, (entity) => entity);

      if (userEntity == null) {
        return [];
      }

      // Convert to UserModel for compatibility
      final user = userEntity.toModel();

      List<RecommendationItem> recommendations = [];

      for (FoodItem item in candidateItems) {
        double contextScore = _calculateContextualScore(
          item,
          currentContext,
          user,
        );

        if (contextScore > 0.4) {
          recommendations.add(
            RecommendationItem(
              itemId: item.id,
              score: contextScore,
              reason: _generateContextualReason(currentContext, item),
              algorithmType: 'contextual',
              confidence: _calculateConfidence(contextScore),
              generatedAt: DateTime.now(),
            ),
          );
        }
      }

      logger.i(
        'Generated ${recommendations.length} contextual recommendations',
      );
      return recommendations.take(limit).toList();
    } catch (e, stackTrace) {
      logger.e('Error in contextual recommendations: $e\n$stackTrace');
      return [];
    }
  }

  /// Similarity-based collaborative filtering (fallback)
  Future<List<RecommendationItem>> _generateSimilarityBasedRecommendations(
    String userId,
    List<FoodItem> candidateItems,
    int limit,
  ) async {
    try {
      final recommendationRepository = di.sl<RecommendationRepository>();

      final interactionsResult = await recommendationRepository
          .getUserInteractions(userId: userId, limit: 100);

      final userInteractions = interactionsResult.fold(
        (failure) => <UserInteraction>[],
        (entities) => entities.map((e) => e.toModel()).toList(),
      );

      if (userInteractions.isEmpty) {
        logger.i(
          'No user interactions, using popularity-based recommendations',
        );
        return await _generatePopularityBasedRecommendations(
          candidateItems,
          limit,
        );
      }

      // Get items user has liked
      Set<String> likedItems = userInteractions
          .where(
            (i) =>
                (i.rating ?? 0.0) >= 4.0 ||
                i.interactionType == 'like' ||
                i.interactionType == 'order',
          )
          .map((i) => i.itemId)
          .toSet();

      if (likedItems.isEmpty) {
        logger.i('No liked items, using popularity-based recommendations');
        return await _generatePopularityBasedRecommendations(
          candidateItems,
          limit,
        );
      }

      // Find similar users (users who liked similar items)
      Map<String, double> similarUsers = {};
      for (String itemId in likedItems) {
        final itemInteractionsResult = await recommendationRepository
            .getItemInteractions(itemId: itemId, limit: 100);

        final otherInteractions = itemInteractionsResult.fold(
          (failure) => <UserInteraction>[],
          (entities) => entities.map((e) => e.toModel()).toList(),
        );

        for (UserInteraction interaction in otherInteractions) {
          if (interaction.userId != userId &&
              (interaction.rating ?? 0.0) >= 4.0) {
            similarUsers[interaction.userId] =
                (similarUsers[interaction.userId] ?? 0.0) + 1.0;
          }
        }
      }

      // Get items liked by similar users
      Map<String, double> itemScores = {};
      for (String simUserId in similarUsers.keys) {
        double userSimilarity = similarUsers[simUserId]! / likedItems.length;

        final simUserInteractionsResult = await recommendationRepository
            .getUserInteractions(userId: simUserId, limit: 100);

        final simUserInteractions = simUserInteractionsResult.fold(
          (failure) => <UserInteraction>[],
          (entities) => entities.map((e) => e.toModel()).toList(),
        );

        for (UserInteraction interaction in simUserInteractions) {
          if (!likedItems.contains(interaction.itemId)) {
            itemScores[interaction.itemId] =
                (itemScores[interaction.itemId] ?? 0.0) +
                (interaction.rating ?? 0.0) * userSimilarity;
          }
        }
      }

      // Convert to recommendations
      List<RecommendationItem> recommendations = [];
      for (String itemId in itemScores.keys) {
        recommendations.add(
          RecommendationItem(
            itemId: itemId,
            score: (itemScores[itemId]! / 5.0).clamp(0.0, 1.0),
            reason: "Recommended by users with similar taste",
            algorithmType: 'collaborative_similarity',
            confidence: _calculateConfidence(itemScores[itemId]! / 5.0),
            generatedAt: DateTime.now(),
          ),
        );
      }

      recommendations.sort((a, b) => b.score.compareTo(a.score));
      logger.i(
        'Generated ${recommendations.length} similarity-based recommendations',
      );
      return recommendations.take(limit).toList();
    } on FirebaseException catch (e) {
      logger.e(
        'Firebase error in similarity-based recommendations: ${e.code} - ${e.message}',
      );
      return [];
    } catch (e, stackTrace) {
      logger.e('Error in similarity-based recommendations: $e\n$stackTrace');
      return [];
    }
  }

  /// Popularity-based recommendations (final fallback)
  Future<List<RecommendationItem>> _generatePopularityBasedRecommendations(
    List<FoodItem> candidateItems,
    int limit,
  ) async {
    List<FoodItem> popularItems = candidateItems
        .where((item) => item.totalOrders > 0)
        .toList();
    popularItems.sort((a, b) => b.totalOrders.compareTo(a.totalOrders));

    logger.i(
      'Generated ${popularItems.length} popularity-based recommendations',
    );
    return popularItems
        .take(limit)
        .map(
          (item) => RecommendationItem(
            itemId: item.id,
            score: min(item.totalOrders / 100.0, 1.0),
            reason: "Popular choice among users",
            algorithmType: 'popularity',
            confidence: 0.7,
            generatedAt: DateTime.now(),
          ),
        )
        .toList();
  }

  /// Extract numerical features from user for ML model
  List<double> extractUserFeatures(auth_models.UserModel user) {
    List<double> features = [];

    // Cuisine preferences (5 features)
    List<String> cuisines = ['Malay', 'Chinese', 'Indian', 'Western', 'Thai'];
    for (String cuisine in cuisines) {
      features.add(user.cuisinePreferences[cuisine] ?? 0.0);
    }

    // Dietary restrictions (3 features)
    features.add(user.dietaryRestrictions.contains('halal') ? 1.0 : 0.0);
    features.add(user.dietaryRestrictions.contains('vegetarian') ? 1.0 : 0.0);
    features.add(user.dietaryRestrictions.contains('vegan') ? 1.0 : 0.0);

    // Spice tolerance (1 feature)
    features.add(user.spiceTolerance);

    // Price preference (1 feature) - use average price from behavior patterns
    features.add((user.behaviorPatterns['avg_price'] ?? 50.0) / 100.0);

    // Cultural background (4 features - one-hot encoded)
    List<String> cultures = ['Malay', 'Chinese', 'Indian', 'Mixed'];
    String userCulture = user.culturalBackground;
    for (String culture in cultures) {
      features.add(
        culture.toLowerCase() == userCulture.toLowerCase() ? 1.0 : 0.0,
      );
    }

    // Location activity (1 feature) - use behavior patterns activity level
    features.add(min((user.behaviorPatterns['activity_level'] ?? 0.5), 1.0));

    return features;
  }

  /// Extract numerical features from food item for ML model
  List<double> extractItemFeatures(FoodItem item) {
    List<double> features = [];

    // Basic features (6 features)
    features.add(item.price / 100.0); // Normalized price
    features.add(item.spiceLevel);
    features.add(item.isHalal ? 1.0 : 0.0);
    features.add(item.isVegetarian ? 1.0 : 0.0);
    features.add(item.averageRating / 5.0);
    features.add(min(item.totalOrders / 100.0, 1.0));

    // Cuisine type (5 features - one-hot encoded)
    List<String> cuisines = ['Malay', 'Chinese', 'Indian', 'Western', 'Thai'];
    for (String cuisine in cuisines) {
      features.add(item.cuisineType == cuisine ? 1.0 : 0.0);
    }

    // Categories (4 features - binary indicators)
    List<String> commonCats = ['rice', 'noodles', 'soup', 'dessert'];
    for (String cat in commonCats) {
      bool hasCat = item.categories.any((c) => c.toLowerCase().contains(cat));
      features.add(hasCat ? 1.0 : 0.0);
    }

    // Popularity metrics (2 features) - use totalRatings and totalOrders as proxies
    features.add(min(item.totalRatings / 1000.0, 1.0));
    features.add(min(item.totalOrders / 100.0, 1.0));

    // Time appropriateness (3 features) - infer from categories
    features.add(
      _hasMealTimeCategory(item.categories, 'breakfast') ? 1.0 : 0.0,
    );
    features.add(_hasMealTimeCategory(item.categories, 'lunch') ? 1.0 : 0.0);
    features.add(_hasMealTimeCategory(item.categories, 'dinner') ? 1.0 : 0.0);

    return features;
  }

  /// Check if item has meal time category
  bool _hasMealTimeCategory(List<String> categories, String mealTime) {
    return categories.any(
      (c) => c.toLowerCase().contains(mealTime.toLowerCase()),
    );
  }

  /// Build user profile from interactions
  Future<Map<String, double>> _buildUserProfile(
    auth_models.UserModel user,
    List<UserInteraction> interactions,
  ) async {
    Map<String, double> profile = Map.from(user.cuisinePreferences);

    // Learn from interactions
    final foodRepository = di.sl<FoodRepository>();
    for (UserInteraction interaction in interactions) {
      try {
        final itemResult = await foodRepository.getFoodItem(interaction.itemId);
        final itemEntity = itemResult.fold(
          (failure) => null,
          (entity) => entity,
        );

        if (itemEntity == null) continue;

        // Convert to FoodItem for compatibility
        final item = itemEntity.toFoodItem();

        double weight = _getInteractionWeight(interaction);

        // Update cuisine preferences
        profile[item.cuisineType] =
            (profile[item.cuisineType] ?? 0.0) + weight * 0.1;

        // Update category preferences
        for (String category in item.categories) {
          profile['category_$category'] =
              (profile['category_$category'] ?? 0.0) + weight * 0.05;
        }

        // Update spice preference
        profile['spice'] =
            (profile['spice'] ?? 0.5) * 0.9 + item.spiceLevel * 0.1;
      } catch (e) {
        logger.w('Error processing interaction: $e');
      }
    }

    // Normalize values
    return _normalizeProfile(profile);
  }

  /// Calculate content-based score
  double _calculateContentScore(
    Map<String, double> userProfile,
    FoodItem item,
  ) {
    double score = 0.0;

    // Cuisine matching (40% weight)
    score += (userProfile[item.cuisineType] ?? 0.0) * 0.4;

    // Category matching (30% weight)
    double categoryScore = 0.0;
    int matchedCategories = 0;
    for (String category in item.categories) {
      categoryScore += (userProfile['category_$category'] ?? 0.0);
      matchedCategories++;
    }
    if (matchedCategories > 0) {
      score += (categoryScore / matchedCategories) * 0.3;
    }

    // Spice level matching (15% weight)
    if (userProfile.containsKey('spice')) {
      double spiceDiff = (userProfile['spice']! - item.spiceLevel).abs();
      score += (1.0 - spiceDiff) * 0.15;
    }

    // Rating quality (15% weight)
    score += (item.averageRating / 5.0) * 0.15;

    return score.clamp(0.0, 1.0);
  }

  /// Calculate contextual score based on current situation
  double _calculateContextualScore(
    FoodItem item,
    RecommendationContext context,
    auth_models.UserModel user,
  ) {
    double score = 0.5; // Base score

    // Time of day matching (30% weight)
    if (context.timeOfDay != null) {
      if (_isAppropriateForTimeOfDay(item, context.timeOfDay!)) {
        score += 0.3;
      }
    }

    // Weather matching (20% weight)
    if (context.weather != null) {
      if (_matchesWeather(item, context.weather!)) {
        score += 0.2;
      }
    }

    // Location proximity (25% weight)
    if (context.currentLocation != null) {
      double distance = _calculateDistance(
        context.currentLocation!,
        item.restaurantLocation,
      );
      // Prefer closer restaurants (within 5km)
      if (distance < 5.0) {
        score += 0.25 * (1.0 - distance / 5.0);
      }
    }

    // Occasion matching (15% weight)
    if (context.occasion != null) {
      if (_matchesOccasion(item, context.occasion!)) {
        score += 0.15;
      }
    }

    // Group size consideration (10% weight)
    // Note: restaurant info not available in FoodItem, skip for now
    // This could be added by fetching restaurant data separately if needed

    return score.clamp(0.0, 1.0);
  }

  /// Get current context
  Future<RecommendationContext> _getCurrentContext(String userId) async {
    final now = DateTime.now();
    final userRepository = di.sl<UserRepository>();

    final userResult = await userRepository.getUser(userId);
    final userEntity = userResult.fold((failure) => null, (entity) => entity);

    // Convert to UserModel for compatibility (we need location)
    auth_models.UserModel? user;
    auth_models.Location? userLocation;
    if (userEntity != null) {
      user = userEntity.toModel();
      userLocation = user.currentLocation;
    }

    return RecommendationContext(
      userId: userId,
      timestamp: now,
      timeOfDay: _getTimeOfDay(now),
      dayOfWeek: _getDayOfWeek(now),
      weather: await _getCurrentWeather(userLocation),
      temperature: null, // TODO: Get from weather API
      currentLocation: userLocation,
      occasion: null,
      groupSize: null,
    );
  }

  /// Check if item is appropriate for time of day
  bool _isAppropriateForTimeOfDay(FoodItem item, String timeOfDay) {
    switch (timeOfDay) {
      case 'morning':
        return _hasMealTimeCategory(item.categories, 'breakfast');
      case 'afternoon':
        return _hasMealTimeCategory(item.categories, 'lunch');
      case 'evening':
      case 'night':
        return _hasMealTimeCategory(item.categories, 'dinner');
      default:
        return true;
    }
  }

  /// Check if item matches weather
  bool _matchesWeather(FoodItem item, String weather) {
    // Rainy weather - prefer soup, hot meals
    if (weather == 'rainy') {
      return item.categories.any(
        (c) =>
            c.toLowerCase().contains('soup') || c.toLowerCase().contains('hot'),
      );
    }

    // Hot weather - prefer cold items, refreshing
    if (weather == 'sunny' || weather == 'hot') {
      return item.categories.any(
        (c) =>
            c.toLowerCase().contains('cold') ||
            c.toLowerCase().contains('dessert') ||
            c.toLowerCase().contains('refreshing'),
      );
    }

    return true;
  }

  /// Check if item matches occasion
  bool _matchesOccasion(FoodItem item, String occasion) {
    switch (occasion) {
      case 'date':
        // Use price as indicator for romantic/formal places
        return item.price >= 30.0;
      case 'family':
        // Assume most items are family-friendly, use price as filter
        return item.price <= 50.0;
      case 'business':
        // Use price as indicator for formal places
        return item.price >= 25.0;
      case 'casual':
      default:
        return true;
    }
  }

  /// Calculate distance between two locations (Haversine formula)
  double _calculateDistance(
    auth_models.Location loc1,
    auth_models.Location loc2,
  ) {
    const double earthRadius = 6371; // km

    double lat1 = loc1.latitude * pi / 180;
    double lat2 = loc2.latitude * pi / 180;
    double dLat = (loc2.latitude - loc1.latitude) * pi / 180;
    double dLon = (loc2.longitude - loc1.longitude) * pi / 180;

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Get time of day
  String _getTimeOfDay(DateTime dateTime) {
    int hour = dateTime.hour;
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }

  /// Get day of week
  String _getDayOfWeek(DateTime dateTime) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[dateTime.weekday - 1];
  }

  /// Get current weather (mock - integrate with weather API)
  Future<String?> _getCurrentWeather(auth_models.Location? location) async {
    // TODO: Integrate with weather API (OpenWeatherMap, WeatherAPI, etc.)
    // For now, return mock data
    return 'sunny';
  }

  /// Get interaction weight for building user profile
  double _getInteractionWeight(UserInteraction interaction) {
    switch (interaction.interactionType.toLowerCase()) {
      case 'order':
        return (interaction.rating ?? 3.0) / 5.0;
      case 'like':
        return 0.8;
      case 'bookmark':
        return 0.6;
      case 'share':
        return 0.7;
      case 'view':
        return 0.2;
      default:
        return 0.1;
    }
  }

  /// Normalize profile values
  Map<String, double> _normalizeProfile(Map<String, double> profile) {
    Map<String, double> normalized = {};

    for (String key in profile.keys) {
      normalized[key] = profile[key]!.clamp(0.0, 1.0);
    }

    return normalized;
  }

  /// Calculate confidence score
  double _calculateConfidence(double score) {
    return score.clamp(0.0, 1.0);
  }

  /// Generate reason for collaborative recommendation
  String _generateCollaborativeReason(double score, FoodItem item) {
    if (score > 0.8) {
      return "Highly recommended by users with similar taste preferences";
    } else if (score > 0.6) {
      return "Users like you often enjoy this ${item.cuisineType} dish";
    } else {
      return "Recommended based on community preferences";
    }
  }

  /// Generate reason for content-based recommendation
  String _generateContentBasedReason(
    Map<String, double> userProfile,
    FoodItem item,
  ) {
    // Find strongest matching aspect
    double cuisineMatch = userProfile[item.cuisineType] ?? 0.0;

    if (cuisineMatch > 0.7) {
      return "Perfect match for your love of ${item.cuisineType} cuisine";
    }

    List<String> matchedCategories = [];
    for (String category in item.categories) {
      if ((userProfile['category_$category'] ?? 0.0) > 0.5) {
        matchedCategories.add(category);
      }
    }

    if (matchedCategories.isNotEmpty) {
      return "Matches your preference for ${matchedCategories.first}";
    }

    return "Based on your food preferences";
  }

  /// Generate reason for contextual recommendation
  String _generateContextualReason(
    RecommendationContext context,
    FoodItem item,
  ) {
    List<String> reasons = [];

    if (context.timeOfDay != null &&
        _isAppropriateForTimeOfDay(item, context.timeOfDay!)) {
      reasons.add("perfect for ${context.timeOfDay}");
    }

    if (context.weather != null && _matchesWeather(item, context.weather!)) {
      reasons.add("great for ${context.weather} weather");
    }

    if (context.currentLocation != null) {
      double distance = _calculateDistance(
        context.currentLocation!,
        item.restaurantLocation,
      );
      if (distance < 2.0) {
        reasons.add("nearby");
      }
    }

    if (reasons.isEmpty) {
      return "Recommended for current situation";
    }

    return "Great choice - ${reasons.join(', ')}";
  }

  /// Apply business rules and ensure diversity
  Future<List<RecommendationItem>> _applyBusinessRules(
    List<RecommendationItem> recommendations,
    String userId,
  ) async {
    Set<String> seenCuisines = {};
    List<RecommendationItem> diverseRecommendations = [];

    recommendations.sort((a, b) => b.score.compareTo(a.score));

    final foodRepository = di.sl<FoodRepository>();
    for (RecommendationItem rec in recommendations) {
      try {
        final itemResult = await foodRepository.getFoodItem(rec.itemId);
        final itemEntity = itemResult.fold(
          (failure) => null,
          (entity) => entity,
        );

        if (itemEntity == null) continue;

        // Convert to FoodItem for compatibility
        final item = itemEntity.toFoodItem();

        // Ensure cuisine diversity
        if (seenCuisines.length < 3 ||
            !seenCuisines.contains(item.cuisineType)) {
          seenCuisines.add(item.cuisineType);

          // Boost diversity bonus
          double diversityBonus = seenCuisines.length <= 3 ? 0.1 : 0.0;

          diverseRecommendations.add(
            rec.copyWith(score: (rec.score + diversityBonus).clamp(0.0, 1.0)),
          );
        } else if (diverseRecommendations.length <
            recommendations.length * 0.8) {
          diverseRecommendations.add(rec);
        }

        if (diverseRecommendations.length >= recommendations.length) break;
      } on FirebaseException catch (e) {
        logger.w(
          'Firebase error applying business rules: ${e.code} - ${e.message}',
        );
      } catch (e) {
        logger.w('Error applying business rules to item ${rec.itemId}: $e');
      }
    }

    return diverseRecommendations;
  }

  /// Get fallback recommendations
  Future<List<RecommendationItem>> _getFallbackRecommendations(
    String userId,
    int limit,
  ) async {
    try {
      logger.i('Getting fallback recommendations for user: $userId');

      // Try multiple sources to ensure we get some recommendations
      List<FoodItem> items = [];

      // Try popular items
      final foodRepository = di.sl<FoodRepository>();
      try {
        final popularResult = await foodRepository.getPopularItems(
          limit: limit * 2,
        );
        items = popularResult.fold(
          (failure) => <FoodItem>[],
          (entities) => entities.map((e) => e.toFoodItem()).toList(),
        );
        logger.i('Found ${items.length} popular items');
      } catch (e) {
        logger.w('Error getting popular items: $e');
      }

      // If no popular items, try highly rated items
      if (items.isEmpty) {
        try {
          final highlyRatedResult = await foodRepository.getHighlyRatedItems(
            limit: limit * 2,
          );
          items = highlyRatedResult.fold(
            (failure) => <FoodItem>[],
            (entities) => entities.map((e) => e.toFoodItem()).toList(),
          );
          logger.i('Found ${items.length} highly rated items');
        } catch (e) {
          logger.w('Error getting highly rated items: $e');
        }
      }

      // If still no items, try to get any active items
      if (items.isEmpty) {
        try {
          // This would require a method in FoodService to get any active items
          // For now, we'll return empty and let the UI handle it
          logger.w('No items available for fallback recommendations');
          return [];
        } catch (e) {
          logger.w('Error getting any items: $e');
        }
      }

      // Convert to recommendations
      return items
          .take(limit)
          .map(
            (item) => RecommendationItem(
              itemId: item.id,
              score: 0.7,
              reason: "Popular choice in Malaysia",
              algorithmType: 'fallback',
              confidence: 0.6,
              generatedAt: DateTime.now(),
            ),
          )
          .toList();
    } on FirebaseException catch (e) {
      logger.e(
        'Firebase error getting fallback recommendations: ${e.code} - ${e.message}',
      );
      return [];
    } catch (e, stackTrace) {
      logger.e('Error getting fallback recommendations: $e\n$stackTrace');
      return [];
    }
  }
}
