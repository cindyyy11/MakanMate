import 'package:equatable/equatable.dart';

/// Entity representing an admin notification/alert
class AdminNotification extends Equatable {
  final String id;
  final String type; // "critical", "warning", "info"
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? actionUrl; // Optional link to related page

  const AdminNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.actionUrl,
  });

  bool get isCritical => type == 'critical';
  bool get isWarning => type == 'warning';

  @override
  List<Object?> get props => [
    id,
    type,
    title,
    message,
    timestamp,
    isRead,
    actionUrl,
  ];

  AdminNotification copyWith({
    String? id,
    String? type,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? actionUrl,
  }) {
    return AdminNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }
}
