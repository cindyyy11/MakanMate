import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for splash screen data
abstract class SplashLocalDataSource {
  Future<bool> hasCompletedOnboarding();
  Future<void> setOnboardingComplete();
}

/// Implementation of splash local data source using SharedPreferences
class SplashLocalDataSourceImpl implements SplashLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _onboardingCompleteKey = 'onboarding_complete';

  SplashLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<bool> hasCompletedOnboarding() async {
    return sharedPreferences.getBool(_onboardingCompleteKey) ?? false;
  }

  @override
  Future<void> setOnboardingComplete() async {
    await sharedPreferences.setBool(_onboardingCompleteKey, true);
  }
}

