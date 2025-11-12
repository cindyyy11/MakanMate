import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/features/admin/domain/entities/activity_log_entity.dart';

/// Data model for activity log
class ActivityLogModel extends ActivityLog {
  const ActivityLogModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.action,
    super.details,
    required super.timestamp,
    super.ipAddress,
    super.deviceInfo,
  });

  factory ActivityLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityLogModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Unknown',
      action: data['action'] as String? ?? '',
      details: data['details'] as String?,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ipAddress: data['ipAddress'] as String?,
      deviceInfo: data['deviceInfo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'action': action,
      'details': details,
      'timestamp': Timestamp.fromDate(timestamp),
      'ipAddress': ipAddress,
      'deviceInfo': deviceInfo,
    };
  }

  ActivityLog toEntity() {
    return ActivityLog(
      id: id,
      userId: userId,
      userName: userName,
      action: action,
      details: details,
      timestamp: timestamp,
      ipAddress: ipAddress,
      deviceInfo: deviceInfo,
    );
  }
}

