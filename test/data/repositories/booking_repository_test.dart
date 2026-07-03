import 'package:flutter_test/flutter_test.dart';
import 'package:nounou_express/data/models/booking_model.dart';
import 'package:nounou_express/data/repositories/booking_repository.dart';

void main() {
  group('MockBookingRepository', () {
    late MockBookingRepository repository;

    setUp(() {
      repository = MockBookingRepository();
    });

    test('getBookings returns a list of bookings', () async {
      final bookings = await repository.getBookings();
      expect(bookings, isNotEmpty);
      expect(bookings.first, isA<BookingModel>());
    });

    test('getBookingById returns the correct booking', () async {
      final bookings = await repository.getBookings();
      final targetId = bookings.first.id;

      final booking = await repository.getBookingById(targetId);
      expect(booking.id, equals(targetId));
    });

    test('getBookingById throws StateError if not found', () async {
      expect(() => repository.getBookingById('invalid_id'), throwsStateError);
    });

    test('createBooking adds a new booking to the list', () async {
      final newBooking = BookingModel(
        id: 'new_booking_1',
        parentId: 'parent1',
        nannyId: 'nanny1',
        date: DateTime.now(),
        startTime: '14:00',
        endTime: '18:00',
        address: '123 Test Street',
        numberOfChildren: 1,
        childrenAges: [3],
        status: 'En attente',
        totalPrice: 12000,
        commission: 1800,
      );

      final created = await repository.createBooking(newBooking);
      expect(created.id, equals('new_booking_1'));

      final bookings = await repository.getBookings();
      expect(bookings.first.id, equals('new_booking_1'));
    });
  });
}
