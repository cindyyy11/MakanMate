import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:makan_mate/ai_engine/ai_engine_base.dart';
import 'package:makan_mate/models/food_models.dart';
import 'package:makan_mate/models/recommendation_models.dart';
import 'package:makan_mate/models/user_models.dart';
import 'package:makan_mate/services/food_service.dart';
import 'package:makan_mate/services/user_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io';


class RecommendationEngine extends AIEngineBase {
  static final RecommendationEngine _instance = RecommendationEngine._internal();
  factory RecommendationEngine() => _instance;
  RecommendationEngine._internal();
  
  bool _isInitialized = false;
  
  // Feature dimensions (must match training script)
  static const int USER_FEATURE_DIM = 15;
  static const int ITEM_FEATURE_DIM = 20;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      logger.i('Initializing AI Recommendation Engine...');
      
      // Download latest model if available
      await _downloadLatestModel();
      
      // Load the model
      await loadModel('assets/ml_models/recommendation_model.tflite');
      
      _isInitialized = true;
      logger.i('AI Recommendation Engine initialized successfully!');
      
    } catch (e) {
      logger.e('Error initializing recommendation engine: $e');
      // Try to load fallback model
      await _loadFallbackModel();
    }
  }
  
  Future<void> _downloadLatestModel() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final modelDir = Directory('${directory.path}/ml_models');
      if (!modelDir.existsSync()) {
        modelDir.createSync(recursive: true);
      }
      
      final modelFile = File('${modelDir.path}/recommendation_model.tflite');
      
      // Check if we should download a new version
      if (!modelFile.existsSync() || await _shouldUpdateModel()) {
        logger.i('Downloading latest AI model...');
        
        final ref = FirebaseStorage.instance.ref().child('ml_models/recommendation_model.tflite');
        await ref.writeToFile(modelFile);
        
        logger.i('Latest model downloaded');
      }
      
    } catch (e) {
      logger.w('Could not download latest model: $e');
    }
  }
  
  Future<bool> _shouldUpdateModel() async {
    // Check model version/timestamp logic here
    return false; // Implement version checking
  }
  
  Future<void> _loadFallbackModel() async {
    try {
      // Create a simple rule-based fallback
      logger.w('Loading fallback recommendation system');
      _isInitialized = true;
    } catch (e) {
      logger.e('Failed to load fallback model: $e');
    }
  }
  
  // Main recommendation method
  Future<List<RecommendationItem>> generateRecommendations({
    required String userId,
    int limit = 20,
    String? context,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      logger.i('Generating recommendations for user: $userId');
      
      // Get hybrid recommendations
      List<RecommendationItem> recommendations = await _generateHybridRecommendations(
        userId: userId,
        limit: limit * 2, // Get more to ensure diversity
      );
      
      // Apply business rules and diversity
      recommendations = await _applyBusinessRules(recommendations, userId);
      
      // Sort and limit
      recommendations.sort((a, b) => b.score.compareTo(a.score));
      
      logger.i('Generated ${recommendations.length} recommendations');
      return recommendations.take(limit).toList();
      
    } catch (e) {
      logger.e('Error generating recommendations: $e');
      return await _getFallbackRecommendations(userId, limit);
    }
  }
  
  Future<List<RecommendationItem>> _generateHybridRecommendations({
    required String userId,
    required int limit,
  }) async {
    // Get candidate items
    List<FoodItem> candidateItems = await FoodService().getCandidateItems(userId);
    if (candidateItems.isEmpty) {
      return await _getFallbackRecommendations(userId, limit);
    }
    
    // Get different types of recommendations
    List<RecommendationItem> collaborativeRecs = await _generateCollaborativeRecommendations(
      userId: userId,
      candidateItems: candidateItems,
      limit: limit,
    );
    
    List<RecommendationItem> contentBasedRecs = await _generateContentBasedRecommendations(
      userId: userId,
      candidateItems: candidateItems,
      limit: limit,
    );
    
    List<RecommendationItem> contextualRecs = await _generateContextualRecommendations(
      userId: userId,
      candidateItems: candidateItems.take(50).toList(),
      limit: limit ~/ 2,
    );
    
    // Combine with weights
    Map<String, RecommendationItem> combinedRecs = {};
    
    // Collaborative filtering: 40% weight
    for (var rec in collaborativeRecs) {
      combinedRecs[rec.itemId] = rec.copyWith(
        score: rec.score * 0.4,
        algorithmType: 'hybrid',
      );
    }
    
    // Content-based: 35% weight
    for (var rec in contentBasedRecs) {
      if (combinedRecs.containsKey(rec.itemId)) {
        var existing = combinedRecs[rec.itemId]!;
        combinedRecs[rec.itemId] = existing.copyWith(
          score: existing.score + (rec.score * 0.35),
        );
      } else {
        combinedRecs[rec.itemId] = rec.copyWith(
          score: rec.score * 0.35,
          algorithmType: 'hybrid',
        );
      }
    }
    
    // Contextual: 25% weight
    for (var rec in contextualRecs) {
      if (combinedRecs.containsKey(rec.itemId)) {
        var existing = combinedRecs[rec.itemId]!;
        combinedRecs[rec.itemId] = existing.copyWith(
          score: existing.score + (rec.score * 0.25),
        );
      } else {
        combinedRecs[rec.itemId] = rec.copyWith(
          score: rec.score * 0.25,
          algorithmType: 'hybrid',
        );
      }
    }
    
    return combinedRecs.values.toList();
  }
  
  Future<List<RecommendationItem>> _generateCollaborativeRecommendations({
    required String userId,
    required List<FoodItem> candidateItems,
    required int limit,
  }) async {
    if (!isModelLoaded) {
      // Use similarity-based collaborative filtering
      return await _generateSimilarityBasedRecommendations(userId, candidateItems, limit);
    }
    
    try {
      UserModel? user = await UserService().getUser(userId);
      if (user == null) return [];
      
      List<double> userFeatures = user.toFeatureVector();
      List<RecommendationItem> recommendations = [];
      
      for (FoodItem item in candidateItems) {
        List<double> itemFeatures = item.toFeatureVector();
        
        // Prepare input for TensorFlow Lite model
        var input = [
          [userFeatures], // Batch size 1
          [itemFeatures],
        ];
        
        var output = List.filled(1, 0.0).reshape([1, 1]);
        
        // Run inference
        interpreter!.runForMultipleInputs(input, {0: output});
        
        double score = output[0][0];
        
        if (score > 0.5) { // Threshold for good recommendations
          recommendations.add(RecommendationItem(
            itemId: item.id,
            score: score,
            reason: "Based on users with similar preferences",
            algorithmType: 'collaborative_filtering',
            confidence: _calculateConfidence(score),
            generatedAt: DateTime.now(),
          ));
        }
      }
      
      recommendations.sort((a, b) => b.score.compareTo(a.score));
      return recommendations.take(limit).toList();
      
    } catch (e) {
      logger.e('Error in collaborative filtering: $e');
      return await _generateSimilarityBasedRecommendations(userId, candidateItems, limit);
    }
  }
  
  Future<List<RecommendationItem>> _generateContentBasedRecommendations({
    required String userId,
    required List<FoodItem> candidateItems,
    required int limit,
  }) async {
    try {
      UserModel? user = await UserService().getUser(userId);
      if (user == null) return [];
      
      List<UserInteraction> userHistory = await UserService().getUserInteractions(userId);
      Map<String, double> userProfile = await _buildUserProfile(user, userHistory);
      
      List<RecommendationItem> recommendations = [];
      
      for (FoodItem item in candidateItems) {
        double contentScore = _calculateContentScore(userProfile, item);
        
        if (contentScore > 0.3) {
          recommendations.add(RecommendationItem(
            itemId: item.id,
            score: contentScore,
            reason: _generateContentBasedReason(userProfile, item),
            algorithmType: 'content_based',
            confidence: _calculateConfidence(contentScore),
            generatedAt: DateTime.now(),
          ));
        }
      }
      
      recommendations.sort((a, b) => b.score.compareTo(a.score));
      return recommendations.take(limit).toList();
      
    } catch (e) {
      logger.e('Error in content-based filtering: $e');
      return [];
    }
  }
  
  Future<List<RecommendationItem>> _generateContextualRecommendations({
    required String userId,
    required List<FoodItem> candidateItems,
    required int limit,
  }) async {
    try {
      Map<String, dynamic> context = await _getCurrentContext();
      UserModel? user = await UserService().getUser(userId);
      
      if (user == null) return [];
      
      List<RecommendationItem> recommendations = [];
      
      for (FoodItem item in candidateItems) {
        double contextScore = _calculateContextualScore(item, context, user);
        
        if (contextScore > 0.4) {
          recommendations.add(RecommendationItem(
            itemId: item.id,
            score: contextScore,
            reason: _generateContextualReason(context, item),
            algorithmType: 'contextual',
            confidence: _calculateConfidence(contextScore),
            generatedAt: DateTime.now(),
          ));
        }
      }
      
      return recommendations.take(limit).toList();
    } catch (e) {
      logger.e('Error in contextual recommendations: $e');
      return [];
    }
  }
  
  // Fallback similarity-based collaborative filtering
  Future<List<RecommendationItem>> _generateSimilarityBasedRecommendations(
    String userId,
    List<FoodItem> candidateItems,
    int limit,
  ) async {
    try {
      // Get user interactions
      List<UserInteraction> userInteractions = await UserService().getUserInteractions(userId);
      
      if (userInteractions.isEmpty) {
        return await _generatePopularityBasedRecommendations(candidateItems, limit);
      }
      
      // Get items user has liked
      Set<String> likedItems = userInteractions
          .where((i) => (i.rating ?? 0) >= 4.0 || i.interactionType == 'order')
          .map((i) => i.itemId)
          .toSet();
      
      if (likedItems.isEmpty) {
        return await _generatePopularityBasedRecommendations(candidateItems, limit);
      }
      
      // Find similar users based on common liked items
      List<UserInteraction> allInteractions = await UserService().getInteractionsSince(
        DateTime.now().subtract(Duration(days: 30)),
      );
      
      Map<String, Set<String>> otherUserLikes = {};
      for (var interaction in allInteractions) {
        if (interaction.userId != userId && 
            ((interaction.rating ?? 0) >= 4.0 || interaction.interactionType == 'order')) {
          otherUserLikes.putIfAbsent(interaction.userId, () => {}).add(interaction.itemId);
        }
      }
      
      // Calculate user similarities
      Map<String, double> userSimilarities = {};
      for (String otherUserId in otherUserLikes.keys) {
        Set<String> commonItems = likedItems.intersection(otherUserLikes[otherUserId]!);
        if (commonItems.isNotEmpty) {
          double similarity = commonItems.length / 
              (likedItems.union(otherUserLikes[otherUserId]!).length);
          userSimilarities[otherUserId] = similarity;
        }
      }
      
      // Get recommendations from similar users
      List<String> sortedSimilarUsers = userSimilarities.keys.toList()
        ..sort((a, b) => userSimilarities[b]!.compareTo(userSimilarities[a]!));
      
      Map<String, double> itemScores = {};
      Set<String> userAlreadyHas = userInteractions.map((i) => i.itemId).toSet();
      
      for (String similarUserId in sortedSimilarUsers.take(20)) {
        double userSimilarity = userSimilarities[similarUserId]!;
        
        for (String itemId in otherUserLikes[similarUserId]!) {
          if (!userAlreadyHas.contains(itemId) && 
              candidateItems.any((item) => item.id == itemId)) {
            itemScores[itemId] = (itemScores[itemId] ?? 0.0) + userSimilarity;
          }
        }
      }
      
      List<RecommendationItem> recommendations = [];
      for (String itemId in itemScores.keys) {
        recommendations.add(RecommendationItem(
          itemId: itemId,
          score: itemScores[itemId]! / 5.0, // Normalize
          reason: "Recommended by users with similar taste",
          algorithmType: 'collaborative_similarity',
          confidence: _calculateConfidence(itemScores[itemId]! / 5.0),
          generatedAt: DateTime.now(),
        ));
      }
      
      recommendations.sort((a, b) => b.score.compareTo(a.score));
      return recommendations.take(limit).toList();
      
    } catch (e) {
      logger.e('Error in similarity-based recommendations: $e');
      return [];
    }
  }
  
  Future<List<RecommendationItem>> _generatePopularityBasedRecommendations(
    List<FoodItem> candidateItems,
    int limit,
  ) async {
    List<FoodItem> popularItems = candidateItems.where((item) => item.totalOrders > 0).toList();
    popularItems.sort((a, b) => b.totalOrders.compareTo(a.totalOrders));
    
    return popularItems.take(limit).map((item) => RecommendationItem(
      itemId: item.id,
      score: min(item.totalOrders / 100.0, 1.0),
      reason: "Popular choice among users",
      algorithmType: 'popularity',
      confidence: 0.7,
      generatedAt: DateTime.now(),
    )).toList();
  }
  
  // Helper methods
  Future<Map<String, double>> _buildUserProfile(
    UserModel user,
    List<UserInteraction> interactions,
  ) async {
    Map<String, double> profile = Map.from(user.cuisinePreferences);
    
    // Learn from interactions
    for (UserInteraction interaction in interactions) {
      try {
        FoodItem? item = await FoodService().getFoodItem(interaction.itemId);
        if (item == null) continue;
        
        double weight = _getInteractionWeight(interaction);
        
        // Update cuisine preferences
        profile[item.cuisineType] = (profile[item.cuisineType] ?? 0.0) + weight * 0.1;
        
        // Update category preferences
        for (String category in item.categories) {
          profile['category_$category'] = (profile['category_$category'] ?? 0.0) + weight * 0.05;
        }
      } catch (e) {
        logger.w('Error processing interaction: $e');
      }
    }
    
    // Normalize values
    return _normalizeProfile(profile);
  }
  
  double _calculateContentScore(Map<String, double> userProfile, FoodItem item) {
    double score = 0.0;
    
    // Cuisine matching
    score += (userProfile[item.cuisineType] ?? 0.0) * 0.4;
    
    // Category matching
    for (String category in item.categories) {
      score += (userProfile['category_$category'] ?? 0.0) * 0.2;
    }
    
    // Dietary restrictions compliance
    if (userProfile['requires_halal'] == 1.0 && !item.isHalal) score *= 0.1;
    if (userProfile['requires_vegetarian'] == 1.0 && !item.isVegetarian) score *= 0.1;
    
    // Spice level matching
    double userSpicePreference = userProfile['spice_tolerance'] ?? 0.5;
    double spiceDifference = (userSpicePreference - item.spiceLevel).abs();
    score += (1.0 - spiceDifference) * 0.2;
    
    return score.clamp(0.0, 1.0);
  }
  
  double _calculateContextualScore(
    FoodItem item,
    Map<String, dynamic> context,
    UserModel user,
  ) {
    double score = 0.5; // Base score
    
    int hour = context['hour'] ?? DateTime.now().hour;
    
    // Time-based scoring
    if (hour >= 7 && hour <= 10) {
      // Breakfast time
      if (item.categories.any((c) => c.toLowerCase().contains('breakfast'))) score += 0.3;
    } else if (hour >= 12 && hour <= 14) {
      // Lunch time
      if (item.categories.any((c) => ['lunch', 'rice', 'main'].contains(c.toLowerCase()))) score += 0.3;
    } else if (hour >= 18 && hour <= 21) {
      // Dinner time
      if (item.categories.any((c) => ['dinner', 'main'].contains(c.toLowerCase()))) score += 0.3;
    }
    
    // Weather-based scoring
    String weather = context['weather']?.toString().toLowerCase() ?? '';
    if (weather.contains('rain') && item.categories.any((c) => c.toLowerCase().contains('soup'))) {
      score += 0.2;
    }
    if (weather.contains('hot') && item.categories.any((c) => ['cold', 'ice'].contains(c.toLowerCase()))) {
      score += 0.2;
    }
    
    // Distance penalty
    double distance = context['distance_km'] ?? 5.0;
    if (distance > 10) score *= 0.8;
    if (distance > 20) score *= 0.6;
    
    return score.clamp(0.0, 1.0);
  }
  
  String _generateContentBasedReason(Map<String, double> userProfile, FoodItem item) {
    List<String> reasons = [];
    
    if ((userProfile[item.cuisineType] ?? 0.0) > 0.7) {
      reasons.add("matches your ${item.cuisineType} preference");
    }
    
    for (String category in item.categories) {
      if ((userProfile['category_$category'] ?? 0.0) > 0.6) {
        reasons.add("you enjoy $category dishes");
        break;
      }
    }
    
    if (reasons.isEmpty) {
      return "Based on your taste profile";
    }
    
    return "Great choice - ${reasons.join(' and ')}";
  }
  
  String _generateContextualReason(Map<String, dynamic> context, FoodItem item) {
    int hour = context['hour'] ?? DateTime.now().hour;
    
    if (hour >= 7 && hour <= 10) {
      return "Perfect breakfast choice";
    } else if (hour >= 12 && hour <= 14) {
      return "Great lunch option";
    } else if (hour >= 18 && hour <= 21) {
      return "Ideal for dinner";
    }
    
    String weather = context['weather']?.toString().toLowerCase() ?? '';
    if (weather.contains('rain') && item.categories.any((c) => c.toLowerCase().contains('soup'))) {
      return "Perfect for this rainy weather";
    }
    if (weather.contains('hot')) {
      return "Refreshing choice for hot weather";
    }
    
    return "Recommended for this time";
  }
  
  Future<Map<String, dynamic>> _getCurrentContext() async {
    // In a real app, get weather from API and location from GPS
    DateTime now = DateTime.now();
    
    return {
      'hour': now.hour,
      'day_of_week': now.weekday,
      'weather': 'clear', // Would come from weather API
      'temperature': 28, // Would come from weather API
      'distance_km': 5.0, // Would be calculated based on location
    };
  }
  
  double _getInteractionWeight(UserInteraction interaction) {
    switch (interaction.interactionType.toLowerCase()) {
      case 'order':
        return 1.0;
      case 'rate':
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
  
  Map<String, double> _normalizeProfile(Map<String, double> profile) {
    Map<String, double> normalized = {};
    
    for (String key in profile.keys) {
      normalized[key] = profile[key]!.clamp(0.0, 1.0);
    }
    
    return normalized;
  }
  
  double _calculateConfidence(double score) {
    return score.clamp(0.0, 1.0);
  }
  
  Future<List<RecommendationItem>> _applyBusinessRules(
    List<RecommendationItem> recommendations,
    String userId,
  ) async {
    // Apply diversity - ensure we have different cuisines and categories
    Set<String> seenCuisines = {};
    Set<String> seenCategories = {};
    List<RecommendationItem> diverseRecommendations = [];
    
    recommendations.sort((a, b) => b.score.compareTo(a.score));
    
    for (RecommendationItem rec in recommendations) {
      try {
        FoodItem? item = await FoodService().getFoodItem(rec.itemId);
        if (item == null) continue;
        
        // Ensure cuisine diversity
        if (seenCuisines.length < 3 || !seenCuisines.contains(item.cuisineType)) {
          seenCuisines.add(item.cuisineType);
          
          // Boost diversity bonus
          double diversityBonus = seenCuisines.length <= 3 ? 0.1 : 0.0;
          
          diverseRecommendations.add(rec.copyWith(
            score: (rec.score + diversityBonus).clamp(0.0, 1.0),
          ));
        } else if (diverseRecommendations.length < recommendations.length * 0.8) {
          diverseRecommendations.add(rec);
        }
        
        if (diverseRecommendations.length >= recommendations.length) break;
      } catch (e) {
        logger.w('Error applying business rules to item ${rec.itemId}: $e');
      }
    }
    
    return diverseRecommendations;
  }
  
  Future<List<RecommendationItem>> _getFallbackRecommendations(String userId, int limit) async {
    try {
      // Get popular items as fallback
      List<FoodItem> popularItems = await FoodService().getPopularItems(limit: limit);
      
      return popularItems.map((item) => RecommendationItem(
        itemId: item.id,
        score: 0.7,
        reason: "Popular choice",
        algorithmType: 'fallback',
        confidence: 0.6,
        generatedAt: DateTime.now(),
      )).toList();
    } catch (e) {
      logger.e('Error getting fallback recommendations: $e');
      return [];
    }
  }
  
  @override
  List<Object> runInference(List<Object> inputs) {
    if (!isModelLoaded) {
      throw Exception('Model not loaded');
    }
    
    // This is a simplified implementation
    // In reality, you'd process the inputs and run through TensorFlow Lite
    return [];
  }
}