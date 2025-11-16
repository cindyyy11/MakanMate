import 'package:dartz/dartz.dart';
import 'package:makan_mate/core/errors/exceptions.dart';
import 'package:makan_mate/core/errors/failures.dart';
import 'package:makan_mate/core/network/network_info.dart';
import 'package:makan_mate/features/tickets/data/datasources/ticket_remote_datasource.dart';
import 'package:makan_mate/features/tickets/domain/repositories/ticket_repository.dart';
import 'package:makan_mate/features/admin/domain/entities/support_ticket_entity.dart';

class TicketRepositoryImpl implements TicketRepository {
  final TicketRemoteDataSource remote;
  final NetworkInfo networkInfo;

  TicketRepositoryImpl({required this.remote, required this.networkInfo});

  @override
  Future<Either<Failure, List<SupportTicketEntity>>> getSupportTickets({
    String? status,
    String? priority,
    String? category,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final models = await remote.getSupportTickets(
        status: status,
        priority: priority,
        category: category,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch support tickets: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> respondToTicket({
    required String ticketId,
    required String response,
    required String assignedAdminId,
    required String assignedAdminName,
    required bool markResolved,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      await remote.respondToTicket(
        ticketId: ticketId,
        response: response,
        assignedAdminId: assignedAdminId,
        assignedAdminName: assignedAdminName,
        markResolved: markResolved,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to respond to ticket: $e'));
    }
  }
}


