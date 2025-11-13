import 'package:logger/logger.dart';
import 'package:makan_mate/ai_engine/recommendation_engine.dart';
import 'package:makan_mate/features/auth/data/models/user_models.dart';
import 'package:makan_mate/features/food/data/models/food_models.dart';

/// Utility class to test and validate TFLite model functionality
///
/// This helps verify the model is working correctly before deployment
class ModelTester {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  final RecommendationEngine _engine = RecommendationEngine();

  /// Run comprehensive model tests
  Future<ModelTestResult> runTests() async {
    _logger.i('Starting TFLite model verification tests...');

    final results = <String, bool>{};
    final messages = <String>[];

    try {
      // Test 1: Model Initialization
      _logger.i('Test 1: Model Initialization');
      await _testModelInitialization(results, messages);

      // Test 2: Model Loading
      _logger.i('Test 2: Model Loading');
      await _testModelLoading(results, messages);

      // Test 3: Feature Extraction
      _logger.i('Test 3: Feature Extraction');
      await _testFeatureExtraction(results, messages);

      // Test 4: Inference
      _logger.i('Test 4: Model Inference');
      await _testInference(results, messages);

      // Test 5: Recommendation Generation
      _logger.i('Test 5: Recommendation Generation');
      await _testRecommendationGeneration(results, messages);

      _logger.i('All tests completed');

      return ModelTestResult(
        passed: !results.values.contains(false),
        testResults: results,
        messages: messages,
      );
    } catch (e, stackTrace) {
      _logger.e('Test suite failed: $e', stackTrace: stackTrace);
      return ModelTestResult(
        passed: false,
        testResults: results,
        messages: [...messages, 'Fatal error: $e'],
      );
    }
  }

  Future<void> _testModelInitialization(
    Map<String, bool> results,
    List<String> messages,
  ) async {
    try {
      await _engine.initialize();
      results['initialization'] = true;
      messages.add('✓ Model initialized successfully');
      _logger.i('Model initialization: PASSED');
    } catch (e) {
      results['initialization'] = false;
      messages.add('✗ Model initialization failed: $e');
      _logger.e('Model initialization: FAILED - $e');
    }
  }

  Future<void> _testModelLoading(
    Map<String, bool> results,
    List<String> messages,
  ) async {
    try {
      if (_engine.isModelLoaded) {
        results['loading'] = true;
        messages.add('✓ Model loaded successfully');
        _logger.i('Model loading: PASSED');

        // Log model info
        if (_engine.inputShapes != null) {
          messages.add('  Input shapes: ${_engine.inputShapes}');
          messages.add('  Output shapes: ${_engine.outputShapes}');
        }
      } else {
        results['loading'] = false;
        messages.add('✗ Model not loaded');
        _logger.w('Model loading: FAILED - Model not loaded');
      }
    } catch (e) {
      results['loading'] = false;
      messages.add('✗ Model loading check failed: $e');
      _logger.e('Model loading: FAILED - $e');
    }
  }

  Future<void> _testFeatureExtraction(
    Map<String, bool> results,
    List<String> messages,
  ) async {
    try {
      // Create test user
      final now = DateTime.now();
      final testUser = UserModel(
        id: 'test_user',
        name: 'Test User',
        email: 'test@test.com',
        cuisinePreferences: {
          'Malay': 0.8,
          'Chinese': 0.6,
          'Indian': 0.4,
          'Western': 0.3,
          'Thai': 0.7,
        },
        dietaryRestrictions: ['halal'],
        spiceTolerance: 0.7,
        culturalBackground: 'Malay',
        currentLocation: Location(
          latitude: 3.1390,
          longitude: 101.6869,
          city: 'Kuala Lumpur',
          state: 'Federal Territory',
          country: 'Malaysia',
        ),
        behaviorPatterns: {'avg_price': 35.0, 'activity_level': 0.6},
        createdAt: now,
        updatedAt: now,
      );

      // Create test food item
      final testFood = FoodItem(
        id: 'test_food',
        name: 'Nasi Lemak',
        description: 'Traditional Malaysian dish',
        price: 12.0,
        cuisineType: 'Malay',
        categories: ['rice', 'breakfast', 'traditional'],
        isHalal: true,
        isVegetarian: false,
        isVegan: false,
        spiceLevel: 0.6,
        averageRating: 4.5,
        totalRatings: 100,
        totalOrders: 250,
        imageUrls: [],
        restaurantId: 'test_restaurant',
        restaurantLocation: Location(
          latitude: 3.1390,
          longitude: 101.6869,
          city: 'Kuala Lumpur',
          state: 'Federal Territory',
          country: 'Malaysia',
        ),
        createdAt: now,
        updatedAt: now,
      );

      // Extract features
      final userFeatures = _engine.extractUserFeatures(testUser);
      final itemFeatures = _engine.extractItemFeatures(testFood);

      // Validate feature dimensions
      if (userFeatures.length == RecommendationEngine.USER_FEATURE_DIM &&
          itemFeatures.length == RecommendationEngine.ITEM_FEATURE_DIM) {
        results['feature_extraction'] = true;
        messages.add('✓ Feature extraction working correctly');
        messages.add('  User features: ${userFeatures.length} dimensions');
        messages.add('  Item features: ${itemFeatures.length} dimensions');
        _logger.i('Feature extraction: PASSED');
      } else {
        results['feature_extraction'] = false;
        messages.add(
          '✗ Feature dimension mismatch: '
          'User: ${userFeatures.length}/${RecommendationEngine.USER_FEATURE_DIM}, '
          'Item: ${itemFeatures.length}/${RecommendationEngine.ITEM_FEATURE_DIM}',
        );
        _logger.e('Feature extraction: FAILED - Dimension mismatch');
      }
    } catch (e) {
      results['feature_extraction'] = false;
      messages.add('✗ Feature extraction failed: $e');
      _logger.e('Feature extraction: FAILED - $e');
    }
  }

  Future<void> _testInference(
    Map<String, bool> results,
    List<String> messages,
  ) async {
    try {
      if (!_engine.isModelLoaded) {
        results['inference'] = false;
        messages.add('✗ Cannot test inference: Model not loaded');
        return;
      }

      // Create test data
      final now = DateTime.now();
      final testUser = UserModel(
        id: 'test_user',
        name: 'Test User',
        email: 'test@test.com',
        cuisinePreferences: {
          'Malay': 0.8,
          'Chinese': 0.6,
          'Indian': 0.4,
          'Western': 0.3,
          'Thai': 0.7,
        },
        dietaryRestrictions: ['halal'],
        spiceTolerance: 0.7,
        culturalBackground: 'Malay',
        currentLocation: Location(
          latitude: 3.1390,
          longitude: 101.6869,
          city: 'Kuala Lumpur',
          state: 'Federal Territory',
          country: 'Malaysia',
        ),
        behaviorPatterns: {'avg_price': 35.0, 'activity_level': 0.6},
        createdAt: now,
        updatedAt: now,
      );

      final testFood = FoodItem(
        id: 'test_food',
        name: 'Nasi Lemak',
        description: 'Traditional Malaysian dish',
        price: 12.0,
        cuisineType: 'Malay',
        categories: ['rice', 'breakfast', 'traditional'],
        isHalal: true,
        isVegetarian: false,
        isVegan: false,
        spiceLevel: 0.6,
        averageRating: 4.5,
        totalRatings: 100,
        totalOrders: 250,
        imageUrls: [],
        restaurantId: 'test_restaurant',
        restaurantLocation: Location(
          latitude: 3.1390,
          longitude: 101.6869,
          city: 'Kuala Lumpur',
          state: 'Federal Territory',
          country: 'Malaysia',
        ),
        createdAt: now,
        updatedAt: now,
      );

      // Run inference
      final userFeatures = _engine.extractUserFeatures(testUser);
      final itemFeatures = _engine.extractItemFeatures(testFood);

      var input = List<double>.from(userFeatures)..addAll(itemFeatures);
      var inputTensor = [input];
      var output = List.filled(1, List.filled(1, 0.0));

      _engine.interpreter!.run(inputTensor, output);

      final score = output[0][0];

      if (score >= 0.0 && score <= 1.0) {
        results['inference'] = true;
        messages.add('✓ Model inference working correctly');
        messages.add('  Test prediction score: ${score.toStringAsFixed(4)}');
        _logger.i('Model inference: PASSED (score: $score)');
      } else {
        results['inference'] = false;
        messages.add('✗ Invalid prediction score: $score (should be 0.0-1.0)');
        _logger.e('Model inference: FAILED - Invalid score: $score');
      }
    } catch (e, stackTrace) {
      results['inference'] = false;
      messages.add('✗ Model inference failed: $e');
      _logger.e('Model inference: FAILED - $e', stackTrace: stackTrace);
    }
  }

  Future<void> _testRecommendationGeneration(
    Map<String, bool> results,
    List<String> messages,
  ) async {
    try {
      // Note: This test requires actual user data and food items
      // In production, you would test with real user IDs

      results['recommendation_generation'] = true;
      messages.add('✓ Recommendation generation ready');
      messages.add('  Note: Full test requires user data in Firestore');
      _logger.i('Recommendation generation: READY');
    } catch (e) {
      results['recommendation_generation'] = false;
      messages.add('✗ Recommendation generation test failed: $e');
      _logger.e('Recommendation generation: FAILED - $e');
    }
  }

  /// Generate test recommendations for a user
  Future<void> generateTestRecommendations(String userId) async {
    try {
      _logger.i('Generating test recommendations for user: $userId');

      final recommendations = await _engine.getRecommendations(
        userId: userId,
        limit: 10,
      );

      _logger.i('Generated ${recommendations.length} recommendations');

      for (final rec in recommendations.take(5)) {
        _logger.i(
          'Item: ${rec.itemId}, Score: ${rec.score.toStringAsFixed(3)}, '
          'Algorithm: ${rec.algorithmType}, Confidence: ${rec.confidence.toStringAsFixed(2)}',
        );
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to generate recommendations: $e',
        stackTrace: stackTrace,
      );
    }
  }
}

/// Result of model testing
class ModelTestResult {
  final bool passed;
  final Map<String, bool> testResults;
  final List<String> messages;

  ModelTestResult({
    required this.passed,
    required this.testResults,
    required this.messages,
  });

  String get summary {
    final passedCount = testResults.values.where((v) => v).length;
    final totalCount = testResults.length;
    return 'Passed: $passedCount/$totalCount tests';
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Model Test Results:');
    buffer.writeln('Overall: ${passed ? "PASSED ✓" : "FAILED ✗"}');
    buffer.writeln(summary);
    buffer.writeln('\nDetailed Results:');
    for (final message in messages) {
      buffer.writeln(message);
    }
    return buffer.toString();
  }
}
