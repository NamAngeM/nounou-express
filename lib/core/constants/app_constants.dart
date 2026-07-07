abstract final class AppConstants {
  // --- App identity ---
  static const String appName = 'Nounou Express';
  static const String appSlogan = 'La confiance à portée de main';

  // --- Currency ---
  static const String currency = 'FCFA';

  // --- Tarification ---
  // Source unique des taux : toute l'app (profil nounou, réservation,
  // récapitulatif) doit passer par PricingService, jamais par des valeurs
  // locales.
  static const double defaultHourlyRate = 2500;
  static const double nightSurchargeRate = 0.20;
  static const double weekendSurchargeRate = 0.10;
  static const double commissionRate = 0.15;

  // --- Règles métier ---
  static const int maxChildrenPerNanny = 3;

  /// Annulation gratuite jusqu'à N heures avant le début de la garde ;
  /// passé ce délai, les frais de service ne sont pas remboursés.
  static const int freeCancellationHours = 24;

  // --- Contacts urgence (Gabon) ---
  static const String emergencyFireNumber = '112'; // Pompiers
  static const String emergencySamuNumber = '1488'; // SAMU social
}
