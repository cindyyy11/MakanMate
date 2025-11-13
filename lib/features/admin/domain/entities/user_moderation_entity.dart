import 'package:equatable/equatable.dart';

/// User account verification
class UserVerification extends Equatable {
  final String userId;
  final String email;
  final bool isPhoneVerified;
  final VerificationRisk riskLevel;
  final List<String> riskFactors;
  final VerificationStatus status;
  final DateTime? verifiedAt;
  final String? verifiedBy;

  const UserVerification({
    required this.userId,
    required this.email,
    this.isPhoneVerified = false,
    this.riskLevel = VerificationRisk.low,
    this.riskFactors = const [],
    this.status = VerificationStatus.pending,
    this.verifiedAt,
    this.verifiedBy,
  });

  @override
  List<Object?> get props => [
        userId,
        email,
        isPhoneVerified,
        riskLevel,
        riskFactors,
        status,
        verifiedAt,
        verifiedBy,
      ];
}

enum VerificationRisk {
  low,
  medium,
  high,
}

enum VerificationStatus {
  pending,
  verified,
  rejected,
  requiresVerification,
}

/// Review moderation
class ReviewModeration extends Equatable {
  final String reviewId;
  final String userId;
  final String vendorId;
  final String reviewText;
  final double toxicityScore; // 0-1
  final double sentimentScore; // -1 to 1
  final ModerationStatus status;
  final String? moderationReason;
  final DateTime flaggedAt;
  final DateTime? moderatedAt;
  final String? moderatedBy;

  const ReviewModeration({
    required this.reviewId,
    required this.userId,
    required this.vendorId,
    required this.reviewText,
    required this.toxicityScore,
    required this.sentimentScore,
    this.status = ModerationStatus.pending,
    this.moderationReason,
    required this.flaggedAt,
    this.moderatedAt,
    this.moderatedBy,
  });

  @override
  List<Object?> get props => [
        reviewId,
        userId,
        vendorId,
        reviewText,
        toxicityScore,
        sentimentScore,
        status,
        moderationReason,
        flaggedAt,
        moderatedAt,
        moderatedBy,
      ];
}

enum ModerationStatus {
  pending,
  approved,
  removed,
  warned,
}

/// User ban
class UserBan extends Equatable {
  final String userId;
  final BanType banType;
  final DateTime? bannedUntil;
  final String reason;
  final DateTime bannedAt;
  final String bannedBy;
  final bool isPermanent;

  const UserBan({
    required this.userId,
    required this.banType,
    this.bannedUntil,
    required this.reason,
    required this.bannedAt,
    required this.bannedBy,
    this.isPermanent = false,
  });

  @override
  List<Object?> get props => [
        userId,
        banType,
        bannedUntil,
        reason,
        bannedAt,
        bannedBy,
        isPermanent,
      ];
}

enum BanType {
  temporary,
  permanent,
}

/// User warning
class UserWarning extends Equatable {
  final String id;
  final String userId;
  final int warningLevel; // 1-3
  final String reason;
  final String message;
  final DateTime issuedAt;
  final String issuedBy;

  const UserWarning({
    required this.id,
    required this.userId,
    required this.warningLevel,
    required this.reason,
    required this.message,
    required this.issuedAt,
    required this.issuedBy,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        warningLevel,
        reason,
        message,
        issuedAt,
        issuedBy,
      ];
}

/// User violation history
class UserViolationHistory extends Equatable {
  final String userId;
  final List<Violation> violations;
  final int totalWarnings;
  final int totalBans;
  final int totalRemovedContent;
  final DateTime? lastViolationDate;

  const UserViolationHistory({
    required this.userId,
    this.violations = const [],
    this.totalWarnings = 0,
    this.totalBans = 0,
    this.totalRemovedContent = 0,
    this.lastViolationDate,
  });

  @override
  List<Object?> get props => [
        userId,
        violations,
        totalWarnings,
        totalBans,
        totalRemovedContent,
        lastViolationDate,
      ];
}

class Violation extends Equatable {
  final String id;
  final ViolationType type;
  final String description;
  final DateTime date;
  final String? actionTaken; // Warning, Ban, Content Removed

  const Violation({
    required this.id,
    required this.type,
    required this.description,
    required this.date,
    this.actionTaken,
  });

  @override
  List<Object?> get props => [id, type, description, date, actionTaken];
}

enum ViolationType {
  toxicReview,
  inappropriatePhoto,
  spam,
  fakeReview,
  harassment,
  other,
}

/// Fake review detection
class FakeReviewDetection extends Equatable {
  final String reviewId;
  final String userId;
  final String vendorId;
  final bool hasOrderHistory;
  final double suspiciousScore; // 0-1
  final List<String> suspiciousFactors;
  final bool isLikelyFake;
  final double confidence; // 0-1
  final DateTime detectedAt;

  const FakeReviewDetection({
    required this.reviewId,
    required this.userId,
    required this.vendorId,
    this.hasOrderHistory = false,
    required this.suspiciousScore,
    this.suspiciousFactors = const [],
    this.isLikelyFake = false,
    required this.confidence,
    required this.detectedAt,
  });

  @override
  List<Object?> get props => [
        reviewId,
        userId,
        vendorId,
        hasOrderHistory,
        suspiciousScore,
        suspiciousFactors,
        isLikelyFake,
        confidence,
        detectedAt,
      ];
}

/// User data export (PDPA)
class UserDataExport extends Equatable {
  final String userId;
  final String requestId;
  final ExportStatus status;
  final String? fileUrl;
  final DateTime requestedAt;
  final DateTime? generatedAt;
  final DateTime? expiresAt;

  const UserDataExport({
    required this.userId,
    required this.requestId,
    this.status = ExportStatus.pending,
    this.fileUrl,
    required this.requestedAt,
    this.generatedAt,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [
        userId,
        requestId,
        status,
        fileUrl,
        requestedAt,
        generatedAt,
        expiresAt,
      ];
}

enum ExportStatus {
  pending,
  generating,
  completed,
  expired,
  failed,
}

/// User engagement analytics
class UserEngagementAnalytics extends Equatable {
  final int dau; // Daily Active Users
  final int mau; // Monthly Active Users
  final double d1Retention; // Day 1 retention percentage
  final double d7Retention; // Day 7 retention percentage
  final double avgSessionDuration; // minutes
  final Map<String, double> featureUsage; // Feature -> usage percentage
  final List<String> topFeatures;
  final int atRiskUsers;
  final int powerUsers;
  final int churnedUsers; // Not active >30 days
  final DateTime generatedAt;

  const UserEngagementAnalytics({
    required this.dau,
    required this.mau,
    required this.d1Retention,
    required this.d7Retention,
    required this.avgSessionDuration,
    this.featureUsage = const {},
    this.topFeatures = const [],
    this.atRiskUsers = 0,
    this.powerUsers = 0,
    this.churnedUsers = 0,
    required this.generatedAt,
  });

  @override
  List<Object?> get props => [
        dau,
        mau,
        d1Retention,
        d7Retention,
        avgSessionDuration,
        featureUsage,
        topFeatures,
        atRiskUsers,
        powerUsers,
        churnedUsers,
        generatedAt,
      ];
}

/// Support ticket
class SupportTicket extends Equatable {
  final String id;
  final String userId;
  final String userEmail;
  final TicketPriority priority;
  final String issue;
  final TicketStatus status;
  final List<TicketMessage> messages;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? assignedTo;

  const SupportTicket({
    required this.id,
    required this.userId,
    required this.userEmail,
    this.priority = TicketPriority.medium,
    required this.issue,
    this.status = TicketStatus.open,
    this.messages = const [],
    required this.createdAt,
    this.resolvedAt,
    this.assignedTo,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        userEmail,
        priority,
        issue,
        status,
        messages,
        createdAt,
        resolvedAt,
        assignedTo,
      ];
}

enum TicketPriority {
  low,
  medium,
  high,
  urgent,
}

enum TicketStatus {
  open,
  inProgress,
  resolved,
  closed,
}

class TicketMessage extends Equatable {
  final String id;
  final String message;
  final bool isFromAdmin;
  final String senderId;
  final DateTime sentAt;

  const TicketMessage({
    required this.id,
    required this.message,
    required this.isFromAdmin,
    required this.senderId,
    required this.sentAt,
  });

  @override
  List<Object?> get props => [
        id,
        message,
        isFromAdmin,
        senderId,
        sentAt,
      ];
}

/// Dispute resolution
class Dispute extends Equatable {
  final String id;
  final String vendorId;
  final String userId;
  final String reviewId;
  final String vendorClaim;
  final String userClaim;
  final DisputeStatus status;
  final String? resolution;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;

  const Dispute({
    required this.id,
    required this.vendorId,
    required this.userId,
    required this.reviewId,
    required this.vendorClaim,
    required this.userClaim,
    this.status = DisputeStatus.pending,
    this.resolution,
    required this.createdAt,
    this.resolvedAt,
    this.resolvedBy,
  });

  @override
  List<Object?> get props => [
        id,
        vendorId,
        userId,
        reviewId,
        vendorClaim,
        userClaim,
        status,
        resolution,
        createdAt,
        resolvedAt,
        resolvedBy,
      ];
}

enum DisputeStatus {
  pending,
  investigating,
  resolved,
  closed,
}

/// User behavior heatmap
class UserBehaviorHeatmap extends Equatable {
  final String id;
  final Map<String, double> featureUsage; // Feature -> usage percentage
  final List<String> mostUsedFeatures;
  final List<String> underusedFeatures;
  final List<String> bottlenecks;
  final DateTime generatedAt;

  const UserBehaviorHeatmap({
    required this.id,
    this.featureUsage = const {},
    this.mostUsedFeatures = const [],
    this.underusedFeatures = const [],
    this.bottlenecks = const [],
    required this.generatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        featureUsage,
        mostUsedFeatures,
        underusedFeatures,
        bottlenecks,
        generatedAt,
      ];
}


