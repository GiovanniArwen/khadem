import 'package:khadem/features/mainScreen/agenda/data/models/agenda_event_model.dart';
import 'package:khadem/features/mainScreen/agenda/data/models/availability_model.dart';

abstract class AgendaEvent {}

class LoadAgenda extends AgendaEvent {
  final String uid;

  LoadAgenda(this.uid);
}

// =========================
// Internal stream events
// =========================

class AgendaEventsUpdated extends AgendaEvent {
  final List<AgendaEventModel> events;

  AgendaEventsUpdated(this.events);
}

class AvailabilityUpdated extends AgendaEvent {
  final List<AvailabilityModel> availability;

  AvailabilityUpdated(this.availability);
}

// =========================
// Events CRUD
// =========================

class AddAgendaEvent extends AgendaEvent {
  final String uid;
  final AgendaEventModel event;

  AddAgendaEvent({
    required this.uid,
    required this.event,
  });
}

class UpdateAgendaEvent extends AgendaEvent {
  final String uid;
  final AgendaEventModel event;

  UpdateAgendaEvent({
    required this.uid,
    required this.event,
  });
}

class DeleteAgendaEvent extends AgendaEvent {
  final String uid;
  final String eventId;

  DeleteAgendaEvent({
    required this.uid,
    required this.eventId,
  });
}

// =========================
// Availability
// =========================

class SetAvailability extends AgendaEvent {
  final String uid;
  final DateTime date;
  final bool isAvailable;

  SetAvailability({
    required this.uid,
    required this.date,
    required this.isAvailable,
  });
}

class DeleteAvailability extends AgendaEvent {
  final String uid;
  final DateTime date;

  DeleteAvailability({
    required this.uid,
    required this.date,
  });
}

class AgendaErrorOccurred extends AgendaEvent {
  final String message;

  AgendaErrorOccurred(this.message);
}