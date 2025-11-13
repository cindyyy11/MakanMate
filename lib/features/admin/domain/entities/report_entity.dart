import 'package:equatable/equatable.dart';

/// Custom report configuration and results
class Report extends Equatable {
  final String id;
  final String name;
  final ReportType type;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> metrics; // Views, clicks, revenue, etc.
  final ReportFormat format; // PDF, Excel, CSV
  final ReportSchedule? schedule; // Weekly, Monthly, etc.
  final String? emailRecipients; // Comma-separated emails
  final ReportStatus status;
  final String? fileUrl; // Generated report URL
  final DateTime? generatedAt;
  final DateTime createdAt;
  final String createdBy;

  const Report({
    required this.id,
    required this.name,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.metrics,
    required this.format,
    this.schedule,
    this.emailRecipients,
    this.status = ReportStatus.pending,
    this.fileUrl,
    this.generatedAt,
    required this.createdAt,
    required this.createdBy,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        startDate,
        endDate,
        metrics,
        format,
        schedule,
        emailRecipients,
        status,
        fileUrl,
        generatedAt,
        createdAt,
        createdBy,
      ];
}

enum ReportType {
  vendorPerformance,
  userEngagement,
  platformMetrics,
  revenue,
  custom,
}

enum ReportFormat {
  pdf,
  excel,
  csv,
}

enum ReportStatus {
  pending,
  generating,
  completed,
  failed,
}

class ReportSchedule extends Equatable {
  final ScheduleFrequency frequency; // Weekly, Monthly
  final int dayOfWeek; // 0-6 for weekly
  final int dayOfMonth; // 1-31 for monthly
  final String time; // HH:mm format

  const ReportSchedule({
    required this.frequency,
    this.dayOfWeek = 1,
    this.dayOfMonth = 1,
    required this.time,
  });

  @override
  List<Object?> get props => [frequency, dayOfWeek, dayOfMonth, time];
}

enum ScheduleFrequency {
  weekly,
  monthly,
}


