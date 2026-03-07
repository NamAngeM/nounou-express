import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingData(
      // Mère noire avec enfant — scène chaleureuse
      imageUrl:
          'https://images.unsplash.com/photo-1531983372-62e91f840e99?auto=format&fit=crop&w=800&q=80',
      gradientColors: [Color(0xFFB83220), Color(0xFFE8552A)],
      tag: 'RECHERCHE',
      title: 'Trouvez la nounou\nidéale',
      description:
          'Des nounous vérifiées et qualifiées dans votre quartier à Libreville. Filtrez par disponibilité, tarif et compétences.',
    ),
    _OnboardingData(
      // Femme africaine avec bébé — moment de tendresse
      imageUrl:
          'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?auto=format&fit=crop&w=800&q=80',
      gradientColors: [Color(0xFF1B2B3A), Color(0xFF2D4A6B)],
      tag: 'RÉSERVATION',
      title: 'Réservez en\nun instant',
      description:
          'Choisissez votre créneau, confirmez en quelques secondes. Aussi simple que ça.',
    ),
    _OnboardingData(
      // Famille noire — confiance et sécurité
      imageUrl:
          'https://images.unsplash.com/photo-1536640712-4d4c36ff0e4e?auto=format&fit=crop&w=800&q=80',
      gradientColors: [Color(0xFF006D62), Color(0xFF00A896)],
      tag: 'CONFIANCE',
      title: 'En toute\nconfiance',
      description:
          'Profils vérifiés, avis des parents, bouton SOS intégré. La sécurité de vos enfants est notre priorité absolue.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.go('/auth/role');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Full-bleed pages ───────────────────────────────────────────────
          PageView.builder(
            controller: _pageController,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemCount: _pages.length,
            itemBuilder: (context, index) =>
                _OnboardingPage(data: _pages[index]),
          ),

          // ── Skip button ────────────────────────────────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: GestureDetector(
                  onTap: () => context.go('/auth/role'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: AppSpacing.chipBorderRadius,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      'Passer',
                      style: AppTypography.labelMd.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 600.ms),

          // ── Bottom controls ────────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomControls(
              currentPage: _currentPage,
              totalPages: _pages.length,
              data: _pages[_currentPage],
              onNext: _nextPage,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Full-bleed photo page ─────────────────────────────────────────────────────
class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Photo background
        CachedNetworkImage(
          imageUrl: data.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: data.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: data.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.child_care_rounded,
                size: 100,
                color: Colors.white30,
              ),
            ),
          ),
        ),

        // Gradient overlay — dark bottom for text, slight top tint
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.3, 0.6, 1.0],
              colors: [
                data.gradientColors.first.withValues(alpha: 0.35),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.45),
                Colors.black.withValues(alpha: 0.88),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Bottom controls overlay ───────────────────────────────────────────────────
class _BottomControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final _OnboardingData data;
  final VoidCallback onNext;

  const _BottomControls({
    required this.currentPage,
    required this.totalPages,
    required this.data,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentPage == totalPages - 1;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxxl,
        AppSpacing.xxxl,
        AppSpacing.xxxl,
        AppSpacing.xxl + bottomPad,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tag pill
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: data.gradientColors.last.withValues(alpha: 0.85),
                  borderRadius: AppSpacing.chipBorderRadius,
                ),
                child: Text(
                  data.tag,
                  style: AppTypography.overline.copyWith(
                    color: Colors.white,
                    letterSpacing: 1.5,
                    fontSize: 10,
                  ),
                ),
              )
              .animate(key: ValueKey('tag_$currentPage'))
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.15, end: 0),

          const SizedBox(height: AppSpacing.md),

          // Title
          Text(
                data.title,
                style: AppTypography.h1.copyWith(
                  color: Colors.white,
                  fontSize: 34,
                  height: 1.15,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
              )
              .animate(key: ValueKey('title_$currentPage'))
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: AppSpacing.md),

          // Description
          Text(
                data.description,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.80),
                  height: 1.6,
                ),
              )
              .animate(key: ValueKey('desc_$currentPage'))
              .fadeIn(delay: 200.ms, duration: 400.ms),

          const SizedBox(height: AppSpacing.xxxl),

          // Dots + CTA
          Row(
            children: [
              // Progress dots
              Row(
                children: List.generate(totalPages, (i) {
                  final isActive = i == currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.only(right: 6),
                    width: isActive ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.35),
                      borderRadius: AppSpacing.chipBorderRadius,
                    ),
                  );
                }),
              ),

              const Spacer(),

              // Next / Start button
              GestureDetector(
                onTap: onNext,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isLast ? null : 56,
                  height: 56,
                  padding: isLast
                      ? const EdgeInsets.symmetric(horizontal: AppSpacing.xl)
                      : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: data.gradientColors,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: AppSpacing.chipBorderRadius,
                    boxShadow: [
                      BoxShadow(
                        color: data.gradientColors.last.withValues(alpha: 0.45),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isLast
                        ? Text(
                            'Commencer',
                            style: AppTypography.buttonLabel.copyWith(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────
class _OnboardingData {
  final String imageUrl;
  final List<Color> gradientColors;
  final String tag;
  final String title;
  final String description;

  const _OnboardingData({
    required this.imageUrl,
    required this.gradientColors,
    required this.tag,
    required this.title,
    required this.description,
  });
}
