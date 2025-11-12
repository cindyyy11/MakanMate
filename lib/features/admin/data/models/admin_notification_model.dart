import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/features/admin/domain/entities/admin_notification_entity.dart';

/// Data model for admin notification
class AdminNotificationModel extends AdminNotification {
  const AdminNotificationModel({
    required super.id,
    required super.type,
    required super.title,
    required super.message,
    required super.timestamp,
    super.isRead,
    super.actionUrl,
  });

  factory AdminNotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminNotificationModel(
      id: doc.id,
      type: data['type'] as String? ?? 'info',
      title: data['title'] as String? ?? '',
      message: data['message'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
      actionUrl: data['actionUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'actionUrl': actionUrl,
    };
  }

  AdminNotification toEntity() {
    return AdminNotification(
      id: id,
      type: type,
      title: title,
      message: message,
      timestamp: timestamp,
      isRead: isRead,
      actionUrl: actionUrl,
    );
  }
}

