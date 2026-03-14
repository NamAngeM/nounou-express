import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../widgets/phone_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String? role;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uri = Uri.parse(GoRouterState.of(context).uri.toString());
    role = uri.queryParameters['role'];
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onReceiveCode() {
    final phone = _phoneController.text.replaceAll(' ', '');
    if (phone.length >= 8) {
      context.go('/auth/otp?phone=$phone&role=${role ?? ''}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Veuillez entrer un numéro valide',
            style: AppTypography.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.cardBorderRadius,
          ),
          margin: const EdgeInsets.all(AppSpacing.lg),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNanny = role == 'nanny';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Branded top section ──────────────────────────────────────────
          _TopSection(isNanny: isNanny),

          // ── Form ────────────────────────────────────────────────────────
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
                          : context.go('/auth/role'),
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
                    'Connexion',
                    style: AppTypography.h1,
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: AppSpacing.xs),

                  Text(
                    'Entrez votre numéro de téléphone\npour recevoir un code de vérification.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 150.ms),

                  const SizedBox(height: AppSpacing.xxxl),

                  // Phone input
                  PhoneInput(
                    controller: _phoneController,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.07, end: 0),

                  const SizedBox(height: AppSpacing.xxl),

                  // Primary CTA
                  AppButton(
                    label: 'Recevoir le code',
                    icon: Icons.sms_rounded,
                    onPressed: _onReceiveCode,
                  ).animate().fadeIn(delay: 260.ms),

                  const SizedBox(height: AppSpacing.xl),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Text('ou', style: AppTypography.caption),
                      ),
                      Expanded(child: Divider(color: AppColors.border)),
                    ],
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: AppSpacing.xl),

                  // Google button
                  _GoogleButton().animate().fadeIn(delay: 340.ms),

                  const SizedBox(height: AppSpacing.xxxl),

                  // Register link
                  Center(
                    child: GestureDetector(
                      onTap: () =>
                          context.push('/auth/register?role=${role ?? ''}'),
                      child: RichText(
                        text: TextSpan(
                          text: 'Pas encore inscrit ? ',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: "S'inscrire",
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 380.ms),

                  const SizedBox(height: AppSpacing.xl),

                  Center(
                    child: Text(
                      "En continuant, vous acceptez nos Conditions d'utilisation",
                      style: AppTypography.small.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fadeIn(delay: 400.ms),

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

// ── Branded hero section ─────────────────────────────────────────────────────
class _TopSection extends StatelessWidget {
  final bool isNanny;
  const _TopSection({required this.isNanny});

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
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              'assets/logo.png',
              height: 56,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.25),
              borderRadius: AppSpacing.chipBorderRadius,
            ),
            child: Text(
              isNanny ? 'Espace Nounou' : 'Espace Parent',
              style: AppTypography.labelMd.copyWith(
                color: AppColors.primaryLight,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.08, end: 0);
  }
}

// ── Google button ────────────────────────────────────────────────────────────
class _GoogleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.buttonBorderRadius,
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/google.png', width: 24, height: 24),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Continuer avec Google',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
