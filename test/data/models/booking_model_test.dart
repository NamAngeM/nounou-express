import 'package:flutter_test/flutter_test.dart';
import 'package:nounou_express/data/models/booking_model.dart';

void main() {
  group('BookingModel', () {
    late BookingModel booking;

    setUp(() {
      booking = BookingModel(
        id: 'b1',
        parentId: 'p1',
        nannyId: 'n1',
        date: DateTime(2026, 7, 10),
        startTime: '09:00',
        endTime: '13:00',
        numberOfChildren: 2,
        childrenAges: [3, 7],
        totalPrice: 10000,
        commission: 1500,
        status: 'confirmed',
        address: 'Akanda, Libreville',
        notes: 'Allergies arachides',
      );
    });

    test('toJson / fromJson round-trip preserves all fields', () {
      final json = booking.toJson();
      final restored = BookingModel.fromJson(json);

      expect(restored.id, 'b1');
      expect(restored.parentId, 'p1');
      expect(restored.nannyId, 'n1');
      expect(restored.date.year, 2026);
      expect(restored.date.month, 7);
      expect(restored.date.day, 10);
      expect(restored.startTime, '09:00');
      expect(restored.endTime, '13:00');
      expect(restored.numberOfChildren, 2);
      expect(restored.childrenAges, [3, 7]);
      expect(restored.totalPrice, 10000);
      expect(restored.commission, 1500);
      expect(restored.status, 'confirmed');
      expect(restored.address, 'Akanda, Libreville');
      expect(restored.notes, 'Allergies arachides');
    });

    test('fromJson handles missing fields with defaults', () {
      final restored = BookingModel.fromJson(<String, dynamic>{});

      expect(restored.id, '');
      expect(restored.parentId, '');
      expect(restored.nannyId, '');
      expect(restored.startTime, '');
      expect(restored.numberOfChildren, 0);
      expect(restored.childrenAges, isEmpty);
      expect(restored.totalPrice, 0);
      expect(restored.commission, 0);
      expect(restored.status, '');
      expect(restored.address, '');
      expect(restored.notes, isNull);
    });

    test('fromJson handles null notes', () {
      final json = booking.toJson();
      json.remove('notes');
      final restored = BookingModel.fromJson(json);
      expect(restored.notes, isNull);
    });

    test('toJson includes all fields', () {
      final json = booking.toJson();
      expect(json.containsKey('id'), true);
      expect(json.containsKey('parentId'), true);
      expect(json.containsKey('nannyId'), true);
      expect(json.containsKey('date'), true);
      expect(json.containsKey('startTime'), true);
      expect(json.containsKey('endTime'), true);
      expect(json.containsKey('numberOfChildren'), true);
      expect(json.containsKey('childrenAges'), true);
      expect(json.containsKey('totalPrice'), true);
      expect(json.containsKey('commission'), true);
      expect(json.containsKey('status'), true);
      expect(json.containsKey('address'), true);
      expect(json.containsKey('notes'), true);
    });
  });
}
