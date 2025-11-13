import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/entities/system_metrics_entity.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_repository.dart';

/// Use case for streaming real-time system metrics
class StreamSystemMetricsUseCase {
  final AdminRepository repository;

  StreamSystemMetricsUseCase(this.repository);

  Stream<Either<Failure, SystemMetrics>> call() {
    return repository.streamSystemMetrics();
  }
}

