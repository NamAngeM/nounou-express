import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';

enum MockPaymentState { initial, processing, success, error }

class MockPaymentGateway extends StatefulWidget {
  final String provider; // 'airtel' or 'moov'
  final double amount;
  final String? initialPhoneNumber;

  const MockPaymentGateway({
    super.key,
    required this.provider,
    required this.amount,
    this.initialPhoneNumber,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String provider,
    required double amount,
    String? initialPhoneNumber,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MockPaymentGateway(
        provider: provider,
        amount: amount,
        initialPhoneNumber: initialPhoneNumber,
      ),
    );
  }

  @override
  State<MockPaymentGateway> createState() => _MockPaymentGatewayState();
}

class _MockPaymentGatewayState extends State<MockPaymentGateway> {
  final _phoneController = TextEditingController();
  MockPaymentState _state = MockPaymentState.initial;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialPhoneNumber != null) {
      // Nettoyer le format initial si besoin pour l'affichage
      _phoneController.text = widget.initialPhoneNumber!
          .replaceAll('+241', '')
          .trim();
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool get _isAirtel => widget.provider == 'airtel';

  Color get _brandColor =>
      _isAirtel ? const Color(0xFFE50000) : const Color(0xFF005A9E);
  String get _providerName => _isAirtel ? 'Airtel Money' : 'Moov Money';

  Future<void> _processPayment() async {
    final phone = _phoneController.text.replaceAll(' ', '');
    if (phone.isEmpty || phone.length < 7) {
      setState(() {
        _errorMessage = 'Veuillez saisir un numéro valide.';
      });
      return;
    }

    setState(() {
      _state = MockPaymentState.processing;
      _errorMessage = null;
    });

    // Simulate network delay & USSD push (3 seconds)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    setState(() {
      _state = MockPaymentState.success;
    });

    // Wait a moment for the success animation to be seen, then return true
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              if (_state == MockPaymentState.initial ||
                  _state == MockPaymentState.error)
                _buildInitialState()
              else if (_state == MockPaymentState.processing)
                _buildProcessingState()
              else
                _buildSuccessState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    final formattedAmount = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: AppConstants.currency,
      decimalDigits: 0,
    ).format(widget.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: _brandColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.phone_android_rounded,
                color: _brandColor,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Paiement $_providerName', style: AppTypography.h4),
                  Text(
                    'Environnement de Démo',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Montant à payer',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                formattedAmount,
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Numéro de compte $_providerName', style: AppTypography.labelMd),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: AppTypography.bodyLarge,
          decoration: InputDecoration(
            prefixIcon: const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('+241')],
              ),
            ),
            prefixIconConstraints: const BoxConstraints(),
            hintText: '07X XX XX XX',
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
              borderSide: BorderSide(color: _brandColor, width: 2),
            ),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            _errorMessage!,
            style: AppTypography.caption.copyWith(color: AppColors.danger),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        AppButton(label: 'Confirmer et Payer', onPressed: _processPayment),
      ],
    ).animate().fadeIn();
  }

  Widget _buildProcessingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Column(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(_brandColor),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('En attente de validation...', style: AppTypography.h4),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Veuillez valider le paiement sur votre téléphone (USSD).',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildSuccessState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Column(
        children: [
          Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 64,
                ),
              )
              .animate()
              .scale(duration: 400.ms, curve: Curves.easeOutBack)
              .fadeIn(duration: 200.ms),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Paiement Réussi !',
            style: AppTypography.h3.copyWith(color: AppColors.success),
          ).animate().slideY(begin: 0.2, end: 0, delay: 200.ms).fadeIn(),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Redirection en cours...',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}
