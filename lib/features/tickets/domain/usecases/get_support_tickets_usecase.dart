import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/features/admin/domain/entities/support_ticket_entity.dart';
import 'package:makan_mate/features/tickets/domain/repositories/ticket_repository.dart';

class GetSupportTicketsUseCase {
  final TicketRepository repository;
  GetSupportTicketsUseCase(this.repository);

  Future<Either<Failure, List<SupportTicketEntity>>> call({
    String? status,
    String? priority,
    String? category,
  }) {
    return repository.getSupportTickets(
      status: status,
      priority: priority,
      category: category,
    );
  }
}



