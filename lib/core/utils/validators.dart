class Validators {
  static const _validGabonPrefixes = [
    '060', '062', '065', '066', // Moov Africa
    '074', '076', '077',         // Airtel Gabon
    '011',                        // Téléphonie Fixe (Libreville)
  ];

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'adresse email est requise.';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Veuillez entrer une adresse email valide.';
    }
    return null;
  }

  /// Validates a Gabonese phone number (without the +241 country code).
  /// Accepts 9 digits starting with a valid prefix: 060, 062, 065, 066 (Moov),
  /// 074, 076, 077 (Airtel), 011 (Fixe).
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro de téléphone est requis.';
    }
    final clean = value.replaceAll(' ', '');

    if (!RegExp(r'^\d+$').hasMatch(clean)) {
      return 'Le numéro ne doit contenir que des chiffres.';
    }
    if (clean.length != 9) {
      return 'Le numéro doit contenir 9 chiffres (ex: 066 85 18 18).';
    }
    final prefix = clean.substring(0, 3);
    if (!_validGabonPrefixes.contains(prefix)) {
      return 'Préfixe invalide. Moov: 060/062/065/066 · Airtel: 074/076/077 · Fixe: 011';
    }
    return null;
  }

  static String? validateCNI(String? value) {
    if (value == null || value.isEmpty) {
      return 'La pièce d\'identité est requise (CNI/Passeport).';
    }
    if (value.length < 5) {
      return 'Numéro de pièce invalide.';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis.';
    }
    return null;
  }
}
