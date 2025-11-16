import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/entities/support_ticket_entity.dart';

abstract class TicketRepository {
  Future<Either<Failure, List<SupportTicketEntity>>> getSupportTickets({
    String? status,
    String? priority,
    String? category,
  });
  Future<Either<Failure, void>> respondToTicket({
    required String ticketId,
    required String response,
    required String assignedAdminId,
    required String assignedAdminName,
    required bool markResolved,
  });
}


