import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/tickets/domain/repositories/ticket_repository.dart';

class RespondToSupportTicketUseCase {
  final TicketRepository repository;
  RespondToSupportTicketUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String ticketId,
    required String response,
    required String assignedAdminId,
    required String assignedAdminName,
    required bool markResolved,
  }) {
    return repository.respondToTicket(
      ticketId: ticketId,
      response: response,
      assignedAdminId: assignedAdminId,
      assignedAdminName: assignedAdminName,
      markResolved: markResolved,
    );
  }
}





