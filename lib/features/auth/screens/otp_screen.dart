import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/backend_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/repositories/auth_repository.dart';
import '../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
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
  bool _isComplete = false;
  bool _isVerifying = false;
  bool _codeRequested = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    // Listen to all controllers to track completion
    for (final c in _controllers) {
      c.addListener(_onControllersChanged);
    }
  }

  void _onControllersChanged() {
    final filled = _controllers.every((c) => c.text.isNotEmpty);
    if (filled != _isComplete) {
      setState(() => _isComplete = filled);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (extra != null) {
      phone = extra['phone'] as String? ?? '';
      role = extra['role'] as String? ?? 'parent';
    } else {
      final uri = Uri.parse(GoRouterState.of(context).uri.toString());
      phone = uri.queryParameters['phone'] ?? '';
      role = uri.queryParameters['role'] ?? 'parent';
    }
    if (!_codeRequested) {
      _codeRequested = true;
      _sendCode();
    }
  }

  /// Envoi (ou renvoi) du SMS de vérification via le repository d'auth.
  void _sendCode() {
    ref
        .read(authProvider.notifier)
        .startPhoneVerification(
          phone,
          onCodeSent: () {},
          onError: (message) {
            if (!mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          },
        );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    for (final c in _controllers) {
      c.removeListener(_onControllersChanged);
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

  Future<void> _onVerify() async {
    if (_isVerifying) return;
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 4) {
      setState(() => _hasError = true);
      _shake();
      return;
    }
    setState(() => _isVerifying = true);
    try {
      final result = await ref
          .read(authProvider.notifier)
          .confirmOtp(otp, role: role);
      if (!mounted) return;
      // Profil existant → connexion directe ; sinon → inscription.
      context.go(result.hasProfile ? '/home' : '/auth/register?role=$role');
    } on OtpException catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isVerifying = false;
      });
      _shake();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
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

                  // ── Title — delay 0 ms ──────────────────────────────────
                  Text(
                    'Vérification',
                    style: AppTypography.h1,
                  ).animate().fadeIn(delay: 0.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: AppSpacing.xs),

                  // ── Subtitle — delay 100 ms ─────────────────────────────
                  Text(
                    'Entrez le code à 4 chiffres envoyé au\n$_formattedPhone',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.08, end: 0),

                  const SizedBox(height: AppSpacing.xxxl),

                  // ── OTP fields — delay 200 ms ───────────────────────────
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

                  const SizedBox(height: AppSpacing.lg),

                  // ── Success indicator — appears when all 4 digits filled ─
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isComplete && !_hasError
                        ? Center(
                                key: const ValueKey('complete'),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 16,
                                      color: AppColors.accent,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      'Code complet',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.accentDark,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 250.ms)
                              .scale(
                                begin: const Offset(0.85, 0.85),
                                end: const Offset(1.0, 1.0),
                                duration: 250.ms,
                                curve: Curves.easeOutBack,
                              )
                        : const SizedBox(key: ValueKey('empty'), height: 20),
                  ),

                  const SizedBox(height: AppSpacing.md),

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

                  const SizedBox(height: AppSpacing.lg),

                  // ── Timer / Resend — delay 300 ms ───────────────────────
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm + 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: AppSpacing.chipBorderRadius,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _secondsRemaining > 0
                                ? Icons.timer_outlined
                                : Icons.refresh_rounded,
                            size: 15,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          _secondsRemaining > 0
                              ? RichText(
                                  text: TextSpan(
                                    text: 'Renvoyer dans ',
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
                                  onTap: () {
                                    _sendCode();
                                    _startTimer();
                                  },
                                  child: Text(
                                    'Renvoyer le code',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.primary,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: AppSpacing.xxxl),

                  AppButton(
                    label: _isVerifying ? 'Vérification...' : 'Vérifier',
                    icon: Icons.verified_rounded,
                    onPressed: _onVerify,
                  ).animate().fadeIn(delay: 380.ms),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Demo hint — affiché uniquement sur le backend mock ───
                  if (!BackendConfig.useFirebase)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentSurface,
                          borderRadius: AppSpacing.chipBorderRadius,
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 14,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Mode demo : entrez n\'importe quel code',
                              style: AppTypography.small.copyWith(
                                color: AppColors.accentDark,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 440.ms),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Bottom security card ─────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: AppSpacing.cardBorderRadius,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Connexion sécurisée · Code valide 5 min',
                          style: AppTypography.small.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
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
class _OtpBox extends StatefulWidget {
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
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _isFocused = false;
  bool _hasFilled = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChanged);
    widget.controller.addListener(_onControllerChanged);
  }

  void _onFocusChanged() {
    setState(() => _isFocused = widget.focusNode.hasFocus);
  }

  void _onControllerChanged() {
    final filled = widget.controller.text.isNotEmpty;
    if (filled != _hasFilled) {
      setState(() => _hasFilled = filled);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChanged);
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine box visual state
    final Color fillColor;
    if (widget.hasError) {
      fillColor = AppColors.dangerSurface;
    } else if (_hasFilled) {
      fillColor = AppColors.surface;
    } else {
      fillColor = AppColors.primarySurface;
    }

    final Color borderColor;
    if (widget.hasError) {
      borderColor = AppColors.danger;
    } else if (_isFocused) {
      borderColor = AppColors.primary;
    } else if (_hasFilled) {
      borderColor = AppColors.primaryLight;
    } else {
      borderColor = AppColors.border;
    }

    final double borderWidth = (widget.hasError || _isFocused || _hasFilled)
        ? 2.0
        : 1.0;

    // Gradient border decoration when focused (non-error)
    final bool showGradientBorder = _isFocused && !widget.hasError;

    Widget box = SizedBox(
      width: 64,
      height: 64,
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: AppTypography.h2.copyWith(
          color: widget.hasError ? AppColors.danger : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: fillColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: borderColor, width: borderWidth),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: widget.hasError ? AppColors.danger : AppColors.primary,
              width: 2,
            ),
          ),
        ),
        onChanged: widget.onChanged,
      ),
    );

    // Wrap with gradient border when focused
    if (showGradientBorder) {
      box = Container(
        width: 64,
        height: 64,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradientH,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(13),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              counterText: '',
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            onChanged: widget.onChanged,
          ),
        ),
      );
    }

    // Scale micro-animation when a digit is filled
    return AnimatedScale(
      scale: _hasFilled ? 1.06 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      child: box,
    );
  }
}
