import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nounou_express/core/utils/formatters.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_FR');
  });

  // ── formatFCFA ────────────────────────────────────────────────────────────

  group('AppFormatters.formatFCFA', () {
    test('formats integer amounts with no decimals', () {
      final result = AppFormatters.formatFCFA(10000);
      // Should contain "10" and "000" and the currency symbol
      expect(result, contains('10'));
      expect(result, contains('FCFA'));
    });

    test('formats zero', () {
      final result = AppFormatters.formatFCFA(0);
      expect(result, contains('0'));
      expect(result, contains('FCFA'));
    });

    test('formats large amounts', () {
      final result = AppFormatters.formatFCFA(1500000);
      expect(result, contains('FCFA'));
    });
  });

  // ── formatDistance ────────────────────────────────────────────────────────

  group('AppFormatters.formatDistance', () {
    test('formats distances < 1 km in meters', () {
      expect(AppFormatters.formatDistance(0.5), '500 m');
      expect(AppFormatters.formatDistance(0.1), '100 m');
      expect(AppFormatters.formatDistance(0.75), '750 m');
    });

    test('formats distances >= 1 km in kilometers', () {
      expect(AppFormatters.formatDistance(1.0), '1.0 km');
      expect(AppFormatters.formatDistance(2.5), '2.5 km');
      expect(AppFormatters.formatDistance(10.3), '10.3 km');
    });

    test('boundary: exactly 1 km', () {
      expect(AppFormatters.formatDistance(1.0), '1.0 km');
    });
  });

  // ── formatShortDate ──────────────────────────────────────────────────────

  group('AppFormatters.formatShortDate', () {
    test('formats date correctly', () {
      final date = DateTime(2026, 7, 3);
      expect(AppFormatters.formatShortDate(date), '3 juil 2026');
    });

    test('handles January', () {
      final date = DateTime(2026, 1, 15);
      expect(AppFormatters.formatShortDate(date), '15 jan 2026');
    });

    test('handles December', () {
      final date = DateTime(2026, 12, 31);
      expect(AppFormatters.formatShortDate(date), '31 déc 2026');
    });

    test('handles all months', () {
      final expectedMonths = [
        'jan',
        'fév',
        'mar',
        'avr',
        'mai',
        'juin',
        'juil',
        'août',
        'sep',
        'oct',
        'nov',
        'déc',
      ];
      for (int i = 1; i <= 12; i++) {
        final date = DateTime(2026, i);
        final result = AppFormatters.formatShortDate(date);
        expect(result, contains(expectedMonths[i - 1]));
      }
    });
  });

  // ── formatDateWithWeekday ────────────────────────────────────────────────

  group('AppFormatters.formatDateWithWeekday', () {
    test('formats with weekday abbreviation', () {
      // 2026-07-03 is a Friday (Ven.)
      final date = DateTime(2026, 7, 3);
      expect(AppFormatters.formatDateWithWeekday(date), 'Ven. 3 juil.');
    });

    test('formats Monday', () {
      // 2026-06-29 is a Monday
      final date = DateTime(2026, 6, 29);
      expect(AppFormatters.formatDateWithWeekday(date), 'Lun. 29 juin');
    });

    test('formats Sunday', () {
      // 2026-07-05 is a Sunday
      final date = DateTime(2026, 7, 5);
      expect(AppFormatters.formatDateWithWeekday(date), 'Dim. 5 juil.');
    });
  });
}
