import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../data/providers/data_providers.dart';
import '../widgets/stats_card.dart';

class ParentProfileScreen extends ConsumerStatefulWidget {
  const ParentProfileScreen({super.key});

  @override
  ConsumerState<ParentProfileScreen> createState() =>
      _ParentProfileScreenState();
}

class _ParentProfileScreenState extends ConsumerState<ParentProfileScreen> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Styled header ──────────────────────────────────────────────
          AppPageHeader(
            title: 'Mon Profil',
            subtitle: 'Alice Mengome',
            icon: Icons.person_rounded,
            gradientColors: const [Color(0xFFC04420), AppColors.primary],
            actions: [
              GestureDetector(
                onTap: () => context.push('/profile/edit'),
                child: Container(
                  padding: const EdgeInsets.all(9),
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
                  _buildStatsRow(),
                  const SizedBox(height: AppSpacing.xl),
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
    return Column(
      children: [
        Stack(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=p1"),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text("Alice Mengome", style: AppTypography.h2),
        Text(
          "alice.mengome@gmail.com",
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
                child: StatsCard(value: stats["favorites"], label: "Favorites"),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(
            "Impossible de charger les statistiques",
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        );
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
        _buildMenuItem(
          Icons.person_outline,
          "Modifier mon profil",
          Colors.blue,
          onTap: () => context.push('/profile/edit'),
        ),
        _buildMenuItem(Icons.child_care, "Mes enfants", Colors.orange),
        _buildMenuItem(
          Icons.calendar_today,
          "Mes réservations",
          Colors.green,
          onTap: () => context.go('/bookings'),
        ),
        _buildMenuItem(Icons.favorite_border, "Mes favorites", Colors.red),
        _buildMenuItem(Icons.credit_card, "Paiements", Colors.teal),
        _buildMenuItem(
          Icons.notifications_none,
          "Notifications",
          Colors.purple,
        ),
        _buildMenuSwitch(
          Icons.dark_mode_outlined,
          "Mode sombre",
          Colors.indigo,
          _isDarkMode,
          (val) {
            setState(() => _isDarkMode = val);
          },
        ),
        _buildMenuItem(
          Icons.language,
          "Langue",
          Colors.blueGrey,
          trailingText: "Français",
        ),
        _buildMenuItem(Icons.help_outline, "Aide & FAQ", Colors.amber),
        _buildMenuItem(
          Icons.description_outlined,
          "Conditions d'utilisation",
          Colors.grey,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildMenuItem(
          Icons.logout,
          "Déconnexion",
          AppColors.danger,
          isDestructive: true,
          onTap: () => context.go('/auth/login'),
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

  Widget _buildMenuSwitch(
    IconData icon,
    String label,
    Color color,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
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
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w500),
        ),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.primary,
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
