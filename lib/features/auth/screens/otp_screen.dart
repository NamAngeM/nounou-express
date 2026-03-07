import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  int _secondsRemaining = 59;
  Timer? _timer;
  String phone = '';
  String role = '';
  bool _hasError = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uri = Uri.parse(GoRouterState.of(context).uri.toString());
    phone = uri.queryParameters['phone'] ?? '';
    role = uri.queryParameters['role'] ?? 'parent';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final fn in _focusNodes) {
      fn.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    setState(() => _secondsRemaining = 59);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        t.cancel();
      }
    });
  }

  void _onDigitChanged(int index, String value) {
    setState(() => _hasError = false);
    if (value.isNotEmpty) {
      if (index < 3) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last digit entered — auto verify
        _onVerify();
      }
    } else if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _onVerify() {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 4) {
      setState(() => _hasError = true);
      _shake();
      return;
    }
    // Mock: any 4-digit code passes
    context.go('/auth/register?role=$role');
  }

  void _shake() {
    _shakeController.forward(from: 0.0);
  }

  String get _formattedPhone {
    if (phone.isEmpty) return '';
    // phone is stored without spaces (raw digits)
    // Format: 0XX XX XX XX
    final clean = phone.replaceAll(' ', '');
    if (clean.length != 9) return '+241 $phone';
    return '+241 ${clean.substring(0, 3)} ${clean.substring(3, 5)} ${clean.substring(5, 7)} ${clean.substring(7)}';
  }

  @override
  Widget build(BuildContext context) {
    final offsetAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Top hero ──────────────────────────────────────────────────────
          _HeroSection(phone: _formattedPhone),

          // ── Content ───────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () => GoRouter.of(context).canPop()
                          ? context.pop()
                          : context.go('/auth/login?role=$role'),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppSpacing.md),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  Text(
                    'Vérification',
                    style: AppTypography.h1,
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: AppSpacing.xs),

                  Text(
                    'Entrez le code à 4 chiffres envoyé au\n$_formattedPhone',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 150.ms),

                  const SizedBox(height: AppSpacing.xxxl),

                  // ── OTP fields ──────────────────────────────────────────
                  AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(offsetAnim.value, 0),
                      child: child,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        4,
                        (i) =>
                            _OtpBox(
                              controller: _controllers[i],
                              focusNode: _focusNodes[i],
                              hasError: _hasError,
                              onChanged: (v) => _onDigitChanged(i, v),
                            ).animate().fadeIn(
                              delay: Duration(milliseconds: 200 + i * 60),
                            ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Error text ──────────────────────────────────────────
                  if (_hasError)
                    Center(
                      child: Text(
                        'Code incorrect. Vérifiez et réessayez.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                    ).animate().fadeIn(duration: 200.ms),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Timer / Resend ──────────────────────────────────────
                  Center(
                    child: _secondsRemaining > 0
                        ? RichText(
                            text: TextSpan(
                              text: 'Renvoyer le code dans ',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      '00:${_secondsRemaining.toString().padLeft(2, '0')}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GestureDetector(
                            onTap: _startTimer,
                            child: Text(
                              'Renvoyer le code',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primary,
                              ),
                            ),
                          ),
                  ).animate().fadeIn(delay: 380.ms),

                  const SizedBox(height: AppSpacing.xxxl),

                  AppButton(
                    label: 'Vérifier',
                    icon: Icons.verified_rounded,
                    onPressed: _onVerify,
                  ).animate().fadeIn(delay: 440.ms),

                  const SizedBox(height: AppSpacing.xl),

                  // Hint for demo
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentSurface,
                        borderRadius: AppSpacing.chipBorderRadius,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 14,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Mode demo : entrez n\'importe quel code',
                            style: AppTypography.small.copyWith(
                              color: AppColors.accentDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero section ──────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final String phone;
  const _HeroSection({required this.phone});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        56,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sms_rounded, size: 36, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Code envoyé',
            style: AppTypography.h3.copyWith(color: Colors.white),
          ),
          if (phone.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              phone,
              style: AppTypography.labelMd.copyWith(
                color: AppColors.primaryLight,
                letterSpacing: 1,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.08, end: 0);
  }
}

// ── Single OTP box ────────────────────────────────────────────────────────────
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: AppTypography.h2.copyWith(
          color: hasError ? AppColors.danger : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: hasError ? AppColors.dangerSurface : AppColors.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: hasError ? AppColors.danger : AppColors.border,
              width: hasError ? 2 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: hasError ? AppColors.danger : AppColors.primary,
              width: 2,
            ),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
