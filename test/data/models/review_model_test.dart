import 'package:flutter_test/flutter_test.dart';
import 'package:nounou_express/data/models/review_model.dart';

void main() {
  group('ReviewModel', () {
    test('toJson / fromJson round-trip', () {
      final review = ReviewModel(
        id: 'r1',
        bookingId: 'b1',
        fromUserId: 'p1',
        toUserId: 'n1',
        rating: 4.5,
        comment: 'Excellente nounou, très professionnelle !',
        createdAt: DateTime(2026, 7, 1, 18),
      );

      final json = review.toJson();
      final restored = ReviewModel.fromJson(json);

      expect(restored.id, 'r1');
      expect(restored.bookingId, 'b1');
      expect(restored.fromUserId, 'p1');
      expect(restored.toUserId, 'n1');
      expect(restored.rating, 4.5);
      expect(restored.comment, 'Excellente nounou, très professionnelle !');
      expect(restored.createdAt.year, 2026);
    });

    test('fromJson handles missing fields with defaults', () {
      final restored = ReviewModel.fromJson(<String, dynamic>{});

      expect(restored.id, '');
      expect(restored.bookingId, '');
      expect(restored.fromUserId, '');
      expect(restored.toUserId, '');
      expect(restored.rating, 0);
      expect(restored.comment, '');
    });

    test('toJson includes all fields', () {
      final review = ReviewModel(
        id: 'r1',
        bookingId: 'b1',
        fromUserId: 'p1',
        toUserId: 'n1',
        rating: 5.0,
        comment: 'Parfait',
        createdAt: DateTime(2026, 7),
      );
      final json = review.toJson();

      expect(json.length, 7);
      expect(json['rating'], 5.0);
      expect(json['comment'], 'Parfait');
    });
  });
}
