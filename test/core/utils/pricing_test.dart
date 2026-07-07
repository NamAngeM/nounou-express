import 'package:flutter_test/flutter_test.dart';
import 'package:nounou_express/core/constants/app_constants.dart';
import 'package:nounou_express/core/utils/pricing.dart';

void main() {
  group('PricingService.compute', () {
    test('tarif de base sans majoration', () {
      final price = PricingService.compute(
        hourlyRate: 2000,
        hours: 4,
        isNight: false,
        isWeekend: false,
      );
      expect(price.baseTotal, 8000);
      expect(price.nightSurcharge, 0);
      expect(price.weekendSurcharge, 0);
      expect(price.subtotal, 8000);
      expect(price.commission, 8000 * AppConstants.commissionRate);
      expect(price.total, price.subtotal + price.commission);
    });

    test('majoration nuit appliquée sur le tarif de base', () {
      final price = PricingService.compute(
        hourlyRate: 2000,
        hours: 4,
        isNight: true,
        isWeekend: false,
      );
      expect(price.nightSurcharge, 8000 * AppConstants.nightSurchargeRate);
      expect(price.subtotal, price.baseTotal + price.nightSurcharge);
    });

    test('majoration week-end appliquée sur le tarif de base', () {
      final price = PricingService.compute(
        hourlyRate: 2000,
        hours: 4,
        isNight: false,
        isWeekend: true,
      );
      expect(price.weekendSurcharge, 8000 * AppConstants.weekendSurchargeRate);
    });

    test('nuit + week-end se cumulent, commission sur le sous-total', () {
      final price = PricingService.compute(
        hourlyRate: 3000,
        hours: 2,
        isNight: true,
        isWeekend: true,
      );
      final expectedSubtotal =
          6000 +
          6000 * AppConstants.nightSurchargeRate +
          6000 * AppConstants.weekendSurchargeRate;
      expect(price.subtotal, expectedSubtotal);
      expect(price.commission, expectedSubtotal * AppConstants.commissionRate);
      expect(price.total, expectedSubtotal * (1 + AppConstants.commissionRate));
    });

    test('le tarif de nuit affiché (profil) est cohérent avec la majoration '
        'facturée (réservation)', () {
      // Garde-fou du bug historique : profil à +40% vs checkout à +20%.
      final displayed = PricingService.nightRate(2500);
      final charged = PricingService.compute(
        hourlyRate: 2500,
        hours: 1,
        isNight: true,
        isWeekend: false,
      );
      expect(displayed, charged.baseTotal + charged.nightSurcharge);
    });

    test('libellés de pourcentage dérivés des constantes', () {
      expect(
        PricingService.nightLabel,
        '+${(AppConstants.nightSurchargeRate * 100).round()}%',
      );
      expect(
        PricingService.weekendLabel,
        '+${(AppConstants.weekendSurchargeRate * 100).round()}%',
      );
      expect(
        PricingService.commissionLabel,
        '${(AppConstants.commissionRate * 100).round()}%',
      );
    });
  });
}
