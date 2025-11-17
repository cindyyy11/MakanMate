import 'package:equatable/equatable.dart';

abstract class AdminUserAnalyticsEvent extends Equatable {
  const AdminUserAnalyticsEvent();
  @override
  List<Object?> get props => [];
}

class LoadUserAnalytics extends AdminUserAnalyticsEvent {}





