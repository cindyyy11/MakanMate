import 'package:equatable/equatable.dart';

/// Backup and restore configuration
class BackupInfo extends Equatable {
  final String id;
  final DateTime lastBackup;
  final double backupSizeGB;
  final BackupStatus status;
  final String? backupUrl;
  final BackupType type;
  final DateTime? verifiedAt;
  final String? verifiedBy;

  const BackupInfo({
    required this.id,
    required this.lastBackup,
    required this.backupSizeGB,
    required this.status,
    this.backupUrl,
    required this.type,
    this.verifiedAt,
    this.verifiedBy,
  });

  @override
  List<Object?> get props => [
        id,
        lastBackup,
        backupSizeGB,
        status,
        backupUrl,
        type,
        verifiedAt,
        verifiedBy,
      ];
}

enum BackupStatus {
  healthy,
  warning,
  error,
  inProgress,
}

enum BackupType {
  automatic,
  manual,
  scheduled,
}


