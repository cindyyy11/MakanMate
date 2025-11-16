import 'package:equatable/equatable.dart';
import 'package:makan_mate/features/admin/domain/entities/support_ticket_entity.dart';

abstract class AdminSupportTicketState extends Equatable {
  const AdminSupportTicketState();
  @override
  List<Object?> get props => [];
}

class AdminSupportTicketInitial extends AdminSupportTicketState {}

class AdminSupportTicketLoading extends AdminSupportTicketState {}

class AdminSupportTicketsLoaded extends AdminSupportTicketState {
  final List<SupportTicketEntity> tickets;
  const AdminSupportTicketsLoaded(this.tickets);
  @override
  List<Object?> get props => [tickets];
}

class AdminSupportTicketError extends AdminSupportTicketState {
  final String message;
  const AdminSupportTicketError(this.message);
  @override
  List<Object?> get props => [message];
}

class AdminSupportTicketOperationSuccess extends AdminSupportTicketState {
  final String message;
  const AdminSupportTicketOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}


