import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class AuthLayout extends StatelessWidget {
  final Widget? character;
  final String? title;
  final Widget child;
  final bool showBackButton;
  final VoidCallback? onBack;

  const AuthLayout({
    super.key,
    this.character,
    this.title,
    required this.child,
    this.showBackButton = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Background Wave ──────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: size.height * 0.45,
              child: CustomPaint(
                size: Size(size.width, size.height * 0.45),
                painter: _AuthBackgroundPainter(),
              ),
            ),
          ),

          // Decorative sparkles
          Positioned(
            top: 60,
            right: 40,
            child: Icon(
              Icons.star_rounded,
              color: Colors.white.withValues(alpha: 0.2),
              size: 24,
            ),
          ),
          Positioned(
            top: 100,
            left: 30,
            child: Icon(
              Icons.star_rounded,
              color: Colors.white.withValues(alpha: 0.1),
              size: 16,
            ),
          ),

          // ── Back Button ──────────────────────────────────────────────────
          if (showBackButton)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: onBack ?? () => Navigator.maybePop(context),
                ),
              ),
            ),

          // ── Content ──────────────────────────────────────────────────────
          Column(
            children: [
              // Header area (Wave + Logo + Character + Title)
              SizedBox(
                height: size.height * 0.45,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Logo at top
                    Positioned(
                      top: size.height * 0.06,
                      child: Image.asset(
                        'assets/logo.png',
                        height: 52,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Character illustration
                    if (character != null)
                      Positioned(bottom: size.height * 0.09, child: character!),

                    // Screen title
                    if (title != null)
                      Positioned(
                        bottom: size.height * 0.03,
                        child: Text(
                          title!,
                          style: AppTypography.h2.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Form / Body area
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        blurRadius: 40,
                        offset: const Offset(0, -10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl,
                    ),
                    child: child,
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

class _AuthBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final gradient = AppColors.primaryGradient;

    // Subtle decorative circle behind everything
    final bubblePaint = Paint()..color = Colors.white.withValues(alpha: 0.05);
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      120,
      bubblePaint,
    );

    // Light Layer (Secondary wave)
    final secondaryPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.15);
    final secondaryPath = Path();
    secondaryPath.lineTo(0, size.height * 0.9);
    secondaryPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.7,
      size.width,
      size.height * 0.85,
    );
    secondaryPath.lineTo(size.width, 0);
    secondaryPath.close();
    canvas.drawPath(secondaryPath, secondaryPaint);

    // Primary Layer with Gradient
    final primaryPaint = Paint()..shader = gradient.createShader(rect);
    final primaryPath = Path();
    primaryPath.lineTo(0, size.height * 0.75);
    primaryPath.cubicTo(
      size.width * 0.3,
      size.height * 0.9,
      size.width * 0.7,
      size.height * 0.5,
      size.width,
      size.height * 0.7,
    );
    primaryPath.lineTo(size.width, 0);
    primaryPath.close();
    canvas.drawPath(primaryPath, primaryPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
