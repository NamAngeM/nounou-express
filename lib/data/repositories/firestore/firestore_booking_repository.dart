import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/booking_model.dart';
import '../booking_repository.dart';
import 'firestore_helpers.dart';

/// Implémentation Firestore des réservations.
///
/// Schéma : `bookings/{bookingId}` (BookingModel.toJson, dates ISO-8601).
class FirestoreBookingRepository implements BookingRepository {
  FirestoreBookingRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _bookings =>
      _db.collection('bookings');

  @override
  Future<List<BookingModel>> getBookings() async {
    // where + orderBy sur des champs différents : index composite requis
    // (parentId ASC, date DESC) — déclaré dans firestore.indexes.json.
    final snapshot = await _bookings
        .where('parentId', isEqualTo: currentUid())
        .orderBy('date', descending: true)
        .limit(50)
        .get();
    return List.unmodifiable(
      snapshot.docs.map((d) => BookingModel.fromJson(normalizeDoc(d.data()))),
    );
  }

  @override
  Future<BookingModel> getBookingById(String id) async {
    final snapshot = await _bookings.doc(id).get();
    final data = snapshot.data();
    if (data == null) throw StateError('Réservation introuvable : $id');
    return BookingModel.fromJson(normalizeDoc(data));
  }

  @override
  Future<BookingModel> createBooking(BookingModel booking) async {
    await _bookings.doc(booking.id).set(booking.toJson());
    return booking;
  }
}
