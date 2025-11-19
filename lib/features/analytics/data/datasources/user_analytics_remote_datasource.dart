import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

abstract class UserAnalyticsRemoteDataSource {
  Future<int> getTotalUsers();
  Future<int> getVerifiedUsersCount();
  Future<int> getActiveUsersCount({required Duration window});
  Future<Map<String, int>> getUsersByRole();
  Future<Map<String, int>> getNewUsersByDay({required int days});
}

class UserAnalyticsRemoteDataSourceImpl implements UserAnalyticsRemoteDataSource {
  final FirebaseFirestore firestore;
  final Logger logger;

  UserAnalyticsRemoteDataSourceImpl({required this.firestore, required this.logger});

  @override
  Future<int> getTotalUsers() async {
    try {
      final snap = await firestore.collection('users').get();
      return snap.size;
    } catch (e, st) {
      logger.e('getTotalUsers error: $e', stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<int> getVerifiedUsersCount() async {
    try {
      final snap = await firestore.collection('users').where('isVerified', isEqualTo: true).get();
      return snap.size;
    } catch (e, st) {
      logger.e('getVerifiedUsersCount error: $e', stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<int> getActiveUsersCount({required Duration window}) async {
    try {
      final since = DateTime.now().subtract(window);
      final snap = await firestore
          .collection('users')
          .where('updatedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
          .get();
      return snap.size;
    } catch (e, st) {
      logger.e('getActiveUsersCount error: $e', stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getUsersByRole() async {
    try {
      final snap = await firestore.collection('users').get();
      final Map<String, int> out = {};
      for (final d in snap.docs) {
        final data = d.data();
        final role = (data['role'] ?? 'user').toString();
        out[role] = (out[role] ?? 0) + 1;
      }
      return out;
    } catch (e, st) {
      logger.e('getUsersByRole error: $e', stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getNewUsersByDay({required int days}) async {
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));
      final snap = await firestore
          .collection('users')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .get();
      final Map<String, int> buckets = {};
      for (int i = 0; i < days; i++) {
        final d = start.add(Duration(days: i));
        final label = _weekdayLabel(d.weekday);
        buckets[label] = 0;
      }
      for (final d in snap.docs) {
        final data = d.data();
        final ts = data['createdAt'];
        DateTime created;
        if (ts is Timestamp) {
          created = ts.toDate();
        } else if (ts is DateTime) {
          created = ts;
        } else {
          continue;
        }
        final day = DateTime(created.year, created.month, created.day);
        if (day.isBefore(start)) continue;
        final label = _weekdayLabel(day.weekday);
        buckets[label] = (buckets[label] ?? 0) + 1;
      }
      return buckets;
    } catch (e, st) {
      logger.e('getNewUsersByDay error: $e', stackTrace: st);
      rethrow;
    }
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }
}





