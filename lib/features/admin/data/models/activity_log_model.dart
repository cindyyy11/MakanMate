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
    
    // Support both audit_logs and activity_logs formats
    final adminId = data['adminId'] as String? ?? data['userId'] as String? ?? '';
    final adminEmail = data['adminEmail'] as String? ?? '';
    final userName = data['userName'] as String? ?? adminEmail.split('@').first;
    
    // Build action description from audit log format
    final action = data['action'] as String? ?? '';
    final entityType = data['entityType'] as String? ?? '';
    final entityId = data['entityId'] as String? ?? '';
    final details = data['details'] as Map<String, dynamic>?;
    final reason = data['reason'] as String?;
    
    // Format action string for display
    String actionDescription = action;
    if (entityType.isNotEmpty && entityId.isNotEmpty) {
      actionDescription = '$action on $entityType $entityId';
    }
    if (reason != null && reason.isNotEmpty) {
      actionDescription += ': $reason';
    }
    
    return ActivityLogModel(
      id: doc.id,
      userId: adminId,
      userName: userName.isNotEmpty ? userName : 'Unknown',
      action: actionDescription,
      details: reason ?? (details != null ? details.toString() : null),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ipAddress: data['ipAddress'] as String?,
      deviceInfo: data['userAgent'] as String? ?? data['deviceInfo'] as String?,
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

