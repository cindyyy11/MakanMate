import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/features/admin/domain/entities/support_ticket_entity.dart';

class SupportTicketModel {
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

  const SupportTicketModel({
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

  factory SupportTicketModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    DateTime _ts(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }

    return SupportTicketModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown',
      userEmail: data['userEmail'],
      userProfileImageUrl: data['userProfileImageUrl'],
      subject: data['subject'] ?? '',
      message: data['message'] ?? '',
      category: data['category'] ?? 'other',
      status: data['status'] ?? 'open',
      priority: data['priority'] ?? 'low',
      createdAt: _ts(data['createdAt']),
      resolvedAt: data['resolvedAt'] != null ? _ts(data['resolvedAt']) : null,
      assignedAdminId: data['assignedAdminId'],
      assignedAdminName: data['assignedAdminName'],
      response: data['response'],
      attachments: (data['attachments'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  SupportTicketEntity toEntity() {
    return SupportTicketEntity(
      id: id,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userProfileImageUrl: userProfileImageUrl,
      subject: subject,
      message: message,
      category: category,
      status: status,
      priority: priority,
      createdAt: createdAt,
      resolvedAt: resolvedAt,
      assignedAdminId: assignedAdminId,
      assignedAdminName: assignedAdminName,
      response: response,
      attachments: attachments,
    );
  }
}



