import 'package:equatable/equatable.dart';

abstract class AdminSupportTicketEvent extends Equatable {
  const AdminSupportTicketEvent();
  @override
  List<Object?> get props => [];
}

class LoadSupportTickets extends AdminSupportTicketEvent {
  final String? status;
  final String? priority;
  final String? category;
  const LoadSupportTickets({this.status, this.priority, this.category});
  @override
  List<Object?> get props => [status, priority, category];
}

class RespondToSupportTicket extends AdminSupportTicketEvent {
  final String ticketId;
  final String response;
  final String assignedAdminId;
  final String assignedAdminName;
  final bool markResolved;
  const RespondToSupportTicket({
    required this.ticketId,
    required this.response,
    required this.assignedAdminId,
    required this.assignedAdminName,
    this.markResolved = false,
  });
  @override
  List<Object?> get props =>
      [ticketId, response, assignedAdminId, assignedAdminName, markResolved];
}


