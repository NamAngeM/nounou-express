import 'package:flutter_test/flutter_test.dart';
import 'package:nounou_express/data/models/mission_model.dart';

void main() {
  // ── DelayRequest ──────────────────────────────────────────────────────────

  group('DelayRequest', () {
    test('extraCost returns 0.5 for ≤30 minutes', () {
      final delay = DelayRequest(
        requestedAt: DateTime(2026, 7, 3, 14),
        minutesRequested: 15,
        reason: 'en_route',
      );
      expect(delay.extraCost, 0.5);

      final delay30 = DelayRequest(
        requestedAt: DateTime(2026, 7, 3, 14),
        minutesRequested: 30,
        reason: 'bloque',
      );
      expect(delay30.extraCost, 0.5);
    });

    test('extraCost rounds up to next hour for >30 minutes', () {
      final delay45 = DelayRequest(
        requestedAt: DateTime(2026, 7, 3, 14),
        minutesRequested: 45,
        reason: 'autre',
      );
      expect(delay45.extraCost, 1.0);

      final delay90 = DelayRequest(
        requestedAt: DateTime(2026, 7, 3, 14),
        minutesRequested: 90,
        reason: 'autre',
      );
      expect(delay90.extraCost, 2.0);
    });

    test('toJson / fromJson round-trip', () {
      final original = DelayRequest(
        requestedAt: DateTime(2026, 7, 3, 14, 30),
        minutesRequested: 60,
        reason: 'bloque',
        confirmedByNanny: true,
      );
      final json = original.toJson();
      final restored = DelayRequest.fromJson(json);

      expect(restored.minutesRequested, 60);
      expect(restored.reason, 'bloque');
      expect(restored.confirmedByNanny, true);
      expect(restored.requestedAt.hour, 14);
      expect(restored.requestedAt.minute, 30);
    });

    test('fromJson handles missing fields gracefully', () {
      final restored = DelayRequest.fromJson(<String, dynamic>{});
      expect(restored.minutesRequested, 0);
      expect(restored.reason, '');
      expect(restored.confirmedByNanny, false);
    });
  });

  // ── MissionModel ──────────────────────────────────────────────────────────

  group('MissionModel', () {
    late MissionModel mission;

    setUp(() {
      mission = MissionModel(
        id: 'm1',
        parentId: 'p1',
        parentName: 'Jean Dupont',
        parentPhotoUrl: '',
        address: '123 Rue Libreville',
        locationType: LocationType.home,
        date: DateTime(2026, 7, 3),
        startTime: '08:00',
        endTime: '12:00',
        isUrgent: false,
        childrenIds: ['c1'],
        childrenSummary: ['Léa, 3 ans'],
        needs: ['Repas', 'Bain'],
        hasPets: false,
        paymentMethod: PaymentMethod.cash,
        status: MissionStatus.pending,
        applicantIds: ['n1', 'n2'],
        publishedAt: DateTime(2026, 7),
      );
    });

    test('plannedDuration returns correct duration', () {
      expect(mission.plannedDuration, const Duration(hours: 4));
    });

    test('plannedHours returns hours as double', () {
      expect(mission.plannedHours, 4.0);
    });

    test('estimatedCost calculates correctly', () {
      // 4 hours × 2500 FCFA = 10 000 FCFA
      expect(mission.estimatedCost(2500), 10000.0);
    });

    test('actualDuration returns null when times are not set', () {
      expect(mission.actualDuration, isNull);
    });

    test('finalCost uses planned hours when no actual times', () {
      expect(mission.finalCost(2500), 10000.0);
    });

    test('finalCost uses actual duration when set', () {
      final completed = mission.copyWith(
        actualStartTime: DateTime(2026, 7, 3, 8),
        actualEndTime: DateTime(2026, 7, 3, 11, 30),
      );
      // 3.5 hours → ceil = 4 hours × 2500 = 10000
      expect(completed.finalCost(2500), 10000.0);
    });

    test('hasDelay is false by default', () {
      expect(mission.hasDelay, false);
    });

    test('hasDelay is true with delay requests', () {
      final delayed = mission.copyWith(
        delayRequests: [
          DelayRequest(
            requestedAt: DateTime(2026, 7, 3, 12),
            minutesRequested: 30,
            reason: 'bloque',
          ),
        ],
      );
      expect(delayed.hasDelay, true);
    });

    test('copyWith preserves unchanged fields', () {
      final updated = mission.copyWith(status: MissionStatus.confirmed);
      expect(updated.status, MissionStatus.confirmed);
      expect(updated.id, 'm1');
      expect(updated.parentName, 'Jean Dupont');
      expect(updated.applicantIds, ['n1', 'n2']);
    });

    test('toJson / fromJson round-trip', () {
      final json = mission.toJson();
      final restored = MissionModel.fromJson(json);

      expect(restored.id, mission.id);
      expect(restored.parentId, mission.parentId);
      expect(restored.parentName, mission.parentName);
      expect(restored.address, mission.address);
      expect(restored.locationType, LocationType.home);
      expect(restored.startTime, '08:00');
      expect(restored.endTime, '12:00');
      expect(restored.isUrgent, false);
      expect(restored.childrenSummary, ['Léa, 3 ans']);
      expect(restored.needs, ['Repas', 'Bain']);
      expect(restored.hasPets, false);
      expect(restored.paymentMethod, PaymentMethod.cash);
      expect(restored.status, MissionStatus.pending);
      expect(restored.applicantIds, ['n1', 'n2']);
    });

    test('fromJson handles missing fields with defaults', () {
      final restored = MissionModel.fromJson(<String, dynamic>{});
      expect(restored.id, '');
      expect(restored.locationType, LocationType.home);
      expect(restored.paymentMethod, PaymentMethod.cash);
      expect(restored.status, MissionStatus.pending);
      expect(restored.childrenIds, isEmpty);
      expect(restored.needs, isEmpty);
      expect(restored.applicantIds, isEmpty);
      expect(restored.delayRequests, isEmpty);
    });

    test('fromJson handles invalid enum values gracefully', () {
      final restored = MissionModel.fromJson({
        'locationType': 'invalid_type',
        'paymentMethod': 'bitcoin',
        'status': 'unknown',
      });
      expect(restored.locationType, LocationType.home);
      expect(restored.paymentMethod, PaymentMethod.cash);
      expect(restored.status, MissionStatus.pending);
    });
  });
}
