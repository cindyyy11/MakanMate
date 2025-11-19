import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:makan_mate/features/admin/domain/entities/activity_log_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/admin_notification_entity.dart';
import 'package:makan_mate/features/admin/domain/entities/metric_trend_entity.dart';
import 'package:makan_mate/features/admin/domain/usecases/export_metrics_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_activity_logs_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_metric_trend_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_notifications_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_platform_metrics_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_fairness_metrics_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_seasonal_trends_usecase.dart';
import 'package:makan_mate/features/admin/domain/usecases/get_data_quality_metrics_usecase.dart';
import 'package:makan_mate/features/admin/domain/repositories/admin_repository.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_event.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_state.dart';

/// BLoC for managing admin dashboard state
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetPlatformMetricsUseCase getPlatformMetrics;
  final GetMetricTrendUseCase getMetricTrend;
  final GetActivityLogsUseCase getActivityLogs;
  final GetNotificationsUseCase getNotifications;
  final ExportMetricsUseCase exportMetrics;
  final GetFairnessMetricsUseCase getFairnessMetrics;
  final GetSeasonalTrendsUseCase getSeasonalTrends;
  final GetDataQualityMetricsUseCase getDataQualityMetrics;
  final AdminRepository adminRepository;
  final Logger logger;

  AdminBloc({
    required this.getPlatformMetrics,
    required this.getMetricTrend,
    required this.getActivityLogs,
    required this.getNotifications,
    required this.exportMetrics,
    required this.getFairnessMetrics,
    required this.getSeasonalTrends,
    required this.getDataQualityMetrics,
    required this.adminRepository,
    required this.logger,
  }) : super(const AdminInitial()) {
    on<LoadPlatformMetrics>(_onLoadPlatformMetrics);
    on<RefreshPlatformMetrics>(_onRefreshPlatformMetrics);
    on<LoadMetricTrend>(_onLoadMetricTrend);
    on<LoadActivityLogs>(_onLoadActivityLogs);
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<ExportMetrics>(_onExportMetrics);
    on<LoadFairnessMetrics>(_onLoadFairnessMetrics);
    on<RefreshFairnessMetrics>(_onRefreshFairnessMetrics);
    on<LoadSeasonalTrends>(_onLoadSeasonalTrends);
    on<RefreshSeasonalTrends>(_onRefreshSeasonalTrends);
    on<LoadDataQualityMetrics>(_onLoadDataQualityMetrics);
    on<RefreshDataQualityMetrics>(_onRefreshDataQualityMetrics);
  }

  @override
  Future<void> close() {
    return super.close();
  }

  Future<void> _onLoadPlatformMetrics(
    LoadPlatformMetrics event,
    Emitter<AdminState> emit,
  ) async {
    try {
      logger.i('Loading platform metrics');
      emit(const AdminLoading());

      final result = await getPlatformMetrics(
        GetPlatformMetricsParams(
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );

      await result.fold(
        (failure) async {
          logger.e('Failed to load metrics: ${failure.message}');
          emit(AdminError(failure.message));
        },
        (metrics) async {
          logger.i('Successfully loaded platform metrics');

          // Load additional data in parallel
          final trendResults = await Future.wait([
            getMetricTrend(
              GetMetricTrendParams(metricName: 'totalUsers', days: 7),
            ),
            getMetricTrend(
              GetMetricTrendParams(metricName: 'totalVendors', days: 7),
            ),
            getActivityLogs(GetActivityLogsParams(limit: 50)),
            getNotifications(
              GetNotificationsParams(unreadOnly: true, limit: 10),
            ),
          ]);

          MetricTrend? userTrend;
          MetricTrend? vendorTrend;
          List<ActivityLog>? activityLogs;
          List<AdminNotification>? notifications;

          trendResults[0].fold(
            (_) {},
            (trend) => userTrend = trend as MetricTrend,
          );
          trendResults[1].fold(
            (_) {},
            (trend) => vendorTrend = trend as MetricTrend,
          );
          trendResults[2].fold(
            (_) {},
            (logs) => activityLogs = logs as List<ActivityLog>,
          );
          trendResults[3].fold(
            (_) {},
            (notifs) => notifications = notifs as List<AdminNotification>,
          );

          if (!emit.isDone) {
            emit(
              AdminLoaded(
                metrics,
                userTrend: userTrend,
                vendorTrend: vendorTrend,
                activityLogs: activityLogs,
                notifications: notifications,
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error loading platform metrics: $e', stackTrace: stackTrace);
      emit(AdminError('Unexpected error: $e'));
    }
  }

  Future<void> _onRefreshPlatformMetrics(
    RefreshPlatformMetrics event,
    Emitter<AdminState> emit,
  ) async {
    try {
      logger.i('Refreshing platform metrics');

      // Keep current metrics visible while refreshing
      if (state is AdminLoaded) {
        final currentMetrics = (state as AdminLoaded).metrics;
        emit(AdminRefreshing(currentMetrics));
      } else {
        emit(const AdminLoading());
      }

      final result = await getPlatformMetrics(
        GetPlatformMetricsParams(
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );

      await result.fold(
        (failure) async {
          logger.e('Failed to refresh metrics: ${failure.message}');
          // If we had cached metrics, show error with cache
          if (state is AdminRefreshing) {
            final cachedMetrics = (state as AdminRefreshing).metrics;
            if (!emit.isDone) {
              emit(
                AdminError(
                  'Failed to refresh: ${failure.message}',
                  cachedMetrics: cachedMetrics,
                ),
              );
            }
          } else {
            if (!emit.isDone) {
              emit(AdminError(failure.message));
            }
          }
        },
        (metrics) async {
          logger.i('Successfully refreshed platform metrics');

          // Keep existing trends/logs if available
          final currentState = state is AdminLoaded
              ? state as AdminLoaded
              : null;

          if (!emit.isDone) {
            emit(
              AdminLoaded(
                metrics,
                userTrend: currentState?.userTrend,
                vendorTrend: currentState?.vendorTrend,
                activityLogs: currentState?.activityLogs,
                notifications: currentState?.notifications,
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error refreshing platform metrics: $e', stackTrace: stackTrace);
      emit(AdminError('Unexpected error: $e'));
    }
  }

  Future<void> _onLoadMetricTrend(
    LoadMetricTrend event,
    Emitter<AdminState> emit,
  ) async {
    try {
      logger.i('Loading metric trend: ${event.metricName}');

      final result = await getMetricTrend(
        GetMetricTrendParams(metricName: event.metricName, days: event.days),
      );

      result.fold(
        (failure) {
          logger.e('Failed to load trend: ${failure.message}');
        },
        (trend) {
          logger.i('Successfully loaded metric trend');
          if (state is AdminLoaded) {
            final currentState = state as AdminLoaded;
            emit(
              AdminLoaded(
                currentState.metrics,
                userTrend: event.metricName == 'totalUsers'
                    ? trend
                    : currentState.userTrend,
                vendorTrend: event.metricName == 'totalVendors'
                    ? trend
                    : currentState.vendorTrend,
                activityLogs: currentState.activityLogs,
                notifications: currentState.notifications,
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error loading metric trend: $e', stackTrace: stackTrace);
    }
  }

  Future<void> _onLoadActivityLogs(
    LoadActivityLogs event,
    Emitter<AdminState> emit,
  ) async {
    try {
      logger.i('Loading activity logs');

      final result = await getActivityLogs(
        GetActivityLogsParams(
          startDate: event.startDate,
          endDate: event.endDate,
          userId: event.userId,
          limit: event.limit,
        ),
      );

      result.fold(
        (failure) {
          logger.e('Failed to load activity logs: ${failure.message}');
        },
        (logs) {
          logger.i('Successfully loaded ${logs.length} activity logs');
          if (state is AdminLoaded) {
            final currentState = state as AdminLoaded;
            emit(
              AdminLoaded(
                currentState.metrics,
                userTrend: currentState.userTrend,
                vendorTrend: currentState.vendorTrend,
                activityLogs: logs,
                notifications: currentState.notifications,
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error loading activity logs: $e', stackTrace: stackTrace);
    }
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<AdminState> emit,
  ) async {
    try {
      logger.i('Loading notifications');

      final result = await getNotifications(
        GetNotificationsParams(
          unreadOnly: event.unreadOnly,
          limit: event.limit,
        ),
      );

      result.fold(
        (failure) {
          logger.e('Failed to load notifications: ${failure.message}');
        },
        (notifications) {
          logger.i('Successfully loaded ${notifications.length} notifications');
          if (state is AdminLoaded) {
            final currentState = state as AdminLoaded;
            emit(
              AdminLoaded(
                currentState.metrics,
                userTrend: currentState.userTrend,
                vendorTrend: currentState.vendorTrend,
                activityLogs: currentState.activityLogs,
                notifications: notifications,
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error loading notifications: $e', stackTrace: stackTrace);
    }
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<AdminState> emit,
  ) async {
    try {
      logger.i('Marking notification as read: ${event.notificationId}');

      final result = await adminRepository.markNotificationAsRead(
        event.notificationId,
      );

      result.fold(
        (failure) {
          logger.e('Failed to mark notification as read: ${failure.message}');
        },
        (_) {
          logger.i('Successfully marked notification as read');
          // Reload notifications to update state
          add(const LoadNotifications(unreadOnly: true, limit: 10));
        },
      );
    } catch (e, stackTrace) {
      logger.e(
        'Error marking notification as read: $e',
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _onExportMetrics(
    ExportMetrics event,
    Emitter<AdminState> emit,
  ) async {
    try {
      logger.i('Exporting metrics to ${event.format}');
      emit(AdminExporting(event.format));

      final result = await exportMetrics(
        ExportMetricsParams(
          format: event.format,
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );

      result.fold(
        (failure) {
          logger.e('Failed to export: ${failure.message}');
          emit(AdminError('Export failed: ${failure.message}'));
        },
        (filePath) {
          logger.i('Successfully exported to: $filePath');
          // Store current state before emitting export success
          final previousState = state is AdminLoaded
              ? state as AdminLoaded
              : null;
          if (!emit.isDone) {
            emit(AdminExportSuccess(filePath, event.format));
            // Return to loaded state after a moment
            Future.delayed(const Duration(seconds: 2), () {
              if (previousState != null && !emit.isDone) {
                emit(previousState);
              }
            });
          }
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error exporting metrics: $e', stackTrace: stackTrace);
      emit(AdminError('Export failed: $e'));
    }
  }

  Future<void> _onLoadFairnessMetrics(
    LoadFairnessMetrics event,
    Emitter<AdminState> emit,
  ) async {
    try {
      logger.i('Loading fairness metrics');

      final result = await getFairnessMetrics(
        GetFairnessMetricsParams(
          recommendationLimit: event.recommendationLimit,
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );

      result.fold(
        (failure) {
          logger.e('Failed to load fairness metrics: ${failure.message}');
        },
        (metrics) {
          logger.i('Successfully loaded fairness metrics');
          if (state is AdminLoaded) {
            final currentState = state as AdminLoaded;
            emit(
              AdminLoaded(
                currentState.metrics,
                userTrend: currentState.userTrend,
                vendorTrend: currentState.vendorTrend,
                activityLogs: currentState.activityLogs,
                notifications: currentState.notifications,
                systemMetrics: currentState.systemMetrics,
                fairnessMetrics: metrics,
              ),
            );
          } else {
            // If no loaded state, create one with just fairness metrics
            // This shouldn't happen normally, but handle gracefully
            logger.w('Loading fairness metrics without existing loaded state');
          }
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error loading fairness metrics: $e', stackTrace: stackTrace);
    }
  }

  Future<void> _onRefreshFairnessMetrics(
    RefreshFairnessMetrics event,
    Emitter<AdminState> emit,
  ) async {
    try {
      logger.i('Refreshing fairness metrics');

      final result = await getFairnessMetrics(
        GetFairnessMetricsParams(
          recommendationLimit: event.recommendationLimit,
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );

      result.fold(
        (failure) {
          logger.e('Failed to refresh fairness metrics: ${failure.message}');
        },
        (metrics) {
          logger.i('Successfully refreshed fairness metrics');
          if (state is AdminLoaded) {
            final currentState = state as AdminLoaded;
            emit(
              AdminLoaded(
                currentState.metrics,
                userTrend: currentState.userTrend,
                vendorTrend: currentState.vendorTrend,
                activityLogs: currentState.activityLogs,
                notifications: currentState.notifications,
                systemMetrics: currentState.systemMetrics,
                fairnessMetrics: metrics,
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error refreshing fairness metrics: $e', stackTrace: stackTrace);
    }
  }

  Future<void> _onLoadSeasonalTrends(
    LoadSeasonalTrends event,
    Emitter<AdminState> emit,
  ) async {
    try {
      logger.i('Loading seasonal trend analysis');

      final result = await getSeasonalTrends(
        GetSeasonalTrendsParams(
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );

      result.fold(
        (failure) {
          logger.e('Failed to load seasonal trends: ${failure.message}');
          // Don't show mock data - just log the error
          // The UI will handle empty state gracefully
        },
        (trends) {
          logger.i('Successfully loaded seasonal trends from real data');
          if (state is AdminLoaded) {
            final currentState = state as AdminLoaded;
            emit(
              AdminLoaded(
                currentState.metrics,
                userTrend: currentState.userTrend,
                vendorTrend: currentState.vendorTrend,
                activityLogs: currentState.activityLogs,
                notifications: currentState.notifications,
                systemMetrics: currentState.systemMetrics,
                fairnessMetrics: currentState.fairnessMetrics,
                seasonalTrends: trends,
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error loading seasonal trends: $e', stackTrace: stackTrace);
      // Don't show mock data on error - let UI handle empty state
    }
  }

  Future<void> _onRefreshSeasonalTrends(
    RefreshSeasonalTrends event,
    Emitter<AdminState> emit,
  ) async {
    try {
      logger.i('Refreshing seasonal trend analysis');

      final result = await getSeasonalTrends(
        GetSeasonalTrendsParams(
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );

      result.fold(
        (failure) {
          logger.e('Failed to refresh seasonal trends: ${failure.message}');
        },
        (trends) {
          logger.i('Successfully refreshed seasonal trends');
          if (state is AdminLoaded) {
            final currentState = state as AdminLoaded;
            emit(
              AdminLoaded(
                currentState.metrics,
                userTrend: currentState.userTrend,
                vendorTrend: currentState.vendorTrend,
                activityLogs: currentState.activityLogs,
                notifications: currentState.notifications,
                systemMetrics: currentState.systemMetrics,
                fairnessMetrics: currentState.fairnessMetrics,
                seasonalTrends: trends,
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error refreshing seasonal trends: $e', stackTrace: stackTrace);
    }
  }

  Future<void> _onLoadDataQualityMetrics(
    LoadDataQualityMetrics event,
    Emitter<AdminState> emit,
  ) async {
    try {
      logger.i('Loading data quality metrics');

      final result = await getDataQualityMetrics();

      result.fold(
        (failure) {
          logger.e('Failed to load data quality metrics: ${failure.message}');
        },
        (metrics) {
          logger.i('Successfully loaded data quality metrics');
          if (state is AdminLoaded) {
            final currentState = state as AdminLoaded;
            emit(
              AdminLoaded(
                currentState.metrics,
                userTrend: currentState.userTrend,
                vendorTrend: currentState.vendorTrend,
                activityLogs: currentState.activityLogs,
                notifications: currentState.notifications,
                systemMetrics: currentState.systemMetrics,
                fairnessMetrics: currentState.fairnessMetrics,
                seasonalTrends: currentState.seasonalTrends,
                dataQualityMetrics: metrics,
              ),
            );
          } else {
            // If no loaded state, create one with just data quality metrics
            logger.w(
              'Loading data quality metrics without existing loaded state',
            );
          }
        },
      );
    } catch (e, stackTrace) {
      logger.e(
        'Error loading data quality metrics: $e',
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _onRefreshDataQualityMetrics(
    RefreshDataQualityMetrics event,
    Emitter<AdminState> emit,
  ) async {
    try {
      logger.i('Refreshing data quality metrics');

      final result = await getDataQualityMetrics();

      result.fold(
        (failure) {
          logger.e(
            'Failed to refresh data quality metrics: ${failure.message}',
          );
        },
        (metrics) {
          logger.i('Successfully refreshed data quality metrics');
          if (state is AdminLoaded) {
            final currentState = state as AdminLoaded;
            emit(
              AdminLoaded(
                currentState.metrics,
                userTrend: currentState.userTrend,
                vendorTrend: currentState.vendorTrend,
                activityLogs: currentState.activityLogs,
                notifications: currentState.notifications,
                systemMetrics: currentState.systemMetrics,
                fairnessMetrics: currentState.fairnessMetrics,
                seasonalTrends: currentState.seasonalTrends,
                dataQualityMetrics: metrics,
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      logger.e(
        'Error refreshing data quality metrics: $e',
        stackTrace: stackTrace,
      );
    }
  }
}
