import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/exceptions.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/core/network/network_info.dart';
import 'package:makan_mate/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:makan_mate/features/admin/domain/entities/activity_log_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/admin_notification_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/metric_trend_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/platform_metrics_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/system_metrics_entity.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Implementation of admin repository
class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AdminRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, PlatformMetrics>> getPlatformMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final metrics = await remoteDataSource.getPlatformMetrics(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(metrics.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch platform metrics: $e'));
    }
  }

  @override
  Future<Either<Failure, MetricTrend>> getMetricTrend({
    required String metricName,
    required int days,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final trend = await remoteDataSource.getMetricTrend(
        metricName: metricName,
        days: days,
      );
      return Right(trend.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch metric trend: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ActivityLog>>> getActivityLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
    int? limit,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final logs = await remoteDataSource.getActivityLogs(
        startDate: startDate,
        endDate: endDate,
        userId: userId,
        limit: limit,
      );
      return Right(logs.map((log) => log.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch activity logs: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AdminNotification>>> getNotifications({
    bool? unreadOnly,
    int? limit,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final notifications = await remoteDataSource.getNotifications(
        unreadOnly: unreadOnly,
        limit: limit,
      );
      return Right(notifications.map((n) => n.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markNotificationAsRead(
    String notificationId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.markNotificationAsRead(notificationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to mark notification as read: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> exportMetricsToCSV({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final csvContent = await remoteDataSource.exportMetricsToCSV(
        startDate: startDate,
        endDate: endDate,
      );

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/metrics_export_${DateTime.now().millisecondsSinceEpoch}.csv',
      );
      await file.writeAsString(csvContent);

      return Right(file.path);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to export CSV: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> exportMetricsToPDF({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final metrics = await remoteDataSource.getPlatformMetrics(
        startDate: startDate,
        endDate: endDate,
      );

      // Create PDF document
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'MakanMate Platform Metrics Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Generated: ${DateTime.now().toString()}',
                style: pw.TextStyle(fontSize: 10),
              ),
              if (startDate != null || endDate != null)
                pw.Text(
                  'Date Range: ${startDate?.toString().split(' ')[0] ?? 'N/A'} to ${endDate?.toString().split(' ')[0] ?? 'N/A'}',
                  style: pw.TextStyle(fontSize: 10),
                ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Metric',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Value',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  _buildTableRow('Total Users', metrics.totalUsers.toString()),
                  _buildTableRow(
                    'Total Vendors',
                    metrics.totalVendors.toString(),
                  ),
                  _buildTableRow(
                    'Active Vendors',
                    metrics.activeVendors.toString(),
                  ),
                  _buildTableRow(
                    'Pending Applications',
                    metrics.pendingApplications.toString(),
                  ),
                  _buildTableRow(
                    'Flagged Reviews',
                    metrics.flaggedReviews.toString(),
                  ),
                  _buildTableRow(
                    'Average Rating',
                    metrics.averagePlatformRating.toStringAsFixed(2),
                  ),
                  _buildTableRow(
                    'Today\'s Active Users',
                    metrics.todaysActiveUsers.toString(),
                  ),
                  _buildTableRow(
                    'Total Restaurants',
                    metrics.totalRestaurants.toString(),
                  ),
                  _buildTableRow(
                    'Total Food Items',
                    metrics.totalFoodItems.toString(),
                  ),
                ],
              ),
            ];
          },
        ),
      );

      // Save PDF to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/metrics_export_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(await pdf.save());

      return Right(file.path);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to export PDF: $e'));
    }
  }

  pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(label)),
        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(value)),
      ],
    );
  }

  @override
  Stream<Either<Failure, SystemMetrics>> streamSystemMetrics() {
    try {
      return remoteDataSource
          .streamSystemMetrics()
          .map((model) => Right<Failure, SystemMetrics>(model.toEntity()))
          .handleError((error) {
            return Left<Failure, SystemMetrics>(
              ServerFailure('Failed to stream system metrics: $error'),
            );
          });
    } catch (e) {
      return Stream.value(
        Left<Failure, SystemMetrics>(
          ServerFailure('Failed to stream system metrics: $e'),
        ),
      );
    }
  }
}
