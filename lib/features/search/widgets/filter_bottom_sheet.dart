import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/mock/mock_data.dart';

// ─────────────────────────────────────── Models ──

enum SortOption {
  pertinence('Pertinence'),
  distance('Distance'),
  prixCroissant('Prix croissant'),
  prixDecroissant('Prix décroissant'),
  meilleuresNotes('Meilleures notes');

  const SortOption(this.label);
  final String label;
}

class SearchFilters {
  final Set<String> quartiers;
  final RangeValues priceRange;
  final double minRating;
  final String experienceFilter;
  final bool onlyAvailable;
  final Set<String> badges;

  const SearchFilters({
    this.quartiers = const {},
    this.priceRange = const RangeValues(1000, 10000),
    this.minRating = 0,
    this.experienceFilter = 'Toute',
    this.onlyAvailable = false,
    this.badges = const {},
  });

  bool get hasActiveFilters =>
      quartiers.isNotEmpty ||
      priceRange.start != 1000 ||
      priceRange.end != 10000 ||
      minRating > 0 ||
      experienceFilter != 'Toute' ||
      onlyAvailable ||
      badges.isNotEmpty;

  SearchFilters copyWith({
    Set<String>? quartiers,
    RangeValues? priceRange,
    double? minRating,
    String? experienceFilter,
    bool? onlyAvailable,
    Set<String>? badges,
  }) {
    return SearchFilters(
      quartiers: quartiers ?? this.quartiers,
      priceRange: priceRange ?? this.priceRange,
      minRating: minRating ?? this.minRating,
      experienceFilter: experienceFilter ?? this.experienceFilter,
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
      badges: badges ?? this.badges,
    );
  }
}

// ─────────────────────────────────────── Entry point ──

class FilterBottomSheet {
  static Future<SearchFilters?> show(
    BuildContext context,
    SearchFilters current,
  ) {
    return showModalBottomSheet<SearchFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheetContent(current: current),
    );
  }
}

// ─────────────────────────────────────── Sheet content ──

class _FilterSheetContent extends StatefulWidget {
  final SearchFilters current;
  const _FilterSheetContent({required this.current});

  @override
  State<_FilterSheetContent> createState() => _FilterSheetContentState();
}

class _FilterSheetContentState extends State<_FilterSheetContent> {
  late SearchFilters _f;

  static const _quartierOptions = [
    'Akanda',
    'Angondjé',
    'Nzeng-Ayong',
    'Owendo',
    'Glass',
    'Nombakélé',
    'Alibandeng',
    'PK8',
    'Louis',
    'Batterie IV',
  ];

  static const _expOptions = ['Toute', '1-2 ans', '3-5 ans', '5+ ans'];

  static const _badgeOptions = [
    'Vérifiée',
    'Super Nounou',
    'Gold',
    'Premiers secours',
  ];

  @override
  void initState() {
    super.initState();
    _f = widget.current;
  }

  int get _resultCount {
    return MockData.nannies.where((n) {
      if (n.hourlyRate < _f.priceRange.start ||
          n.hourlyRate > _f.priceRange.end) {
        return false;
      }
      if (n.rating < _f.minRating) {
        return false;
      }
      final exp = n.experience;
      if (_f.experienceFilter == '1-2 ans' && (exp < 1 || exp > 2)) {
        return false;
      }
      if (_f.experienceFilter == '3-5 ans' && (exp < 3 || exp > 5)) {
        return false;
      }
      if (_f.experienceFilter == '5+ ans' && exp < 5) {
        return false;
      }
      if (_f.onlyAvailable && !n.isVerified && !n.badges.contains('Disponible')) {
        return false;
      }
      for (final badge in _f.badges) {
        if (!n.badges.contains(badge)) return false;
      }
      return true;
    }).length;
  }

  void _reset() => setState(() => _f = const SearchFilters());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandle(),
              _buildHeader(),
              const Divider(height: 1),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection('Quartier', _buildQuartierChips()),
                      _buildSection('Tarif (FCFA/h)', _buildPriceRange()),
                      _buildSection('Note minimum', _buildRatingPicker()),
                      _buildSection('Expérience', _buildExpChips()),
                      _buildSection('Disponibilité', _buildAvailability()),
                      _buildSection('Badges', _buildBadges()),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              _buildApplyButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Filtres', style: AppTypography.h3),
          TextButton(
            onPressed: _reset,
            child: Text(
              'Réinitialiser',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          content,
          const SizedBox(height: AppSpacing.sm),
          const Divider(),
        ],
      ),
    );
  }

  // ── Quartier chips ──
  Widget _buildQuartierChips() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _quartierOptions.map((q) {
        final selected = _f.quartiers.contains(q);
        return FilterChip(
          label: Text(
            q,
            style: AppTypography.caption.copyWith(
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
          selected: selected,
          onSelected: (v) {
            setState(() {
              final s = Set<String>.from(_f.quartiers);
              v ? s.add(q) : s.remove(q);
              _f = _f.copyWith(quartiers: s);
            });
          },
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.background,
          checkmarkColor: Colors.white,
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.border,
          ),
          showCheckmark: false,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        );
      }).toList(),
    );
  }

  // ── Price range slider ──
  Widget _buildPriceRange() {
    return Column(
      children: [
        RangeSlider(
          values: _f.priceRange,
          min: 1000,
          max: 10000,
          divisions: 18,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border,
          onChanged: (v) => setState(() => _f = _f.copyWith(priceRange: v)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _priceTag(_f.priceRange.start.toInt()),
            _priceTag(_f.priceRange.end.toInt()),
          ],
        ),
      ],
    );
  }

  Widget _priceTag(int value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '$value FCFA/h',
        style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  // ── Rating picker ──
  Widget _buildRatingPicker() {
    return Row(
      children: List.generate(5, (index) {
        final star = index + 1;
        final active = star <= _f.minRating;
        return GestureDetector(
          onTap: () => setState(
            () => _f = _f.copyWith(
              minRating: _f.minRating == star.toDouble() ? 0 : star.toDouble(),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Icon(
              active ? Icons.star_rounded : Icons.star_outline_rounded,
              color: active ? AppColors.warning : AppColors.border,
              size: 32,
            ),
          ),
        );
      }),
    );
  }

  // ── Experience chips ──
  Widget _buildExpChips() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _expOptions.map((exp) {
        final selected = _f.experienceFilter == exp;
        return ChoiceChip(
          label: Text(
            exp,
            style: AppTypography.caption.copyWith(
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
          selected: selected,
          onSelected: (_) =>
              setState(() => _f = _f.copyWith(experienceFilter: exp)),
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.background,
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.border,
          ),
          showCheckmark: false,
        );
      }).toList(),
    );
  }

  // ── Availability ──
  Widget _buildAvailability() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Disponible maintenant', style: AppTypography.bodyMedium),
            Switch(
              value: _f.onlyAvailable,
              activeThumbColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
              onChanged: (v) =>
                  setState(() => _f = _f.copyWith(onlyAvailable: v)),
            ),
          ],
        ),
      ],
    );
  }

  // ── Badge checkboxes ──
  Widget _buildBadges() {
    return Column(
      children: _badgeOptions.map((badge) {
        final checked = _f.badges.contains(badge);
        return CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(badge, style: AppTypography.bodyMedium),
          value: checked,
          activeColor: AppColors.primary,
          onChanged: (v) {
            setState(() {
              final s = Set<String>.from(_f.badges);
              (v ?? false) ? s.add(badge) : s.remove(badge);
              _f = _f.copyWith(badges: s);
            });
          },
        );
      }).toList(),
    );
  }

  // ── Apply button ──
  Widget _buildApplyButton() {
    final count = _resultCount;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(_f),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.buttonBorderRadius,
              ),
            ),
            child: Text(
              'Voir les $count résultat${count > 1 ? 's' : ''}',
              style: AppTypography.buttonLabel,
            ),
          ),
        ),
      ),
    );
  }
}
