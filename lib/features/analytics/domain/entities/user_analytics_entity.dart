class UserAnalytics {
  final int totalUsers;
  final int activeUsers;
  final int newUsersToday;
  final int verifiedUsers;
  final Map<String, int> usersByRole;
  final Map<String, int> userGrowthWeekly; // e.g., {'Mon': 12, ...}

  const UserAnalytics({
    required this.totalUsers,
    required this.activeUsers,
    required this.newUsersToday,
    required this.verifiedUsers,
    required this.usersByRole,
    required this.userGrowthWeekly,
  });
}





