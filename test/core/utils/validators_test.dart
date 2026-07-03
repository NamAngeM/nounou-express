import 'package:flutter_test/flutter_test.dart';
import 'package:nounou_express/core/utils/validators.dart';

void main() {
  // ── Email ─────────────────────────────────────────────────────────────────

  group('Validators.validateEmail', () {
    test('returns error for null', () {
      expect(Validators.validateEmail(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.validateEmail(''), isNotNull);
    });

    test('returns null for valid email', () {
      expect(Validators.validateEmail('user@example.com'), isNull);
      expect(Validators.validateEmail('test.user@domain.ga'), isNull);
      expect(Validators.validateEmail('a-b@c.co'), isNull);
    });

    test('returns error for invalid email formats', () {
      expect(Validators.validateEmail('invalid'), isNotNull);
      expect(Validators.validateEmail('user@'), isNotNull);
      expect(Validators.validateEmail('@domain.com'), isNotNull);
      expect(Validators.validateEmail('user@.com'), isNotNull);
    });
  });

  // ── Phone (Gabon) ─────────────────────────────────────────────────────────

  group('Validators.validatePhone', () {
    test('returns error for null', () {
      expect(Validators.validatePhone(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.validatePhone(''), isNotNull);
    });

    test('returns error for non-digit characters', () {
      expect(Validators.validatePhone('06a851818'), isNotNull);
    });

    test('returns error for wrong length', () {
      expect(Validators.validatePhone('06685181'), isNotNull); // 8 digits
      expect(Validators.validatePhone('0668518180'), isNotNull); // 10 digits
    });

    // Moov prefixes
    test('accepts Moov prefixes (060, 062, 065, 066)', () {
      expect(Validators.validatePhone('060123456'), isNull);
      expect(Validators.validatePhone('062123456'), isNull);
      expect(Validators.validatePhone('065123456'), isNull);
      expect(Validators.validatePhone('066123456'), isNull);
    });

    // Airtel prefixes
    test('accepts Airtel prefixes (074, 076, 077)', () {
      expect(Validators.validatePhone('074123456'), isNull);
      expect(Validators.validatePhone('076123456'), isNull);
      expect(Validators.validatePhone('077123456'), isNull);
    });

    // Fixe prefix
    test('accepts Fixe prefix (011)', () {
      expect(Validators.validatePhone('011123456'), isNull);
    });

    test('rejects invalid prefixes', () {
      expect(Validators.validatePhone('012123456'), isNotNull);
      expect(Validators.validatePhone('050123456'), isNotNull);
      expect(Validators.validatePhone('078123456'), isNotNull);
      expect(Validators.validatePhone('099123456'), isNotNull);
    });

    test('accepts numbers with spaces (stripped internally)', () {
      expect(Validators.validatePhone('066 85 18 18'), isNull);
      expect(Validators.validatePhone('077 12 34 56'), isNull);
    });
  });

  // ── CNI ────────────────────────────────────────────────────────────────────

  group('Validators.validateCNI', () {
    test('returns error for null', () {
      expect(Validators.validateCNI(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.validateCNI(''), isNotNull);
    });

    test('returns error for too short value', () {
      expect(Validators.validateCNI('1234'), isNotNull);
    });

    test('returns null for valid CNI (5+ characters)', () {
      expect(Validators.validateCNI('12345'), isNull);
      expect(Validators.validateCNI('AB123456789'), isNull);
    });
  });

  // ── Required ──────────────────────────────────────────────────────────────

  group('Validators.validateRequired', () {
    test('returns error for null', () {
      expect(Validators.validateRequired(null, 'Champ'), isNotNull);
    });

    test('returns error for empty/whitespace', () {
      expect(Validators.validateRequired('', 'Champ'), isNotNull);
      expect(Validators.validateRequired('   ', 'Champ'), isNotNull);
    });

    test('returns null for non-empty value', () {
      expect(Validators.validateRequired('Valeur', 'Champ'), isNull);
    });

    test('error message includes field name', () {
      final error = Validators.validateRequired(null, 'Nom');
      expect(error, contains('Nom'));
    });
  });
}
