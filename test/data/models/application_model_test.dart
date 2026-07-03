import 'package:flutter_test/flutter_test.dart';
import 'package:nounou_express/data/models/application_model.dart';

void main() {
  group('ApplicationModel', () {
    late ApplicationModel application;

    setUp(() {
      application = ApplicationModel(
        id: 'a1',
        missionId: 'm1',
        nannyId: 'n1',
        nannyName: 'Marie Ndong',
        nannyPhotoUrl: 'https://example.com/photo.jpg',
        nannyRating: 4.8,
        nannyReviewCount: 25,
        hourlyRate: 3000,
        experienceYears: 5,
        skills: ['Premiers secours', 'Cuisine'],
        message: 'Je suis disponible',
        appliedAt: DateTime(2026, 7, 2, 10, 30),
      );
    });

    test('toJson / fromJson round-trip', () {
      final json = application.toJson();
      final restored = ApplicationModel.fromJson(json);

      expect(restored.id, 'a1');
      expect(restored.missionId, 'm1');
      expect(restored.nannyId, 'n1');
      expect(restored.nannyName, 'Marie Ndong');
      expect(restored.nannyRating, 4.8);
      expect(restored.nannyReviewCount, 25);
      expect(restored.hourlyRate, 3000);
      expect(restored.experienceYears, 5);
      expect(restored.skills, ['Premiers secours', 'Cuisine']);
      expect(restored.message, 'Je suis disponible');
      expect(restored.status, ApplicationStatus.pending);
    });

    test('fromJson handles missing fields with defaults', () {
      final restored = ApplicationModel.fromJson(<String, dynamic>{});

      expect(restored.id, '');
      expect(restored.nannyName, '');
      expect(restored.nannyRating, 0);
      expect(restored.hourlyRate, 0);
      expect(restored.skills, isEmpty);
      expect(restored.message, isNull);
      expect(restored.status, ApplicationStatus.pending);
    });

    test('fromJson handles invalid status enum', () {
      final restored = ApplicationModel.fromJson({'status': 'invalid_status'});
      expect(restored.status, ApplicationStatus.pending);
    });

    test('copyWith updates status only', () {
      final accepted = application.copyWith(status: ApplicationStatus.accepted);

      expect(accepted.status, ApplicationStatus.accepted);
      expect(accepted.id, 'a1');
      expect(accepted.nannyName, 'Marie Ndong');
      expect(accepted.message, 'Je suis disponible');
    });

    test('copyWith with null preserves original status', () {
      final unchanged = application.copyWith();
      expect(unchanged.status, ApplicationStatus.pending);
    });

    test('all ApplicationStatus values serialize correctly', () {
      for (final status in ApplicationStatus.values) {
        final app = application.copyWith(status: status);
        final json = app.toJson();
        final restored = ApplicationModel.fromJson(json);
        expect(restored.status, status);
      }
    });
  });
}
