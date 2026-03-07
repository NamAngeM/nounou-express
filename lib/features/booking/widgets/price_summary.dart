import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/nanny_model.dart';

class PriceSummary extends StatelessWidget {
  final NannyModel nanny;
  final int hours;
  final bool isWeekend;
  final bool isNight;
  final String paymentMethod;
  final Function(String method) onPaymentMethodChanged;

  const PriceSummary({
    super.key,
    required this.nanny,
    required this.hours,
    required this.isWeekend,
    required this.isNight,
    required this.paymentMethod,
    required this.onPaymentMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final double baseRate = nanny.hourlyRate;
    final double baseTotal = baseRate * hours;
    final double nightSurcharge = isNight ? baseTotal * 0.2 : 0;
    final double weekendSurcharge = isWeekend ? baseTotal * 0.1 : 0;
    final double subtotal = baseTotal + nightSurcharge + weekendSurcharge;
    final double commission = subtotal * 0.15;
    final double total = subtotal + commission;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPriceRow("Tarif de base ($hours h × ${baseRate.toInt()} FCFA)", baseTotal),
        if (isNight) _buildPriceRow("Majoration nuit (+20%)", nightSurcharge),
        if (isWeekend) _buildPriceRow("Majoration week-end (+10%)", weekendSurcharge),
        const Divider(height: AppSpacing.xl),
        _buildPriceRow("Sous-total", subtotal, isBold: true),
        _buildPriceRow("Commission Nounou Express (15%)", commission),
        const SizedBox(height: AppSpacing.md),
        _buildPriceRow("TOTAL", total, isBold: true, isLarge: true, color: AppColors.primary),
        const SizedBox(height: AppSpacing.xl),
        Text(
          "Mode de paiement",
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildPaymentOption("Espèces", Icons.payments_outlined, "cash"),
        _buildPaymentOption("Airtel Money", Icons.phone_android, "airtel"),
        _buildPaymentOption("Moov Money", Icons.phone_android, "moov"),
      ],
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isBold = false, bool isLarge = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold 
              ? AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700, color: color)
              : AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            "${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} FCFA",
            style: (isLarge ? AppTypography.h3 : (isBold ? AppTypography.bodyLarge : AppTypography.bodyMedium)).copyWith(
              fontWeight: FontWeight.w700,
              color: color ?? (isBold ? AppColors.textPrimary : AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String label, IconData icon, String value) {
    final bool isSelected = paymentMethod == value;
    return InkWell(
      onTap: () => onPaymentMethodChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(AppSpacing.md),
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: paymentMethod,
              onChanged: (val) => onPaymentMethodChanged(val!),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
