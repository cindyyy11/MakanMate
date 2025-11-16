import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:makan_mate/features/tickets/data/models/support_ticket_model.dart';

abstract class TicketRemoteDataSource {
  Future<List<SupportTicketModel>> getSupportTickets({String? status, String? priority, String? category});
  Future<void> respondToTicket({
    required String ticketId,
    required String response,
    required String assignedAdminId,
    required String assignedAdminName,
    required bool markResolved,
  });
}

class TicketRemoteDataSourceImpl implements TicketRemoteDataSource {
  final FirebaseFirestore firestore;
  final Logger logger;

  TicketRemoteDataSourceImpl({required this.firestore, required this.logger});

  @override
  Future<List<SupportTicketModel>> getSupportTickets({String? status, String? priority, String? category}) async {
    try {
      Query query = firestore.collection('support_tickets');

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }
      if (priority != null) {
        query = query.where('priority', isEqualTo: priority);
      }
      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      query = query.orderBy('createdAt', descending: true).limit(200);

      final snap = await query.get();
      return snap.docs.map((d) => SupportTicketModel.fromFirestore(d)).toList();
    } catch (e, st) {
      logger.e('TicketRemoteDataSource.getSupportTickets error: $e', stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> respondToTicket({
    required String ticketId,
    required String response,
    required String assignedAdminId,
    required String assignedAdminName,
    required bool markResolved,
  }) async {
    try {
      final update = <String, dynamic>{
        'response': response,
        'assignedAdminId': assignedAdminId,
        'assignedAdminName': assignedAdminName,
        'status': markResolved ? 'resolved' : 'in_progress',
      };
      if (markResolved) {
        update['resolvedAt'] = FieldValue.serverTimestamp();
      }
      await firestore.collection('support_tickets').doc(ticketId).update(update);
    } catch (e, st) {
      logger.e('TicketRemoteDataSource.respondToTicket error: $e', stackTrace: st);
      rethrow;
    }
  }
}


