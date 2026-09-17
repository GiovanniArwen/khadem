import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khadem/features/mainScreen/agenda/data/models/agenda_event_model.dart';
import 'package:khadem/features/mainScreen/agenda/data/models/availability_model.dart';

class AgendaRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _agendaCollection(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('agenda');
  }

  CollectionReference<Map<String, dynamic>> _availabilityCollection(
    String uid,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('availability');
  }

  // =========================
  // Events
  // =========================

  Stream<List<AgendaEventModel>> getEvents(String uid) {
    return _agendaCollection(uid)
        .orderBy('startTime')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return AgendaEventModel.fromJson({
              ...doc.data(),
              'id': doc.id,
            });
          }).toList(),
        );
  }

  Future<void> addEvent({
    required String uid,
    required AgendaEventModel event,
  }) async {
    final doc = _agendaCollection(uid).doc();

    await doc.set({
      ...event.toJson(),
      'id': doc.id,
    });
  }

  Future<void> updateEvent({
    required String uid,
    required AgendaEventModel event,
  }) async {
    if (event.id == null) return;

    await _agendaCollection(uid).doc(event.id).update(
      event.toJson(),
    );
  }

  Future<void> deleteEvent({
    required String uid,
    required String eventId,
  }) async {
    await _agendaCollection(uid).doc(eventId).delete();
  }

  // =========================
  // Availability
  // =========================

  Stream<List<AvailabilityModel>> getAvailability(String uid) {
    return _availabilityCollection(uid).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) {
            return AvailabilityModel.fromJson({
              ...doc.data(),
              'id': doc.id,
            });
          }).toList(),
        );
  }

  Future<void> setAvailability({
    required String uid,
    required DateTime date,
    required bool isAvailable,
  }) async {
    final dateId = _dateId(date);

    await _availabilityCollection(uid).doc(dateId).set({
      'id': dateId,
      'date': Timestamp.fromDate(
        DateTime(date.year, date.month, date.day),
      ),
      'isAvailable': isAvailable,
    });
  }

  Future<void> deleteAvailability({
    required String uid,
    required DateTime date,
  }) async {
    final dateId = _dateId(date);

    await _availabilityCollection(uid).doc(dateId).delete();
  }

  String _dateId(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }
}