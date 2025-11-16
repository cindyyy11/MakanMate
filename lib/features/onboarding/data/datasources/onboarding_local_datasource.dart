import 'package:shared_preferences/shared_preferences.dart';
import 'package:makan_mate/features/onboarding/domain/entities/onboarding_page_entity.dart';

/// Local data source for onboarding data
abstract class OnboardingLocalDataSource {
  List<OnboardingPageEntity> getOnboardingPages();
  Future<void> completeOnboarding();
  Future<bool> hasCompletedOnboarding();
}

/// Implementation of onboarding local data source
class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _onboardingCompleteKey = 'onboarding_complete';

  OnboardingLocalDataSourceImpl({required this.sharedPreferences});

  @override
  List<OnboardingPageEntity> getOnboardingPages() {
    return [
      const OnboardingPageEntity(
        title: 'AI-Powered Recommendations',
        description:
            'Get personalized food recommendations powered by advanced machine learning. Our AI understands your taste and suggests the perfect meal every time.',
        lottieAsset: 'assets/lottie/ai_recommendation.json',
        iconEmoji: '🤖',
        features: [
          'Smart ML-based matching',
          'Personalized suggestions',
          'Learns your preferences',
        ],
      ),
      const OnboardingPageEntity(
        title: 'Discover & Explore',
        description:
            'Find restaurants on interactive maps, search with filters, bookmark favorites, and explore diverse cuisines near you.',
        lottieAsset: 'assets/lottie/map_search.json',
        iconEmoji: '🗺️',
        features: [
          'Interactive map view',
          'Advanced search filters',
          'Bookmark your favorites',
        ],
      ),
      const OnboardingPageEntity(
        title: 'Reviews & Ratings',
        description:
            'Share your dining experiences, rate dishes, write detailed reviews, and help the community discover great food.',
        lottieAsset: 'assets/lottie/reviews_ratings.json',
        iconEmoji: '⭐',
        features: [
          'Rate restaurants & dishes',
          'Write detailed reviews',
          'Help the community',
        ],
      ),
      const OnboardingPageEntity(
        title: 'Your Food Journey',
        description:
            'Manage your profile, track your dining history, access vendor promotions, and enjoy a personalized food discovery experience.',
        lottieAsset: 'assets/lottie/user_profile.json',
        iconEmoji: '👤',
        features: [
          'Personal food profile',
          'Dining history tracking',
          'Exclusive promotions',
        ],
      ),
    ];
  }

  @override
  Future<void> completeOnboarding() async {
    await sharedPreferences.setBool(_onboardingCompleteKey, true);
  }

  @override
  Future<bool> hasCompletedOnboarding() async {
    return sharedPreferences.getBool(_onboardingCompleteKey) ?? false;
  }
}

