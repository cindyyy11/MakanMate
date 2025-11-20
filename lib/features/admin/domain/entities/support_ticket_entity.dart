import 'package:equatable/equatable.dart';

/// Entity representing a support ticket
class SupportTicketEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? userEmail;
  final String? userProfileImageUrl;
  final String subject;
  final String message;
  final String category; // 'technical', 'billing', 'account', 'other'
  final String status; // 'open', 'in_progress', 'resolved', 'closed'
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? assignedAdminId;
  final String? assignedAdminName;
  final String? response;
  final List<String>? attachments;
  
  const SupportTicketEntity({
    required this.id,
    required this.userId,
    required this.userName,
    this.userEmail,
    this.userProfileImageUrl,
    required this.subject,
    required this.message,
    required this.category,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.resolvedAt,
    this.assignedAdminId,
    this.assignedAdminName,
    this.response,
    this.attachments,
  });
  
  bool get isOpen => status == 'open';
  bool get isInProgress => status == 'in_progress';
  bool get isResolved => status == 'resolved';
  bool get isClosed => status == 'closed';
  bool get isAssigned => assignedAdminId != null;
  
  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    userEmail,
    userProfileImageUrl,
    subject,
    message,
    category,
    status,
    priority,
    createdAt,
    resolvedAt,
    assignedAdminId,
    assignedAdminName,
    response,
    attachments,
  ];
}






