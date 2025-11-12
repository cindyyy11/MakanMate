import 'package:equatable/equatable.dart';

/// Entity representing a user activity log entry
class ActivityLog extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String action; // e.g., "login", "view_restaurant", "place_order"
  final String? details;
  final DateTime timestamp;
  final String? ipAddress;
  final String? deviceInfo;

  const ActivityLog({
    required this.id,
    required this.userId,
    required this.userName,
    required this.action,
    this.details,
    required this.timestamp,
    this.ipAddress,
    this.deviceInfo,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        action,
        details,
        timestamp,
        ipAddress,
        deviceInfo,
      ];
}

