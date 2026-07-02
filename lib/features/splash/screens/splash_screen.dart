import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      context.go(isAuthenticated ? '/home' : '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
              AppColors.secondary,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            // Logo Container
            Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 100,
                    height: 100,
                    color: Colors.white,
                    colorBlendMode: BlendMode.srcATop,
                  ),
                )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  curve: Curves.easeOutBack,
                ),

            const SizedBox(height: 32),

            // App Name
            Column(
                  children: [
                    Text(
                      'NOUNOU',
                      style: AppTypography.h1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                    Text(
                      'EXPRESS',
                      style: AppTypography.h3.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w300,
                        letterSpacing: 8,
                      ),
                    ),
                  ],
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 800.ms)
                .slideY(begin: 0.2, end: 0),

            const Spacer(flex: 2),

            // Tagline
            Text(
              'Confiance • Sécurité • Proximité',
              style: AppTypography.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                letterSpacing: 1.5,
              ),
            ).animate().fadeIn(delay: 800.ms, duration: 1.seconds),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
