import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../booking/widgets/mock_payment_gateway.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  int _balance = 0; // Solde factice pour la démo
  String _selectedMethod = 'airtel';
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _recharge() async {
    final text = _amountController.text.replaceAll(' ', '');
    final amount = double.tryParse(text);

    if (amount == null || amount < 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un montant valide (min. 1000 FCFA)'),
        ),
      );
      return;
    }

    final success = await MockPaymentGateway.show(
      context,
      provider: _selectedMethod,
      amount: amount,
    );

    if (success == true) {
      setState(() {
        _balance += amount.toInt();
        _amountController.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Portefeuille rechargé avec succès !'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.textPrimary,
          onPressed: () => context.pop(),
        ),
        title: Text('Mon Portefeuille', style: AppTypography.h4),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Solde Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppSpacing.cardBorderRadius,
                boxShadow: AppColors.primaryShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Solde Disponible',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '${_balance.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} ${AppConstants.currency}',
                    style: AppTypography.h1.copyWith(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1),

            const SizedBox(height: AppSpacing.xxxl),

            // Recharger Section
            Text('Recharger mon compte', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),

            // Method Selector
            Row(
              children: [
                Expanded(
                  child: _MethodCard(
                    title: 'Airtel Money',
                    color: const Color(0xFFE50000),
                    isSelected: _selectedMethod == 'airtel',
                    onTap: () => setState(() => _selectedMethod = 'airtel'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _MethodCard(
                    title: 'Moov Money',
                    color: const Color(0xFF005A9E),
                    isSelected: _selectedMethod == 'moov',
                    onTap: () => setState(() => _selectedMethod = 'moov'),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: AppSpacing.xl),

            // Amount Input
            Text('Montant (FCFA)', style: AppTypography.labelMd),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: AppTypography.h3,
              decoration: InputDecoration(
                hintText: 'ex: 5000',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: AppSpacing.xxl),

            // Button
            AppButton(
              label: 'Continuer vers $_selectedMethod',
              icon: Icons.security_rounded,
              onPressed: _recharge,
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final String title;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodCard({
    required this.title,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.phone_android_rounded,
              color: isSelected ? color : AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
