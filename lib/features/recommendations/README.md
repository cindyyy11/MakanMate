# AI Recommendation System - Implementation Guide

## Overview

This is a professional implementation of an AI-powered food recommendation system using TensorFlow Lite, following Clean Architecture principles with BLoC state management.

## Architecture

```
features/recommendations/
├── data/
│   ├── datasources/
│   │   ├── recommendation_local_datasource.dart  # Hive caching
│   │   └── recommendation_remote_datasource.dart # Firebase + AI engine
│   ├── models/
│   │   └── recommendation_models.dart            # Data transfer objects
│   └── repositories/
│       └── recommendation_repository_impl.dart   # Repository implementation
├── domain/
│   ├── entities/
│   │   └── recommendation_entity.dart            # Business models
│   ├── repositories/
│   │   └── recommendation_repository.dart        # Repository interface
│   └── usecases/
│       ├── get_recommendations_usecase.dart
│       ├── get_contextual_recommendations_usecase.dart
│       ├── get_similar_items_usecase.dart
│       └── track_interaction_usecase.dart
├── presentation/
│   ├── bloc/
│   │   ├── recommendation_bloc.dart
│   │   ├── recommendation_event.dart
│   │   └── recommendation_state.dart
│   ├── pages/
│   │   └── recommendations_page.dart
│   └── widgets/
│       └── recommendation_card.dart
└── di/
    └── recommendation_injection.dart              # Dependency injection
```

## Setup Instructions

### 1. Initialize Dependencies

The recommendation system is automatically initialized through the main dependency injection container:

```dart
import 'package:makan_mate/core/di/injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize Dependency Injection (includes Recommendation System)
  await di.init();
  
  runApp(const MyApp());
}
```

### 2. Provide BLoC to Your Widget Tree

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/core/di/injection_container.dart' as di;
import 'package:makan_mate/features/recommendations/presentation/bloc/recommendation_bloc.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Other BLoCs...
        BlocProvider(
          create: (_) => di.sl<RecommendationBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'MakanMate',
        home: HomePage(),
      ),
    );
  }
}
```

### 3. Use in Your Pages

#### Simple Usage in Home Page

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:makan_mate/core/di/injection_container.dart' as di;
import 'package:makan_mate/features/food/domain/usecases/get_food_item_usecase.dart';
import 'package:makan_mate/features/food/data/models/food_models.dart';
import 'package:makan_mate/features/recommendations/presentation/bloc/recommendation_bloc.dart';
import 'package:makan_mate/features/recommendations/presentation/bloc/recommendation_event.dart';
import 'package:makan_mate/features/recommendations/presentation/bloc/recommendation_state.dart';
import 'package:makan_mate/features/recommendations/presentation/widgets/recommendation_card.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  void _loadRecommendations() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<RecommendationBloc>().add(
        LoadRecommendationsEvent(
          userId: userId,
          limit: 10,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... other widgets
            
            _buildRecommendationsSection(),
            
            // ... other widgets
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI Recommendations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<RecommendationBloc>(),
                        child: RecommendationsPage(
                          userId: FirebaseAuth.instance.currentUser!.uid,
                        ),
                      ),
                    ),
                  );
                },
                child: Text('See All'),
              ),
            ],
          ),
        ),
        
        BlocBuilder<RecommendationBloc, RecommendationState>(
          builder: (context, state) {
            if (state is RecommendationLoading) {
              return Center(child: CircularProgressIndicator());
            }
            
            if (state is RecommendationLoaded) {
              return SizedBox(
                height: 350,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.recommendations.take(5).length,
                  itemBuilder: (context, index) {
                    final rec = state.recommendations[index];
                    
                    return Container(
                      width: 280,
                      margin: EdgeInsets.only(right: 16),
                      child: FutureBuilder<FoodItem?>(
                        future: _getFoodItem(rec.itemId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Card(
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          
                          return RecommendationCard(
                            recommendation: rec,
                            foodItem: snapshot.data!,
                            onTap: () {
                              // Track view
                              context.read<RecommendationBloc>().add(
                                TrackInteractionEvent(
                                  userId: FirebaseAuth.instance.currentUser!.uid,
                                  itemId: rec.itemId,
                                  interactionType: 'view',
                                ),
                              );
                              // Navigate to detail page
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            }
            
            if (state is RecommendationError) {
              return Padding(
                padding: EdgeInsets.all(16),
                child: Text('Error loading recommendations'),
              );
            }
            
            return SizedBox.shrink();
          },
        ),
      ],
    );
  }

  // Helper method to get food item using Clean Architecture
  Future<FoodItem?> _getFoodItem(String itemId) async {
    final getFoodItemUseCase = di.sl<GetFoodItemUseCase>();
    final result = await getFoodItemUseCase(itemId);
    return result.fold(
      (failure) => null,
      (entity) => entity.toFoodItem(),
    );
  }
}
```

### 4. Tracking User Interactions

Track user interactions to improve recommendations:

```dart
// Track view
context.read<RecommendationBloc>().add(
  TrackInteractionEvent(
    userId: currentUserId,
    itemId: foodItemId,
    interactionType: 'view',
  ),
);

// Track like/bookmark
context.read<RecommendationBloc>().add(
  TrackInteractionEvent(
    userId: currentUserId,
    itemId: foodItemId,
    interactionType: 'bookmark',
  ),
);

// Track order with rating
context.read<RecommendationBloc>().add(
  TrackInteractionEvent(
    userId: currentUserId,
    itemId: foodItemId,
    interactionType: 'order',
    rating: 4.5,
  ),
);
```

### 5. Contextual Recommendations

Get recommendations based on context (time, location, weather):

```dart
import 'package:makan_mate/features/recommendations/domain/entities/recommendation_entity.dart';

void loadContextualRecommendations() {
  final context = RecommendationContextEntity(
    userId: currentUserId,
    timestamp: DateTime.now(),
    timeOfDay: 'evening',
    weather: 'rainy',
    currentLocation: LocationEntity(
      latitude: 3.1390,
      longitude: 101.6869,
    ),
    occasion: 'casual',
    groupSize: 2,
  );

  this.context.read<RecommendationBloc>().add(
    LoadContextualRecommendationsEvent(
      userId: currentUserId,
      context: context,
      limit: 10,
    ),
  );
}
```

### 6. Similar Items

Show similar items on food detail pages:

```dart
void loadSimilarItems(String foodItemId) {
  context.read<RecommendationBloc>().add(
    LoadSimilarItemsEvent(
      itemId: foodItemId,
      limit: 6,
    ),
  );
}
```

## Testing the Model

Use the `ModelTester` utility to verify your TFLite model:

```dart
import 'package:makan_mate/core/ml/model_tester.dart';

// In your app (e.g., settings page or debug menu)
Future<void> testModel() async {
  final tester = ModelTester();
  final result = await tester.runTests();
  
  showDialog(
    context: context,
    builder: (_) => ModelTestResultsDialog(result: result),
  );
  
  print(result.toString());
}

// Test with real user data
Future<void> testWithUser(String userId) async {
  final tester = ModelTester();
  await tester.generateTestRecommendations(userId);
}
```

## Model Information

### Input Features (35 dimensions)

**User Features (15):**
- Cuisine preferences: Malay, Chinese, Indian, Western, Thai (5)
- Dietary restrictions: Halal, Vegetarian, Vegan (3)
- Spice tolerance (1)
- Price preference (1)
- Cultural background (4)
- Location activity (1)

**Item Features (20):**
- Price, spice level, halal, vegetarian, rating, orders (6)
- Cuisine type one-hot (5)
- Categories (4)
- Popularity metrics (2)
- Time appropriateness (3)

### Output

- Single score (0.0 - 1.0) indicating recommendation strength

## Performance Optimization

### Caching Strategy

The system implements a two-level caching strategy:

1. **Local Cache (Hive)**: Fast access to recent recommendations
2. **Firebase Cache**: Shared across devices

Cache expires after 1 hour, ensuring fresh recommendations while minimizing API calls.

### Best Practices

1. **Lazy Loading**: Load recommendations on-demand
2. **Pagination**: Use `limit` parameter to control batch size
3. **Background Refresh**: Refresh recommendations in background
4. **Error Handling**: Always handle failures gracefully
5. **User Feedback**: Track all interactions for better accuracy

## Analytics

Track recommendation performance:

```dart
import 'package:makan_mate/core/di/injection_container.dart' as di;
import 'package:makan_mate/features/recommendations/domain/repositories/recommendation_repository.dart';

final repository = di.sl<RecommendationRepository>();
final statsResult = await repository.getRecommendationStats(userId: currentUserId);
statsResult.fold(
  (failure) => print('Error: ${failure.message}'),
  (stats) {
    print('Total interactions: ${stats['totalInteractions']}');
    print('Average rating: ${stats['averageRating']}');
  },
);
```

## Troubleshooting

### Model Not Loading

1. Ensure TFLite file is in `assets/ml_models/`
2. Check `pubspec.yaml` includes the asset
3. Verify Firebase Storage has the latest model

### Poor Recommendations

1. Check user has sufficient interaction history
2. Verify user preferences are set correctly
3. Ensure food items have complete data

### Performance Issues

1. Reduce `limit` parameter
2. Implement pagination
3. Use cached recommendations when possible

## Model Updates

To update the TFLite model:

1. Train new model using Python training script
2. Convert to TFLite format
3. Upload to Firebase Storage at `ml_models/recommendation_model.tflite`
4. App will download on next initialization

## Production Checklist

- [ ] Model loaded successfully
- [ ] All tests passing
- [ ] Caching working correctly
- [ ] Error handling implemented
- [ ] User interactions tracked
- [ ] Analytics configured
- [ ] Performance optimized
- [ ] Firebase rules configured
- [ ] Model versioning set up

## Support

For issues or questions, refer to the codebase documentation or contact the development team.


