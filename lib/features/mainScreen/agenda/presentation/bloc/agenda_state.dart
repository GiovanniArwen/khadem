import 'package:khadem/features/mainScreen/agenda/data/models/agenda_event_model.dart';
import 'package:khadem/features/mainScreen/agenda/data/models/availability_model.dart';

abstract class AgendaState {}

class AgendaInitial extends AgendaState {}

class AgendaLoading extends AgendaState {}

class AgendaLoaded extends AgendaState {
  final List<AgendaEventModel> events;
  final List<AvailabilityModel> availability;

  AgendaLoaded({
    required this.events,
    required this.availability,
  });
}

class AgendaError extends AgendaState {
  final String message;

  AgendaError(this.message);
}