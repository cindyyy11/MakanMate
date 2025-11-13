import 'package:equatable/equatable.dart';

/// Audit log entry - immutable history of admin actions
class AuditLog extends Equatable {
  final String id;
  final String adminId;
  final String adminEmail;
  final String actionType; // approve_vendor, remove_review, etc.
  final String entityType; // vendor, review, user, etc.
  final String entityId;
  final Map<String, dynamic> changes; // Before/after state
  final String? reason;
  final String? notes;
  final DateTime timestamp;
  final String? ipAddress;
  final Map<String, dynamic> metadata;

  const AuditLog({
    required this.id,
    required this.adminId,
    required this.adminEmail,
    required this.actionType,
    required this.entityType,
    required this.entityId,
    this.changes = const {},
    this.reason,
    this.notes,
    required this.timestamp,
    this.ipAddress,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
    id,
    adminId,
    adminEmail,
    actionType,
    entityType,
    entityId,
    changes,
    reason,
    notes,
    timestamp,
    ipAddress,
    metadata,
  ];
}

