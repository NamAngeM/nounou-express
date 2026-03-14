import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/mission_model.dart';

// ---------------------------------------------------------------------------
// Available Missions Screen
// ---------------------------------------------------------------------------

class AvailableMissionsScreen extends StatefulWidget {
  const AvailableMissionsScreen({super.key});

  @override
  State<AvailableMissionsScreen> createState() =>
      _AvailableMissionsScreenState();
}

class _AvailableMissionsScreenState extends State<AvailableMissionsScreen> {
  String _filter = 'Toutes';

  static const _filters = [
    'Toutes',
    'Urgentes 🔴',
    'Planifiées 🟢',
    'Ce soir',
    'Week-end',
  ];

  List<MissionModel> get _filteredMissions {
    final pending = mockMissions
        .where((m) => m.status == MissionStatus.pending)
        .toList();
    switch (_filter) {
      case 'Urgentes 🔴':
        return pending.where((m) => m.isUrgent).toList();
      case 'Planifiées 🟢':
        return pending.where((m) => !m.isUrgent).toList();
      case 'Ce soir':
        final now = DateTime.now();
        return pending.where((m) {
          final hour = int.tryParse(m.startTime.split(':').first) ?? 0;
          return m.date.day == now.day &&
              m.date.month == now.month &&
              m.date.year == now.year &&
              hour >= 18;
        }).toList();
      case 'Week-end':
        return pending.where((m) {
          final wd = m.date.weekday;
          return wd == DateTime.saturday || wd == DateTime.sunday;
        }).toList();
      default:
        return pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final missions = _filteredMissions;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _FilterBar(
            filters: _filters,
            selected: _filter,
            onSelected: (f) => setState(() => _filter = f),
          ),
          Expanded(
            child: missions.isEmpty
                ? _EmptyState(filter: _filter)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.xxl,
                    ),
                    itemCount: missions.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) =>
                        _MissionCard(mission: missions[i]),
                  ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Annonces disponibles', style: AppTypography.h3),
          Text(
            'Libreville · Angondjé',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter bar
// ---------------------------------------------------------------------------

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(
          children: filters
              .map(
                (f) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: _FilterChip(
                    label: f,
                    isActive: f == selected,
                    onTap: () => onSelected(f),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: AppSpacing.chipBorderRadius,
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMd.copyWith(
            color: isActive ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mission card
// ---------------------------------------------------------------------------

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.mission});

  final MissionModel mission;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.cardBorderRadius,
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP ROW: parent name + urgency badge
            _TopRow(mission: mission),
            const SizedBox(height: AppSpacing.sm),
            // ADDRESS
            _InfoRow(
              icon: Icons.location_on_rounded,
              iconColor: AppColors.primary,
              child: Text(mission.address, style: AppTypography.bodyMedium),
            ),
            const SizedBox(height: AppSpacing.xs),
            // DATE/TIME
            _InfoRow(
              icon: Icons.calendar_today_rounded,
              iconColor: AppColors.secondary,
              child: Text(
                '${_formatDate(mission.date)}  •  '
                '${mission.startTime}–${mission.endTime} '
                '(${_formatDuration(mission.plannedHours)})',
                style: AppTypography.bodyMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            // CHILDREN
            _InfoRow(
              icon: Icons.child_care_rounded,
              iconColor: AppColors.accent,
              child: Text(
                mission.childrenSummary.join(', '),
                style: AppTypography.bodyMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // NEEDS chips
            _NeedsRow(needs: mission.needs),
            // PETS
            if (mission.hasPets) ...[
              const SizedBox(height: AppSpacing.xs),
              _PetChip(),
            ],
            // BUDGET
            if (mission.maxBudgetPerHour != null) ...[
              const SizedBox(height: AppSpacing.xs),
              _InfoRow(
                icon: Icons.payments_outlined,
                iconColor: AppColors.success,
                child: Text(
                  'Budget max: ${_formatMoney(mission.maxBudgetPerHour!)} FCFA/h',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: AppSpacing.md),
            // BOTTOM ROW: applicants + apply button
            _BottomRow(mission: mission),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top row: parent name + time since published + urgency badge
// ---------------------------------------------------------------------------

class _TopRow extends StatelessWidget {
  const _TopRow({required this.mission});

  final MissionModel mission;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(mission.parentName, style: AppTypography.h4),
              const SizedBox(height: 2),
              Text(_timeAgo(mission.publishedAt), style: AppTypography.caption),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _UrgencyBadge(isUrgent: mission.isUrgent),
      ],
    );
  }
}

class _UrgencyBadge extends StatelessWidget {
  const _UrgencyBadge({required this.isUrgent});
  final bool isUrgent;

  @override
  Widget build(BuildContext context) {
    final color = isUrgent ? AppColors.danger : AppColors.success;
    final surface = isUrgent
        ? AppColors.dangerSurface
        : AppColors.successSurface;
    final icon = isUrgent ? Icons.flash_on_rounded : Icons.schedule_rounded;
    final label = isUrgent ? 'URGENT' : 'Planifiée';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppSpacing.badgeBorderRadius,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTypography.overline.copyWith(color: color, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Needs row
// ---------------------------------------------------------------------------

class _NeedsRow extends StatelessWidget {
  const _NeedsRow({required this.needs});
  final List<String> needs;

  @override
  Widget build(BuildContext context) {
    final visible = needs.take(3).toList();
    final extra = needs.length - 3;
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        ...visible.map(
          (n) => Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: AppSpacing.chipBorderRadius,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              n,
              style: AppTypography.labelMd.copyWith(
                color: AppColors.primary,
                fontSize: 11,
              ),
            ),
          ),
        ),
        if (extra > 0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppSpacing.chipBorderRadius,
            ),
            child: Text(
              '+$extra',
              style: AppTypography.labelMd.copyWith(fontSize: 11),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Pet chip
// ---------------------------------------------------------------------------

class _PetChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.warningSurface,
        borderRadius: AppSpacing.chipBorderRadius,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.30)),
      ),
      child: Text(
        '🐾 Animaux',
        style: AppTypography.labelMd.copyWith(
          color: AppColors.warning,
          fontSize: 11,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info row helper
// ---------------------------------------------------------------------------

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  final IconData icon;
  final Color iconColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 15, color: iconColor),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(child: child),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom row: applicants count + Postuler button
// ---------------------------------------------------------------------------

class _BottomRow extends StatelessWidget {
  const _BottomRow({required this.mission});
  final MissionModel mission;

  @override
  Widget build(BuildContext context) {
    final count = mission.applicantIds.length;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: AppSpacing.badgeBorderRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '$count candidat${count > 1 ? 's' : ''}',
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () => _showApplySheet(context, mission),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: AppSpacing.buttonBorderRadius,
            ),
          ),
          child: Text('Postuler', style: AppTypography.buttonLabelSm),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Apply bottom sheet
// ---------------------------------------------------------------------------

void _showApplySheet(BuildContext context, MissionModel mission) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ApplySheet(mission: mission),
  );
}

class _ApplySheet extends StatefulWidget {
  const _ApplySheet({required this.mission});
  final MissionModel mission;

  @override
  State<_ApplySheet> createState() => _ApplySheetState();
}

class _ApplySheetState extends State<_ApplySheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Candidature envoyée !',
              style: AppTypography.bodyMedium.copyWith(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.buttonBorderRadius,
        ),
        margin: const EdgeInsets.all(AppSpacing.lg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.sheetBorderRadius,
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: AppSpacing.chipBorderRadius,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Postuler à cette mission', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.xs),
          Text(widget.mission.parentName, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.lg),
          // Rate display
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: AppSpacing.inputBorderRadius,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text('Votre tarif: ', style: AppTypography.bodyMedium),
                Text(
                  '2 500 FCFA/h',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Message field
          TextField(
            controller: _controller,
            maxLines: 3,
            style: AppTypography.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Message (optionnel)',
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              contentPadding: const EdgeInsets.all(AppSpacing.md),
              border: OutlineInputBorder(
                borderRadius: AppSpacing.inputBorderRadius,
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppSpacing.inputBorderRadius,
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppSpacing.inputBorderRadius,
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size.fromHeight(52),
              shape: const RoundedRectangleBorder(
                borderRadius: AppSpacing.buttonBorderRadius,
              ),
            ),
            child: Text(
              'Confirmer ma candidature',
              style: AppTypography.buttonLabel,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});
  final String filter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Aucune annonce disponible',
              style: AppTypography.h4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Aucune mission ne correspond au filtre "$filter".\nEssayez un autre filtre.',
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Formatting helpers
// ---------------------------------------------------------------------------

String _formatDate(DateTime date) {
  const weekdays = ['Lun.', 'Mar.', 'Mer.', 'Jeu.', 'Ven.', 'Sam.', 'Dim.'];
  const months = [
    'janv.',
    'févr.',
    'mars',
    'avr.',
    'mai',
    'juin',
    'juil.',
    'août',
    'sept.',
    'oct.',
    'nov.',
    'déc.',
  ];
  final wd = weekdays[date.weekday - 1];
  final mo = months[date.month - 1];
  return '$wd ${date.day} $mo';
}

String _formatDuration(double hours) {
  if (hours == hours.truncate()) {
    return '${hours.toInt()}h';
  }
  final h = hours.truncate();
  final m = ((hours - h) * 60).round();
  return h > 0 ? '${h}h${m.toString().padLeft(2, '0')}' : '${m}min';
}

String _formatMoney(double amount) {
  // e.g. 3000 -> "3 000"
  final s = amount.toInt().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('\u202F');
    buf.write(s[i]);
  }
  return buf.toString();
}

String _timeAgo(DateTime publishedAt) {
  final diff = DateTime.now().difference(publishedAt);
  if (diff.inMinutes < 1) return 'publié à l\'instant';
  if (diff.inMinutes < 60) return 'publié il y a ${diff.inMinutes}min';
  if (diff.inHours < 24) return 'publié il y a ${diff.inHours}h';
  return 'publié il y a ${diff.inDays}j';
}
