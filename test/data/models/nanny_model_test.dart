import 'package:flutter_test/flutter_test.dart';
import 'package:nounou_express/data/models/nanny_model.dart';

void main() {
  group('NannyModel', () {
    late NannyModel nanny;

    setUp(() {
      nanny = NannyModel(
        id: 'n1',
        name: 'Aïcha Moussavou',
        email: 'aicha@example.com',
        phone: '066851818',
        role: 'nanny',
        avatar: 'https://example.com/avatar.jpg',
        createdAt: DateTime(2026, 1, 15),
        experience: 3,
        hourlyRate: 2500,
        rating: 4.7,
        totalMissions: 42,
        badges: ['Vérifiée', 'Top Nounou'],
        skills: ['Premiers secours', 'Cuisine', 'Aide aux devoirs'],
        isVerified: true,
        bio: 'Passionnée de la petite enfance.',
        quartier: 'Akanda',
      );
    });

    test('toJson / fromJson round-trip preserves all fields', () {
      final json = nanny.toJson();
      final restored = NannyModel.fromJson(json);

      expect(restored.id, 'n1');
      expect(restored.name, 'Aïcha Moussavou');
      expect(restored.email, 'aicha@example.com');
      expect(restored.phone, '066851818');
      expect(restored.role, 'nanny');
      expect(restored.avatar, 'https://example.com/avatar.jpg');
      expect(restored.experience, 3);
      expect(restored.hourlyRate, 2500);
      expect(restored.rating, 4.7);
      expect(restored.totalMissions, 42);
      expect(restored.badges, ['Vérifiée', 'Top Nounou']);
      expect(restored.skills, [
        'Premiers secours',
        'Cuisine',
        'Aide aux devoirs',
      ]);
      expect(restored.isVerified, true);
      expect(restored.bio, 'Passionnée de la petite enfance.');
      expect(restored.quartier, 'Akanda');
    });

    test('toJson includes parent class (UserModel) fields', () {
      final json = nanny.toJson();
      expect(json.containsKey('id'), true);
      expect(json.containsKey('name'), true);
      expect(json.containsKey('email'), true);
      expect(json.containsKey('phone'), true);
      expect(json.containsKey('role'), true);
      expect(json.containsKey('createdAt'), true);
      // NannyModel-specific fields
      expect(json.containsKey('experience'), true);
      expect(json.containsKey('hourlyRate'), true);
      expect(json.containsKey('rating'), true);
      expect(json.containsKey('isVerified'), true);
      expect(json.containsKey('quartier'), true);
    });

    test('fromJson handles missing fields with defaults', () {
      final restored = NannyModel.fromJson(<String, dynamic>{});

      expect(restored.id, '');
      expect(restored.name, '');
      expect(restored.email, '');
      expect(restored.phone, '');
      expect(restored.role, '');
      expect(restored.avatar, isNull);
      expect(restored.experience, 0);
      expect(restored.hourlyRate, 0);
      expect(restored.rating, 0);
      expect(restored.totalMissions, 0);
      expect(restored.badges, isEmpty);
      expect(restored.skills, isEmpty);
      expect(restored.isVerified, false);
      expect(restored.bio, '');
      expect(restored.quartier, '');
    });
  });
}
