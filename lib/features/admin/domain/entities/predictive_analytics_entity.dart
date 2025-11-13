import 'package:equatable/equatable.dart';

/// Predictive analytics forecasts and insights
class PredictiveAnalytics extends Equatable {
  final String id;
  final UserGrowthForecast? userGrowth;
  final RevenueForecast? revenue;
  final List<AtRiskUser> atRiskUsers;
  final List<Opportunity> opportunities;
  final DateTime generatedAt;
  final int confidenceLevel; // 0-100

  const PredictiveAnalytics({
    required this.id,
    this.userGrowth,
    this.revenue,
    this.atRiskUsers = const [],
    this.opportunities = const [],
    required this.generatedAt,
    this.confidenceLevel = 75,
  });

  @override
  List<Object?> get props => [
        id,
        userGrowth,
        revenue,
        atRiskUsers,
        opportunities,
        generatedAt,
        confidenceLevel,
      ];
}

class UserGrowthForecast extends Equatable {
  final int currentUsers;
  final int forecastedUsers;
  final double growthPercentage;
  final DateTime forecastDate; // Next 7 days
  final List<DailyForecast> dailyForecasts;

  const UserGrowthForecast({
    required this.currentUsers,
    required this.forecastedUsers,
    required this.growthPercentage,
    required this.forecastDate,
    this.dailyForecasts = const [],
  });

  @override
  List<Object?> get props => [
        currentUsers,
        forecastedUsers,
        growthPercentage,
        forecastDate,
        dailyForecasts,
      ];
}

class DailyForecast extends Equatable {
  final DateTime date;
  final int forecastedUsers;
  final double confidence;

  const DailyForecast({
    required this.date,
    required this.forecastedUsers,
    required this.confidence,
  });

  @override
  List<Object?> get props => [date, forecastedUsers, confidence];
}

class RevenueForecast extends Equatable {
  final double currentRevenue;
  final double forecastedRevenue;
  final double growthPercentage;
  final DateTime forecastDate; // Next 30 days
  final String currency;

  const RevenueForecast({
    required this.currentRevenue,
    required this.forecastedRevenue,
    required this.growthPercentage,
    required this.forecastDate,
    this.currency = 'RM',
  });

  @override
  List<Object?> get props => [
        currentRevenue,
        forecastedRevenue,
        growthPercentage,
        forecastDate,
        currency,
      ];
}

class AtRiskUser extends Equatable {
  final String userId;
  final String email;
  final double riskScore; // 0-100
  final List<String> riskFactors;
  final DateTime lastActiveDate;
  final String? recommendedAction;

  const AtRiskUser({
    required this.userId,
    required this.email,
    required this.riskScore,
    this.riskFactors = const [],
    required this.lastActiveDate,
    this.recommendedAction,
  });

  @override
  List<Object?> get props => [
        userId,
        email,
        riskScore,
        riskFactors,
        lastActiveDate,
        recommendedAction,
      ];
}

class Opportunity extends Equatable {
  final String id;
  final String title;
  final String description;
  final OpportunityType type;
  final double potentialImpact; // Estimated impact score
  final String? actionRequired;

  const Opportunity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.potentialImpact,
    this.actionRequired,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        potentialImpact,
        actionRequired,
      ];
}

enum OpportunityType {
  vendorRecruitment,
  featureEnhancement,
  marketingCampaign,
  seasonalTrend,
  userRetention,
}


