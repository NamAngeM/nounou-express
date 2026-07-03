import '../mock/mock_data.dart';
import '../models/booking_model.dart';

/// Contrat d'accès aux réservations.
abstract class BookingRepository {
  Future<List<BookingModel>> getBookings();

  Future<BookingModel> getBookingById(String id);

  Future<BookingModel> createBooking(BookingModel booking);
}

/// Implémentation mock : liste en mémoire initialisée depuis [MockData].
/// Les créations persistent pendant la session (perdues au redémarrage).
class MockBookingRepository implements BookingRepository {
  static const Duration _latency = Duration(milliseconds: 300);

  final List<BookingModel> _bookings = List.of(MockData.bookings);

  @override
  Future<List<BookingModel>> getBookings() =>
      Future.delayed(_latency, () => List.unmodifiable(_bookings));

  @override
  Future<BookingModel> getBookingById(String id) => Future.delayed(
    _latency,
    () => _bookings.firstWhere(
      (b) => b.id == id,
      orElse: () => throw StateError('Réservation introuvable : $id'),
    ),
  );

  @override
  Future<BookingModel> createBooking(BookingModel booking) =>
      Future.delayed(_latency, () {
        _bookings.insert(0, booking);
        return booking;
      });
}
