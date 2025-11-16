import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_support_ticket_event.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_support_ticket_state.dart';
import 'package:makan_mate/features/tickets/domain/usecases/get_support_tickets_usecase.dart';
import 'package:makan_mate/features/tickets/domain/usecases/respond_to_support_ticket_usecase.dart';

class AdminSupportTicketBloc extends Bloc<AdminSupportTicketEvent, AdminSupportTicketState> {
  final GetSupportTicketsUseCase getSupportTickets;
  final RespondToSupportTicketUseCase respondToSupportTicket;
  AdminSupportTicketBloc({
    required this.getSupportTickets,
    required this.respondToSupportTicket,
  }) : super(AdminSupportTicketInitial()) {
    on<LoadSupportTickets>(_onLoadSupportTickets);
    on<RespondToSupportTicket>(_onRespondToSupportTicket);
  }

  Future<void> _onLoadSupportTickets(
    LoadSupportTickets event,
    Emitter<AdminSupportTicketState> emit,
  ) async {
    emit(AdminSupportTicketLoading());
    final result = await getSupportTickets(
      status: event.status,
      priority: event.priority,
      category: event.category,
    );
    result.fold(
      (failure) => emit(AdminSupportTicketError(failure.message)),
      (tickets) => emit(AdminSupportTicketsLoaded(tickets)),
    );
  }

  Future<void> _onRespondToSupportTicket(
    RespondToSupportTicket event,
    Emitter<AdminSupportTicketState> emit,
  ) async {
    emit(AdminSupportTicketLoading());
    final result = await respondToSupportTicket(
      ticketId: event.ticketId,
      response: event.response,
      assignedAdminId: event.assignedAdminId,
      assignedAdminName: event.assignedAdminName,
      markResolved: event.markResolved,
    );
    result.fold(
      (failure) => emit(AdminSupportTicketError(failure.message)),
      (_) => emit(const AdminSupportTicketOperationSuccess('Response sent successfully')),
    );
  }
}


