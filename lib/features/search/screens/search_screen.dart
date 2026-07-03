import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/nanny_card.dart';
import '../../../data/models/nanny_model.dart';
import '../../../data/providers/data_providers.dart';
import '../widgets/filter_bottom_sheet.dart';

const _mockDistances = [1.2, 0.8, 2.5, 1.9, 3.1, 0.5, 4.2, 2.1, 1.7, 3.8];

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  SearchFilters _filters = const SearchFilters();
  SortOption _sortBy = SortOption.pertinence;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _quartierOf(NannyModel n) =>
      n.quartier.isNotEmpty ? n.quartier : 'Libreville';

  double _distanceOf(List<NannyModel> all, NannyModel n) {
    final i = all.indexOf(n).clamp(0, _mockDistances.length - 1);
    return _mockDistances[i];
  }

  List<NannyModel> _results(List<NannyModel> all) {
    final q = _query.toLowerCase().trim();

    final list = all.where((n) {
      final quartier = _quartierOf(n);

      // Text search (name or quartier)
      if (q.isNotEmpty &&
          !n.name.toLowerCase().contains(q) &&
          !quartier.toLowerCase().contains(q)) {
        return false;
      }

      // Quartier filter
      if (_filters.quartiers.isNotEmpty &&
          !_filters.quartiers.contains(quartier)) {
        return false;
      }

      // Price range
      if (n.hourlyRate < _filters.priceRange.start ||
          n.hourlyRate > _filters.priceRange.end) {
        return false;
      }

      // Rating
      if (n.rating < _filters.minRating) return false;

      // Experience
      final exp = n.experience;
      if (_filters.experienceFilter == '1-2 ans' && (exp < 1 || exp > 2)) {
        return false;
      }
      if (_filters.experienceFilter == '3-5 ans' && (exp < 3 || exp > 5)) {
        return false;
      }
      if (_filters.experienceFilter == '5+ ans' && exp < 5) {
        return false;
      }

      // Availability
      if (_filters.onlyAvailable &&
          !n.isVerified &&
          !n.badges.contains('Disponible')) {
        return false;
      }

      // Required badges
      for (final badge in _filters.badges) {
        if (!n.badges.contains(badge)) return false;
      }

      return true;
    }).toList();

    // Sort
    switch (_sortBy) {
      case SortOption.distance:
        list.sort((a, b) => _distanceOf(all, a).compareTo(_distanceOf(all, b)));
      case SortOption.prixCroissant:
        list.sort((a, b) => a.hourlyRate.compareTo(b.hourlyRate));
      case SortOption.prixDecroissant:
        list.sort((a, b) => b.hourlyRate.compareTo(a.hourlyRate));
      case SortOption.meilleuresNotes:
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case SortOption.pertinence:
        break;
    }

    return list;
  }

  Future<void> _openFilters() async {
    final result = await FilterBottomSheet.show(context, _filters);
    if (result != null) setState(() => _filters = result);
  }

  @override
  Widget build(BuildContext context) {
    final nanniesAsync = ref.watch(nanniesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: nanniesAsync.when(
        data: _buildResults,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Erreur de chargement',
          description:
              'Impossible de charger les nounous. Vérifiez votre connexion.',
          actionLabel: 'Réessayer',
          onAction: () => ref.invalidate(nanniesProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/search/map'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.map_outlined),
        label: Text(
          'Carte',
          style: AppTypography.caption.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildResults(List<NannyModel> nannies) {
    final results = _results(nannies);

    return Column(
      children: [
        _buildCountAndSort(results.length),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.refresh(nanniesProvider.future),
            color: AppColors.primary,
            child: results.isEmpty
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    child: EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Aucune nounou trouvée',
                      description:
                          'Essayez de modifier vos filtres ou d\'élargir votre recherche.',
                      actionLabel: 'Réinitialiser les filtres',
                      onAction: () => setState(() {
                        _filters = const SearchFilters();
                        _query = '';
                        _controller.clear();
                      }),
                    ),
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.md,
                      AppSpacing.xl,
                      100,
                    ),
                    itemCount: results.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final n = results[index];
                      return NannyCard(
                            nannyId: n.id,
                            name: n.name,
                            quartier: _quartierOf(n),
                            rating: n.rating,
                            hourlyRate: n.hourlyRate,
                            distanceKm: _distanceOf(nannies, n),
                            isVerified: n.isVerified,
                          )
                          .animate()
                          .fadeIn(delay: (index * 50).ms, duration: 400.ms)
                          .slideX(begin: 0.1, end: 0);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final hasFilters = _filters.hasActiveFilters;
    return AppBar(
      backgroundColor: AppColors.secondary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
      ),
      titleSpacing: 0,
      title: Container(
        height: 40,
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: _controller,
          autofocus: true,
          style: AppTypography.bodyLarge.copyWith(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Nom, quartier...',
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.55),
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            filled: false,
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Colors.white70,
              size: 18,
            ),
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Filtres',
          onPressed: _openFilters,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.tune_rounded),
              if (hasFilters)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1),
      ),
    );
  }

  Widget _buildCountAndSort(int count) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$count nounou${count > 1 ? 's' : ''} disponible${count > 1 ? 's' : ''}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<SortOption>(
              value: _sortBy,
              isDense: true,
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
              onChanged: (v) {
                if (v != null) setState(() => _sortBy = v);
              },
              items: SortOption.values
                  .map((o) => DropdownMenuItem(value: o, child: Text(o.label)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
