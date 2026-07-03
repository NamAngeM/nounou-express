import 'package:flutter_test/flutter_test.dart';
import 'package:nounou_express/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('toJson / fromJson round-trip', () {
      final user = UserModel(
        id: 'u1',
        name: 'Jean Mboulou',
        email: 'jean@example.com',
        phone: '077123456',
        role: 'parent',
        avatar: 'https://example.com/avatar.jpg',
        createdAt: DateTime(2026, 6, 15, 10, 30),
      );

      final json = user.toJson();
      final restored = UserModel.fromJson(json);

      expect(restored.id, 'u1');
      expect(restored.name, 'Jean Mboulou');
      expect(restored.email, 'jean@example.com');
      expect(restored.phone, '077123456');
      expect(restored.role, 'parent');
      expect(restored.avatar, 'https://example.com/avatar.jpg');
      expect(restored.createdAt.year, 2026);
      expect(restored.createdAt.month, 6);
      expect(restored.createdAt.day, 15);
    });

    test('fromJson handles missing fields with defaults', () {
      final restored = UserModel.fromJson(<String, dynamic>{});

      expect(restored.id, '');
      expect(restored.name, '');
      expect(restored.email, '');
      expect(restored.phone, '');
      expect(restored.role, '');
      expect(restored.avatar, isNull);
    });

    test('fromJson handles null avatar', () {
      final restored = UserModel.fromJson({
        'id': 'u1',
        'name': 'Test',
        'avatar': null,
      });
      expect(restored.avatar, isNull);
    });

    test('toJson serializes createdAt as ISO 8601', () {
      final user = UserModel(
        id: 'u1',
        name: 'Test',
        email: '',
        phone: '',
        role: 'parent',
        createdAt: DateTime(2026, 7, 3, 14),
      );
      final json = user.toJson();
      expect(json['createdAt'], contains('2026-07-03'));
    });
  });
}
