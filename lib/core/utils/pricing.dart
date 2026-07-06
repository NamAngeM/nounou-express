import '../constants/app_constants.dart';

/// Détail d'un prix de mission, calculé par [PricingService].
class PriceBreakdown {
  final double baseTotal;
  final double nightSurcharge;
  final double weekendSurcharge;
  final double subtotal;
  final double commission;
  final double total;

  const PriceBreakdown({
    required this.baseTotal,
    required this.nightSurcharge,
    required this.weekendSurcharge,
    required this.subtotal,
    required this.commission,
    required this.total,
  });
}

/// Source unique du calcul de prix. Tous les écrans (profil nounou,
/// réservation, récapitulatif) doivent passer par ce service pour que
/// le tarif affiché soit identique partout.
abstract final class PricingService {
  /// Tarif horaire de nuit affiché sur le profil d'une nounou.
  static double nightRate(double hourlyRate) =>
      hourlyRate * (1 + AppConstants.nightSurchargeRate);

  /// Libellé de pourcentage, ex. "+20%".
  static String percentLabel(double rate) => '+${(rate * 100).round()}%';

  static String get nightLabel => percentLabel(AppConstants.nightSurchargeRate);
  static String get weekendLabel =>
      percentLabel(AppConstants.weekendSurchargeRate);
  static String get commissionLabel =>
      '${(AppConstants.commissionRate * 100).round()}%';

  static PriceBreakdown compute({
    required double hourlyRate,
    required int hours,
    required bool isNight,
    required bool isWeekend,
  }) {
    final baseTotal = hourlyRate * hours;
    final nightSurcharge =
        isNight ? baseTotal * AppConstants.nightSurchargeRate : 0.0;
    final weekendSurcharge =
        isWeekend ? baseTotal * AppConstants.weekendSurchargeRate : 0.0;
    final subtotal = baseTotal + nightSurcharge + weekendSurcharge;
    final commission = subtotal * AppConstants.commissionRate;
    return PriceBreakdown(
      baseTotal: baseTotal,
      nightSurcharge: nightSurcharge,
      weekendSurcharge: weekendSurcharge,
      subtotal: subtotal,
      commission: commission,
      total: subtotal + commission,
    );
  }
}
