import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khadem/features/mainScreen/agenda/data/models/agenda_event_model.dart';
import 'package:khadem/features/mainScreen/agenda/data/models/availability_model.dart';
import 'package:khadem/features/mainScreen/agenda/data/repo/agenda_repo.dart';
import 'package:khadem/features/mainScreen/agenda/presentation/bloc/agenda_event.dart';
import 'package:khadem/features/mainScreen/agenda/presentation/bloc/agenda_state.dart';

class AgendaBloc extends Bloc<AgendaEvent, AgendaState> {
  final AgendaRepo agendaRepo;

  StreamSubscription<List<AgendaEventModel>>? _eventsSubscription;
  StreamSubscription<List<AvailabilityModel>>? _availabilitySubscription;

  List<AgendaEventModel> _events = [];
  List<AvailabilityModel> _availability = [];

  AgendaBloc({required this.agendaRepo}) : super(AgendaInitial()) {
    on<LoadAgenda>(_onLoadAgenda);
    on<AgendaErrorOccurred>((event, emit) {
      emit(AgendaError(event.message));
    });
    // Internal stream updates
    on<AgendaEventsUpdated>(_onEventsUpdated);
    on<AvailabilityUpdated>(_onAvailabilityUpdated);

    // Events
    on<AddAgendaEvent>(_onAddEvent);
    on<UpdateAgendaEvent>(_onUpdateEvent);
    on<DeleteAgendaEvent>(_onDeleteEvent);

    // Availability
    on<SetAvailability>(_onSetAvailability);
    on<DeleteAvailability>(_onDeleteAvailability);
  }

  // =========================
  // Load Agenda
  // =========================

  Future<void> _onLoadAgenda(
    LoadAgenda event,
    Emitter<AgendaState> emit,
  ) async {
    emit(AgendaLoading());

    print('================ AGENDA DEBUG ================');
    print('UID: ${event.uid}');
    print('UID EMPTY: ${event.uid.isEmpty}');
    print('===============================================');

    await _eventsSubscription?.cancel();
    await _availabilitySubscription?.cancel();

    _events = [];
    _availability = [];

    _eventsSubscription = agendaRepo
        .getEvents(event.uid)
        .listen(
          (events) {
            print('AGENDA EVENTS RECEIVED: ${events.length}');

            add(AgendaEventsUpdated(events));
          },
          onError: (error) {
            print('AGENDA EVENTS ERROR: $error');

            add(AgendaErrorOccurred(error.toString()));
          },
        );

    _availabilitySubscription = agendaRepo
        .getAvailability(event.uid)
        .listen(
          (availability) {
            print('AVAILABILITY RECEIVED: ${availability.length}');

            add(AvailabilityUpdated(availability));
          },
          onError: (error) {
            print('AVAILABILITY ERROR: $error');

            add(AgendaErrorOccurred(error.toString()));
          },
        );
  }

  // =========================
  // Stream Updates
  // =========================

  void _onEventsUpdated(AgendaEventsUpdated event, Emitter<AgendaState> emit) {
    _events = event.events;

    emit(AgendaLoaded(events: _events, availability: _availability));
  }

  void _onAvailabilityUpdated(
    AvailabilityUpdated event,
    Emitter<AgendaState> emit,
  ) {
    _availability = event.availability;

    emit(AgendaLoaded(events: _events, availability: _availability));
  }

  // =========================
  // Add Event
  // =========================

  Future<void> _onAddEvent(
    AddAgendaEvent event,
    Emitter<AgendaState> emit,
  ) async {
    try {
      await agendaRepo.addEvent(uid: event.uid, event: event.event);
    } catch (e) {
      emit(AgendaError(e.toString()));
    }
  }

  // =========================
  // Update Event
  // =========================

  Future<void> _onUpdateEvent(
    UpdateAgendaEvent event,
    Emitter<AgendaState> emit,
  ) async {
    try {
      await agendaRepo.updateEvent(uid: event.uid, event: event.event);
    } catch (e) {
      emit(AgendaError(e.toString()));
    }
  }

  // =========================
  // Delete Event
  // =========================

  Future<void> _onDeleteEvent(
    DeleteAgendaEvent event,
    Emitter<AgendaState> emit,
  ) async {
    try {
      await agendaRepo.deleteEvent(uid: event.uid, eventId: event.eventId);
    } catch (e) {
      emit(AgendaError(e.toString()));
    }
  }

  // =========================
  // Set Availability
  // =========================

  Future<void> _onSetAvailability(
    SetAvailability event,
    Emitter<AgendaState> emit,
  ) async {
    try {
      await agendaRepo.setAvailability(
        uid: event.uid,
        date: event.date,
        isAvailable: event.isAvailable,
      );
    } catch (e) {
      emit(AgendaError(e.toString()));
    }
  }

  // =========================
  // Delete Availability
  // =========================

  Future<void> _onDeleteAvailability(
    DeleteAvailability event,
    Emitter<AgendaState> emit,
  ) async {
    try {
      await agendaRepo.deleteAvailability(uid: event.uid, date: event.date);
    } catch (e) {
      emit(AgendaError(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _eventsSubscription?.cancel();
    await _availabilitySubscription?.cancel();

    return super.close();
  }


}
