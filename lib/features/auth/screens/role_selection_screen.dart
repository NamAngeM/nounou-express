import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? selectedRole;

  void _onRoleTap(String role) => setState(() => selectedRole = role);

  void _onContinue() {
    if (selectedRole != null) context.go('/auth/login?role=$selectedRole');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Decorative background ─────────────────────────────────────────
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.12),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.10),
                    AppColors.accent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xl),

                  // Back
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () => context.go('/onboarding'),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppSpacing.md),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 18, color: AppColors.textPrimary),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  // App logo
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradientH,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppColors.primaryShadow,
                      ),
                      child: const Icon(Icons.child_care_rounded, size: 40, color: Colors.white),
                    ),
                  ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    'Qui êtes-vous ?',
                    style: AppTypography.h1,
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 150.ms).slideY(begin: -0.1, end: 0),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    'Choisissez votre profil pour personaliser\nvotre expérience',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 220.ms),

                  const SizedBox(height: AppSpacing.xxxl),

                  // Role: Parent
                  _RoleCard(
                    icon: Icons.family_restroom_rounded,
                    title: 'Je suis Parent',
                    description: 'Je cherche une nounou de confiance pour mes enfants',
                    accentColor: AppColors.primary,
                    badgeText: 'FAMILLE',
                    isSelected: selectedRole == 'parent',
                    onTap: () => _onRoleTap('parent'),
                  ).animate().fadeIn(delay: 320.ms).slideX(begin: -0.06, end: 0),

                  const SizedBox(height: AppSpacing.lg),

                  // Role: Nanny
                  _RoleCard(
                    icon: Icons.child_care_rounded,
                    title: 'Je suis Nounou',
                    description: 'Je propose mes services de garde d\'enfants professionnels',
                    accentColor: AppColors.accent,
                    badgeText: 'PROFESSIONNEL',
                    isSelected: selectedRole == 'nanny',
                    onTap: () => _onRoleTap('nanny'),
                  ).animate().fadeIn(delay: 420.ms).slideX(begin: -0.06, end: 0),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
                    child: AppButton(
                      label: 'Continuer',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: selectedRole == null ? null : _onContinue,
                    ).animate(target: selectedRole != null ? 1 : 0)
                     .scaleXY(end: 1.02, duration: 200.ms, curve: Curves.easeOut),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;
  final String badgeText;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.badgeText,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : AppColors.surface,
          borderRadius: AppSpacing.largeBorderRadius,
          border: Border.all(
            color: isSelected ? accentColor : AppColors.border,
            width: isSelected ? 2.0 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  )
                ]
              : AppColors.cardShadow,
        ),
        transform: isSelected
            ? Matrix4.diagonal3Values(1.015, 1.015, 1.0)
            : Matrix4.identity(),
        child: Row(
          children: [
            // Icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [accentColor, accentColor.withValues(alpha: 0.70)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(18),
                boxShadow: isSelected
                    ? [BoxShadow(color: accentColor.withValues(alpha: 0.30), blurRadius: 12, offset: const Offset(0, 4))]
                    : null,
              ),
              child: Icon(
                icon,
                size: 34,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),

            const SizedBox(width: AppSpacing.lg),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: isSelected ? 0.12 : 0.07),
                      borderRadius: AppSpacing.chipBorderRadius,
                    ),
                    child: Text(
                      badgeText,
                      style: AppTypography.overline.copyWith(
                        color: accentColor,
                        fontSize: 9,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    title,
                    style: AppTypography.h4.copyWith(
                      color: isSelected ? AppColors.textPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(height: 1.4),
                  ),
                ],
              ),
            ),

            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
              ).animate().scale(duration: 250.ms, curve: Curves.easeOutBack),
          ],
        ),
      ),
    );
  }
}
