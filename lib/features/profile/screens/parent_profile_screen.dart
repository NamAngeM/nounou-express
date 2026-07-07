import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../data/providers/data_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/stats_card.dart';

class ParentProfileScreen extends ConsumerStatefulWidget {
  const ParentProfileScreen({super.key});

  @override
  ConsumerState<ParentProfileScreen> createState() =>
      _ParentProfileScreenState();
}

class _ParentProfileScreenState extends ConsumerState<ParentProfileScreen> {
  Map<String, dynamic>? get _profile =>
      ref.watch(currentUserProfileProvider).valueOrNull;

  String get _displayName {
    final name = (_profile?['name'] as String?)?.trim();
    return name == null || name.isEmpty ? 'Mon compte' : name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Styled header ──────────────────────────────────────────────
          AppPageHeader(
            title: 'Mon Profil',
            subtitle: _displayName,
            icon: Icons.person_rounded,
            gradientColors: const [AppColors.secondary, AppColors.primary],
            actions: [
              Semantics(
                button: true,
                label: 'Modifier mon profil',
                child: GestureDetector(
                  onTap: () => context.push('/profile/edit'),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Scrollable content ─────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: AppSpacing.xl),
                  // Les stats nounou vivent sur son dashboard (onglet
                  // Accueil) ; cette rangée est parent uniquement.
                  if (!ref.watch(authProvider).isNanny) ...[
                    _buildStatsRow(),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  _buildMenuSection(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildFooter(),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final email = (_profile?['email'] as String?)?.trim();
    return Column(
      children: [
        AppAvatar(name: _displayName, size: 100, showRing: true),
        const SizedBox(height: AppSpacing.md),
        Text(_displayName, style: AppTypography.h2),
        if (email != null && email.isNotEmpty)
          Text(
            email,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return ref
        .watch(parentStatsProvider)
        .when(
          data: (stats) => Row(
            children: [
              Expanded(
                child: StatsCard(
                  value: stats["bookings"],
                  label: "Réservations",
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: StatsCard(
                  value: stats["avgRating"],
                  label: "Note donnée",
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: StatsCard(value: stats["favorites"], label: "Favoris"),
              ),
            ],
          ),
          loading: () => const AppLoader(),
          error: (e, _) => Text(
            "Impossible de charger les statistiques",
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        );
  }

  Future<void> _signOut() async {
    await ref.read(authProvider.notifier).signOut();
    if (mounted) context.go('/auth/login');
  }

  Widget _buildMenuSection() {
    final isNanny = ref.watch(authProvider).isNanny;
    return Column(
      children: [
        _buildMenuItem(
          Icons.person_outline,
          "Modifier mon profil",
          AppColors.primary,
          onTap: () => context.push('/profile/edit'),
        ),
        if (isNanny)
          _buildMenuItem(
            Icons.verified_user_outlined,
            "Vérification du profil",
            AppColors.primary,
            onTap: () => context.push('/profile/verification'),
          ),
        _buildMenuItem(
          Icons.calendar_today,
          "Mes réservations",
          AppColors.primary,
          onTap: () => context.go('/bookings'),
        ),
        if (!isNanny)
          _buildMenuItem(
            Icons.favorite_border,
            "Mes favoris",
            AppColors.primary,
            onTap: () => context.push('/favorites'),
          ),
        _buildMenuItem(
          Icons.notifications_none,
          "Notifications",
          AppColors.primary,
          onTap: () => context.push('/notifications'),
        ),
        _buildMenuItem(
          Icons.description_outlined,
          "Conditions d'utilisation",
          AppColors.primary,
          onTap: () => context.push('/legal/terms'),
        ),
        _buildMenuItem(
          Icons.privacy_tip_outlined,
          "Politique de confidentialité",
          AppColors.primary,
          onTap: () => context.push('/legal/privacy'),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildMenuItem(
          Icons.logout,
          "Déconnexion",
          AppColors.danger,
          isDestructive: true,
          onTap: _signOut,
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String label,
    Color color, {
    VoidCallback? onTap,
    String? trailingText,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          label,
          style: AppTypography.bodyLarge.copyWith(
            color: isDestructive ? AppColors.danger : AppColors.textPrimary,
            fontWeight: isDestructive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        trailing: trailingText != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(trailingText, style: AppTypography.caption),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ],
              )
            : const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textSecondary,
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          "Nounou Express v1.0.0",
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
